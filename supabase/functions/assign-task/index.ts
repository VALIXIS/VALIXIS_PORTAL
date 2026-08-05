import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin } from '../_shared/supabase.ts';
import { requireManager } from '../_shared/auth.ts';

interface AssignTaskPayload {
  task_id: string;
  employee_id: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return errorResponse('Method Not Allowed', 405);
  }

  const authResult = await requireManager(req);
  if (authResult.errorResponse) {
    return authResult.errorResponse;
  }

  try {
    const body: AssignTaskPayload = await req.json().catch(() => ({}) as AssignTaskPayload);

    if (!body.task_id || typeof body.task_id !== 'string') {
      return errorResponse('task_id is required', 400);
    }

    if (!body.employee_id || typeof body.employee_id !== 'string') {
      return errorResponse('employee_id is required', 400);
    }

    const supabaseAdmin = getSupabaseAdmin();

    const assignmentData = {
      task_id: body.task_id.trim(),
      employee_id: body.employee_id.trim(),
      status: 'assigned',
      assigned_at: new Date().toISOString(),
    };

    const { data, error } = await supabaseAdmin
      .from('task_assignments')
      .insert(assignmentData)
      .select()
      .single();

    if (error) {
      return errorResponse('Failed to assign task to employee', 500, error.message);
    }

    return jsonResponse(
      {
        success: true,
        message: 'Task assigned successfully',
        assignment: data,
      },
      201
    );
  } catch (err: any) {
    return errorResponse('Internal Server Error', 500, err?.message || String(err));
  }
});
