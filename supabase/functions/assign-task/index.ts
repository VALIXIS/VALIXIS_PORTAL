import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin } from '../_shared/supabase.ts';
import { requireManager } from '../_shared/auth.ts';

interface AssignTaskPayload {
  task_id: string;
  employee_id: string; // numeric employees.id sent as string from Flutter
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return errorResponse('Method Not Allowed', 405);
  }

  // 1. Verify caller is an authenticated manager
  const authResult = await requireManager(req);
  if (authResult.errorResponse) {
    return authResult.errorResponse;
  }

  try {
    const body: AssignTaskPayload = await req.json().catch(() => ({}) as AssignTaskPayload);

    if (!body.task_id || typeof body.task_id !== 'string' || !body.task_id.trim()) {
      return errorResponse('task_id is required', 400);
    }

    if (!body.employee_id || typeof body.employee_id !== 'string' || !body.employee_id.trim()) {
      return errorResponse('employee_id is required', 400);
    }

    const supabaseAdmin = getSupabaseAdmin();
    const taskId = body.task_id.trim();
    const employeeIdRaw = body.employee_id.trim();

    // 2. Resolve employee — Flutter sends employees.id (numeric) as a string.
    //    Look up by numeric id first; if the value looks like a UUID, look up via auth_id instead.
    const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(employeeIdRaw);

    let employee: { id: number; name: string } | null = null;

    if (isUuid) {
      // The Flutter UI passed employees.auth_id — resolve to employees.id
      const { data, error } = await supabaseAdmin
        .from('employees')
        .select('id, name')
        .eq('auth_id', employeeIdRaw)
        .maybeSingle();

      if (error) {
        console.error('Employee auth_id lookup error:', error.message);
        return errorResponse('Database error while resolving employee', 500);
      }
      employee = data;
    } else {
      // The Flutter UI passed the numeric employees.id (expected path)
      const numericId = parseInt(employeeIdRaw, 10);
      if (isNaN(numericId)) {
        return errorResponse(`Invalid employee_id format: "${employeeIdRaw}". Expected a numeric employees.id or a UUID auth_id.`, 400);
      }

      const { data, error } = await supabaseAdmin
        .from('employees')
        .select('id, name')
        .eq('id', numericId)
        .maybeSingle();

      if (error) {
        console.error('Employee id lookup error:', error.message);
        return errorResponse('Database error while resolving employee', 500);
      }
      employee = data;
    }

    if (!employee) {
      return errorResponse('Employee not found. The selected employee no longer exists.', 404);
    }

    const resolvedEmployeeId: number = employee.id;

    // 3. Verify the task exists
    const { data: task, error: taskError } = await supabaseAdmin
      .from('tasks')
      .select('id, title')
      .eq('id', taskId)
      .maybeSingle();

    if (taskError) {
      console.error('Task lookup error:', taskError.message);
      return errorResponse('Database error while resolving task', 500);
    }

    if (!task) {
      return errorResponse('Task not found. The selected task no longer exists.', 404);
    }

    const now = new Date().toISOString();

    // 4. Check for an existing assignment for this task
    const { data: existingAssignment, error: existingError } = await supabaseAdmin
      .from('task_assignments')
      .select('id, employee_id, status')
      .eq('task_id', taskId)
      .maybeSingle();

    if (existingError) {
      console.error('Existing assignment check error:', existingError.message);
      return errorResponse('Database error while checking existing assignment', 500);
    }

    if (existingAssignment) {
      if (existingAssignment.employee_id === resolvedEmployeeId) {
        // Same employee — return 409 Conflict
        return errorResponse(
          `This task is already assigned to ${employee.name || 'this employee'}.`,
          409
        );
      }

      // Different employee — reassign by updating the existing row
      const { data: updatedAssignment, error: updateError } = await supabaseAdmin
        .from('task_assignments')
        .update({
          employee_id: resolvedEmployeeId,
          status: 'assigned',
          assigned_at: now,
        })
        .eq('id', existingAssignment.id)
        .select()
        .single();

      if (updateError) {
        console.error('Assignment update error:', updateError.message);
        return errorResponse('Failed to reassign task: ' + updateError.message, 500);
      }

      return jsonResponse(
        {
          success: true,
          message: 'Task reassigned successfully',
          assignment: updatedAssignment,
        },
        200
      );
    }

    // 5. No existing assignment — INSERT a fresh row
    //    Only insert columns that actually exist on task_assignments:
    //    id (auto), task_id, employee_id, status, assigned_at, updated_at
    const { data: newAssignment, error: insertError } = await supabaseAdmin
      .from('task_assignments')
      .insert({
        task_id: taskId,
        employee_id: resolvedEmployeeId,
        status: 'assigned',
        assigned_at: now,
      })
      .select()
      .single();

    if (insertError) {
      console.error('Assignment insert error:', insertError.message, insertError.details);
      return errorResponse('Failed to assign task: ' + insertError.message, 500);
    }

    return jsonResponse(
      {
        success: true,
        message: 'Task assigned successfully',
        assignment: newAssignment,
      },
      201
    );
  } catch (err: any) {
    console.error('assign-task unhandled error:', err?.message || String(err));
    return errorResponse('Internal Server Error', 500);
  }
});
