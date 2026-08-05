import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin } from '../_shared/supabase.ts';

interface SubmitPullRequestPayload {
  task_id: string;
  pr_url: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return errorResponse('Method Not Allowed', 405);
  }

  try {
    const body: SubmitPullRequestPayload = await req.json().catch(() => ({}) as SubmitPullRequestPayload);

    const taskId = body.task_id?.trim();
    const prUrl = body.pr_url?.trim();

    if (!taskId) {
      return errorResponse('task_id is required', 400);
    }

    if (!prUrl || !prUrl.startsWith('https://github.com/')) {
      return errorResponse('A valid GitHub Pull Request URL starting with https://github.com/ is required', 400);
    }

    const supabaseAdmin = getSupabaseAdmin();
    const now = new Date().toISOString();

    // 1. Insert record into submissions table
    const { data: subData, error: subError } = await supabaseAdmin
      .from('submissions')
      .insert({
        task_id: taskId,
        pr_url: prUrl,
        status: 'submitted',
        submitted_at: now,
      })
      .select()
      .single();

    if (subError) {
      console.warn('Submission table insert notice:', subError.message);
    }

    // 2. Update task_assignments status to 'submitted'
    const { error: assignError } = await supabaseAdmin
      .from('task_assignments')
      .update({
        status: 'submitted',
        updated_at: now,
      })
      .eq('task_id', taskId);

    if (assignError) {
      console.warn('Task assignments update notice:', assignError.message);
    }

    return jsonResponse(
      {
        success: true,
        message: 'Pull request submitted successfully',
        submission: subData || { task_id: taskId, pr_url: prUrl, status: 'submitted' },
      },
      201
    );
  } catch (err: any) {
    return errorResponse('Internal Server Error', 500, err?.message || String(err));
  }
});
