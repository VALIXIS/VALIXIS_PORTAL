import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin } from '../_shared/supabase.ts';
import { requireManager } from '../_shared/auth.ts';

interface CreateTaskPayload {
  title: string;
  description: string;
  ai_prompt: string;
  objective?: string;
  expected_output?: string;
  branch_name?: string;
  github_repository?: string;
  github_repo?: string;
  priority?: 'Low' | 'Medium' | 'High' | 'Critical';
  deadline?: string;
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
    const body: CreateTaskPayload = await req.json().catch(() => ({}) as CreateTaskPayload);

    if (!body.title?.trim()) {
      return errorResponse('Task title is required', 400);
    }
    if (!body.ai_prompt?.trim()) {
      return errorResponse('Task ai_prompt is required', 400);
    }

    const supabaseAdmin = getSupabaseAdmin();
    const githubRepo = (body.github_repository || body.github_repo || '').trim();

    const taskData = {
      title: body.title.trim(),
      description: body.description?.trim() || null,
      ai_prompt: body.ai_prompt.trim(),
      objective: body.objective?.trim() || null,
      expected_output: body.expected_output?.trim() || null,
      branch_name: body.branch_name?.trim() || null,
      github_repository: githubRepo.length > 0 ? githubRepo : null,
      priority: body.priority || 'Medium',
      deadline: body.deadline || null,
    };

    const { data, error } = await supabaseAdmin
      .from('tasks')
      .insert(taskData)
      .select()
      .single();

    if (error) {
      return errorResponse(error.message, 400);
    }

    return jsonResponse(
      {
        success: true,
        message: 'Task created successfully',
        task: data,
      },
      201
    );
  } catch (err: any) {
    return errorResponse(err?.message || String(err), 500);
  }
});
