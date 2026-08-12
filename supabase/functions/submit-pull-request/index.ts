import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin, getSupabaseUserClient } from '../_shared/supabase.ts';

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
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return errorResponse('Unauthorized', 401);
    }

    const supabaseUser = getSupabaseUserClient(authHeader);
    const { data: { user }, error: userError } = await supabaseUser.auth.getUser();

    if (userError || !user) {
      return errorResponse('Unauthorized', 401);
    }

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

    // 1. Resolve employee primary key (numeric id) from auth_id UUID
    const { data: employee, error: empError } = await supabaseAdmin
      .from('employees')
      .select('id')
      .eq('auth_id', user.id)
      .single();

    if (empError || !employee) {
      return errorResponse('Employee profile not found', 403);
    }

    // 2. Resolve task_assignments record matching employee.id and taskId
    const { data: assignment, error: assignError } = await supabaseAdmin
      .from('task_assignments')
      .select('id, task_id, employee_id')
      .eq('task_id', taskId)
      .eq('employee_id', employee.id)
      .single();

    if (assignError || !assignment) {
      return errorResponse('You are not assigned to this task', 403);
    }

    const assignmentId = assignment.id;

    // 3. Query existing submission for this assignment_id to respect unique_assignment_submission constraint
    const { data: existingSub, error: subQueryError } = await supabaseAdmin
      .from('submissions')
      .select('id, assignment_id, review_status')
      .eq('assignment_id', assignmentId)
      .maybeSingle();

    if (subQueryError) {
      return errorResponse('Database query error: ' + subQueryError.message, 500);
    }

    let subData: any;

    if (!existingSub) {
      // INSERT new submission
      const { data: insertedData, error: subInsertError } = await supabaseAdmin
        .from('submissions')
        .insert({
          assignment_id: assignmentId,
          pr_url: prUrl,
          review_status: 'pending',
          submitted_at: now,
          reviewed_at: null,
          manager_feedback: null,
        })
        .select()
        .single();

      if (subInsertError) {
        return errorResponse('Failed to create submission: ' + subInsertError.message, 500);
      }
      subData = insertedData;
    } else {
      // Reject re-submission if already approved
      if (existingSub.review_status === 'approved') {
        return errorResponse('This task has already been approved.', 409);
      }

      // UPDATE existing submission (for rejected or pending re-submissions)
      const { data: updatedData, error: subUpdateError } = await supabaseAdmin
        .from('submissions')
        .update({
          pr_url: prUrl,
          review_status: 'pending',
          submitted_at: now,
          reviewed_at: null,
          manager_feedback: null,
        })
        .eq('id', existingSub.id)
        .select()
        .single();

      if (subUpdateError) {
        return errorResponse('Failed to update submission: ' + subUpdateError.message, 500);
      }
      subData = updatedData;
    }

    // 4. Update task_assignments.status to 'submitted'
    const { error: assignUpdateError } = await supabaseAdmin
      .from('task_assignments')
      .update({
        status: 'submitted',
        updated_at: now,
      })
      .eq('id', assignmentId);

    if (assignUpdateError) {
      return errorResponse('Failed to update task assignment: ' + assignUpdateError.message, 500);
    }

    return jsonResponse(
      {
        success: true,
        message: 'Pull request submitted successfully',
        submission: subData,
      },
      201
    );
  } catch (err: any) {
    return errorResponse('Internal Server Error', 500, err?.message || String(err));
  }
});
