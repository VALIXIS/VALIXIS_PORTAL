import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin } from '../_shared/supabase.ts';
import { requireManager } from '../_shared/auth.ts';

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'GET' && req.method !== 'POST') {
    return errorResponse('Method Not Allowed', 405);
  }

  const authResult = await requireManager(req);
  if (authResult.errorResponse) {
    return authResult.errorResponse;
  }

  try {
    const supabaseAdmin = getSupabaseAdmin();

    const [tasksRes, assignmentsRes, submissionsRes, employeesRes] = await Promise.all([
      supabaseAdmin.from('tasks').select('*'),
      supabaseAdmin.from('task_assignments').select('*'),
      supabaseAdmin.from('submissions').select('*').order('submitted_at', { ascending: false }),
      supabaseAdmin.from('employees').select('id, auth_id, name, email, role, department, phone'),
    ]);

    if (tasksRes.error) {
      return errorResponse(tasksRes.error.message, 400);
    }
    if (assignmentsRes.error) {
      return errorResponse(assignmentsRes.error.message, 400);
    }
    if (submissionsRes.error) {
      return errorResponse(submissionsRes.error.message, 400);
    }
    if (employeesRes.error) {
      return errorResponse(employeesRes.error.message, 400);
    }

    const tasks = tasksRes.data || [];
    const assignments = assignmentsRes.data || [];
    const submissions = submissionsRes.data || [];
    const employees = employeesRes.data || [];

    const assignedCount = assignments.filter((a) => a.status === 'assigned').length;
    const inProgressCount = assignments.filter((a) => a.status === 'in_progress').length;
    const submittedCount = assignments.filter((a) => a.status === 'submitted' || a.status === 'under_review').length;
    const approvedCount = assignments.filter((a) => a.status === 'approved' || a.status === 'completed').length;
    const rejectedCount = assignments.filter((a) => a.status === 'rejected').length;

    const metrics = {
      total_tasks: tasks.length,
      assigned_tasks: assignedCount,
      in_progress_tasks: inProgressCount,
      submitted_tasks: submittedCount,
      approved_tasks: approvedCount,
      rejected_tasks: rejectedCount,
      total_employees: employees.length,
    };

    return jsonResponse({
      success: true,
      metrics,
      recent_submissions: submissions.slice(0, 50),
      employees,
      tasks,
      assignments,
    });
  } catch (err: any) {
    return errorResponse(err?.message || String(err), 500);
  }
});
