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

    // Look up employee id
    const { data: employee, error: empError } = await supabaseAdmin
      .from('employees')
      .select('id')
      .eq('auth_id', user.id)
      .single();

    if (empError || !employee) {
      return errorResponse('Employee profile not found', 403);
    }

    const employeeId = employee.id;

    // Verify task assignment
    const { data: assignment, error: assignVerifyError } = await supabaseAdmin
      .from('task_assignments')
      .select('*')
      .eq('task_id', taskId)
      .eq('employee_id', employeeId)
      .single();

    if (assignVerifyError || !assignment) {
      return errorResponse('You are not assigned to this task', 403);
    }

    // 1. Insert record into submissions table
    const { data: subData, error: subError } = await supabaseAdmin
      .from('submissions')
      .insert({
        task_id: taskId,
        employee_id: employeeId,
        pr_url: prUrl,
        status: 'submitted',
        submitted_at: now,
      })
      .select()
      .single();

    if (subError) {
      return errorResponse('Failed to create submission: ' + subError.message, 500);
    }

    // 2. Update task_assignments status to 'submitted'
    const { error: assignError } = await supabaseAdmin
      .from('task_assignments')
      .update({
        status: 'submitted',
        updated_at: now,
      })
      .eq('task_id', taskId)
      .eq('employee_id', employeeId);

    if (assignError) {
      return errorResponse('Failed to update task assignment: ' + assignError.message, 500);
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
