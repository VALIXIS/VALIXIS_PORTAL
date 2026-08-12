import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin } from '../_shared/supabase.ts';
import { requireManager } from '../_shared/auth.ts';

interface ApproveSubmissionPayload {
  task_id?: string;
  submission_id?: string;
  feedback?: string;
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
    const body: ApproveSubmissionPayload = await req.json().catch(() => ({}) as ApproveSubmissionPayload);

    const taskId = body.task_id?.trim();
    const submissionId = body.submission_id?.trim();

    if (!taskId && !submissionId) {
      return errorResponse('Either task_id or submission_id is required', 400);
    }

    const supabaseAdmin = getSupabaseAdmin();
    const now = new Date().toISOString();

    if (submissionId) {
      const { error: subErr } = await supabaseAdmin
        .from('submissions')
        .update({
          status: 'approved',
          feedback: body.feedback || null,
          reviewed_at: now,
        })
        .eq('id', submissionId);

      if (subErr) {
        return errorResponse('Failed to update submission status: ' + subErr.message, 500);
      }
    }

    if (taskId) {
      const { error: assignErr } = await supabaseAdmin
        .from('task_assignments')
        .update({
          status: 'approved',
          updated_at: now,
        })
        .eq('task_id', taskId);

      if (assignErr) {
        return errorResponse('Failed to update task assignment: ' + assignErr.message, 500);
      }

      const { error: subErr } = await supabaseAdmin
        .from('submissions')
        .update({
          status: 'approved',
          feedback: body.feedback || null,
          reviewed_at: now,
        })
        .eq('task_id', taskId);

      if (subErr) {
        return errorResponse('Failed to update submission status: ' + subErr.message, 500);
      }
    }

    return jsonResponse({
      success: true,
      message: 'Submission approved successfully',
      status: 'approved',
    });
  } catch (err: any) {
    return errorResponse('Internal Server Error', 500, err?.message || String(err));
  }
});
