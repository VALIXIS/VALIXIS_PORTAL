import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin } from '../_shared/supabase.ts';
import { requireManager } from '../_shared/auth.ts';

interface DeleteTaskPayload {
  task_id: string;
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
    const body: DeleteTaskPayload = await req.json().catch(() => ({}) as DeleteTaskPayload);

    if (!body.task_id || typeof body.task_id !== 'string') {
      return errorResponse('task_id is required', 400);
    }

    const taskId = body.task_id.trim();
    const supabaseAdmin = getSupabaseAdmin();

    // Cascading delete using assignment_id mapping
    const { data: assignments } = await supabaseAdmin
      .from('task_assignments')
      .select('id')
      .eq('task_id', taskId);

    if (assignments && assignments.length > 0) {
      const assignmentIds = assignments.map((a: { id: string }) => a.id);
      await supabaseAdmin.from('submissions').delete().in('assignment_id', assignmentIds);
    }

    await supabaseAdmin.from('task_assignments').delete().eq('task_id', taskId);
    const { error: taskErr } = await supabaseAdmin.from('tasks').delete().eq('id', taskId);

    if (taskErr) {
      return errorResponse('Failed to delete task', 500, taskErr.message);
    }

    return jsonResponse(
      {
        success: true,
        message: 'Task deleted successfully',
      },
      200
    );
  } catch (err: any) {
    return errorResponse('Internal Server Error', 500, err?.message || String(err));
  }
});
