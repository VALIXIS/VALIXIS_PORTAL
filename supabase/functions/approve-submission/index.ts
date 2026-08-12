import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin } from '../_shared/supabase.ts';
import { requireManager } from '../_shared/auth.ts';

interface ApproveSubmissionPayload {
  task_id?: string;
  submission_id?: string;
  assignment_id?: string;
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
    let assignmentId = body.assignment_id?.trim();

    const supabaseAdmin = getSupabaseAdmin();
    const now = new Date().toISOString();

    // Resolve assignment_id if missing
    if (!assignmentId) {
      if (submissionId) {
        const { data: sub, error: subErr } = await supabaseAdmin
          .from('submissions')
          .select('assignment_id')
          .eq('id', submissionId)
          .single();
        if (subErr || !sub) {
          return errorResponse('Submission not found', 404);
        }
        assignmentId = sub.assignment_id;
      } else if (taskId) {
        const { data: assign, error: assignErr } = await supabaseAdmin
          .from('task_assignments')
          .select('id')
          .eq('task_id', taskId)
          .single();
        if (assignErr || !assign) {
          return errorResponse('Task assignment not found', 404);
        }
        assignmentId = assign.id;
      } else {
        return errorResponse('Either task_id, submission_id, or assignment_id is required', 400);
      }
    }

    // 1. Update submissions table (exact production columns: review_status, manager_feedback, reviewed_at)
    const { error: subUpdateErr } = await supabaseAdmin
      .from('submissions')
      .update({
        review_status: 'approved',
        manager_feedback: body.feedback || null,
        reviewed_at: now,
      })
      .eq('assignment_id', assignmentId);

    if (subUpdateErr) {
      return errorResponse('Failed to update submission: ' + subUpdateErr.message, 500);
    }

    // 2. Update task_assignments table (exact production columns: status, updated_at)
    const { error: assignUpdateErr } = await supabaseAdmin
      .from('task_assignments')
      .update({
        status: 'approved',
        updated_at: now,
      })
      .eq('id', assignmentId);

    if (assignUpdateErr) {
      return errorResponse('Failed to update task assignment: ' + assignUpdateErr.message, 500);
    }

    return jsonResponse({
      success: true,
      message: 'Submission approved successfully',
      review_status: 'approved',
    });
  } catch (err: any) {
    return errorResponse('Internal Server Error', 500, err?.message || String(err));
  }
});
