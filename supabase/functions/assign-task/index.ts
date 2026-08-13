import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { getSupabaseAdmin } from '../_shared/supabase.ts';
import { requireManager } from '../_shared/auth.ts';

interface AssignTaskPayload {
  task_id: string;
  employee_id: string; // May be: numeric employees.id string, UUID auth_id, or email
}

/**
 * Resolves an employee record from the `employees` table using the identifier
 * value that Flutter sends.  Flutter's EmployeeMapper reads json['id'] first —
 * which is the BIGINT employees.id serialised as a string by Supabase-js.
 * However, in some code-paths the mapper falls back to auth_id (UUID) or email.
 *
 * Strategy (in order, no type-mixing in a single OR query):
 *  1. Numeric string  → WHERE id     = <bigint>
 *  2. UUID string     → WHERE auth_id = <uuid>
 *  3. Email string    → WHERE email  = <email>
 *
 * Returns the full employee row, or null if none of the strategies match.
 */
async function resolveEmployee(
  supabaseAdmin: ReturnType<typeof import('../_shared/supabase.ts').getSupabaseAdmin>,
  raw: string
): Promise<{ id: number; name: string; email: string } | null> {

  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  // ── Strategy 1: numeric employees.id ──────────────────────────────────────
  const numericId = parseInt(raw, 10);
  if (!isNaN(numericId) && String(numericId) === raw.trim()) {
    console.log(`[assign-task] Lookup by numeric id: ${numericId}`);
    const { data, error } = await supabaseAdmin
      .from('employees')
      .select('id, name, email')
      .eq('id', numericId)
      .maybeSingle();

    if (error) {
      console.error('[assign-task] Numeric id lookup DB error:', error.message);
    } else if (data) {
      console.log(`[assign-task] Resolved by numeric id: ${data.name} (id=${data.id})`);
      return data;
    }
  }

  // ── Strategy 2: UUID → employees.auth_id ──────────────────────────────────
  if (uuidRegex.test(raw)) {
    console.log(`[assign-task] Lookup by auth_id UUID: ${raw}`);
    const { data, error } = await supabaseAdmin
      .from('employees')
      .select('id, name, email')
      .eq('auth_id', raw)
      .maybeSingle();

    if (error) {
      console.error('[assign-task] auth_id lookup DB error:', error.message);
    } else if (data) {
      console.log(`[assign-task] Resolved by auth_id: ${data.name} (id=${data.id})`);
      return data;
    }

    // Also try employees.id as UUID — in case employees.id is UUID not BIGINT
    console.log(`[assign-task] Lookup by employees.id as UUID: ${raw}`);
    const { data: d2, error: e2 } = await supabaseAdmin
      .from('employees')
      .select('id, name, email')
      .eq('id', raw)
      .maybeSingle();

    if (e2) {
      console.error('[assign-task] UUID id lookup DB error:', e2.message);
    } else if (d2) {
      console.log(`[assign-task] Resolved by id-as-UUID: ${d2.name} (id=${d2.id})`);
      return d2;
    }
  }

  // ── Strategy 3: email ─────────────────────────────────────────────────────
  if (emailRegex.test(raw)) {
    console.log(`[assign-task] Lookup by email: ${raw}`);
    const { data, error } = await supabaseAdmin
      .from('employees')
      .select('id, name, email')
      .eq('email', raw)
      .maybeSingle();

    if (error) {
      console.error('[assign-task] Email lookup DB error:', error.message);
    } else if (data) {
      console.log(`[assign-task] Resolved by email: ${data.name} (id=${data.id})`);
      return data;
    }
  }

  console.error(`[assign-task] All lookup strategies exhausted for identifier: "${raw}"`);
  return null;
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
    const body: AssignTaskPayload = await req.json().catch(
      () => ({}) as AssignTaskPayload
    );

    if (!body.task_id || typeof body.task_id !== 'string' || !body.task_id.trim()) {
      return errorResponse('task_id is required', 400);
    }

    if (
      !body.employee_id ||
      typeof body.employee_id !== 'string' ||
      !body.employee_id.trim()
    ) {
      return errorResponse('employee_id is required', 400);
    }

    const supabaseAdmin = getSupabaseAdmin();
    const taskId       = body.task_id.trim();
    const employeeRaw  = body.employee_id.trim();

    console.log(`[assign-task] Received task_id="${taskId}" employee_id="${employeeRaw}"`);

    // 2. Resolve employee via multi-strategy lookup
    const employee = await resolveEmployee(supabaseAdmin, employeeRaw);

    if (!employee) {
      return errorResponse(
        `Employee not found for identifier "${employeeRaw}". ` +
        `Checked employees.id (numeric), employees.auth_id (UUID), and employees.email.`,
        404
      );
    }

    const resolvedEmployeeId = employee.id;

    // 3. Verify task exists and fetch branch_name for the WhatsApp notification
    const { data: task, error: taskError } = await supabaseAdmin
      .from('tasks')
      .select('id, title, branch_name')
      .eq('id', taskId)
      .maybeSingle();

    if (taskError) {
      console.error('[assign-task] Task lookup error:', taskError.message);
      return errorResponse('Database error while resolving task', 500);
    }

    if (!task) {
      return errorResponse('Task not found. The selected task no longer exists.', 404);
    }

    const now = new Date().toISOString();

    // 4. Check for an existing assignment on this task
    const { data: existing, error: existingError } = await supabaseAdmin
      .from('task_assignments')
      .select('id, employee_id, status')
      .eq('task_id', taskId)
      .maybeSingle();

    if (existingError) {
      console.error('[assign-task] Existing assignment check error:', existingError.message);
      return errorResponse('Database error while checking existing assignment', 500);
    }

    if (existing) {
      // Compare as strings to avoid BIGINT / number type coercion issues
      if (String(existing.employee_id) === String(resolvedEmployeeId)) {
        return errorResponse(
          `This task is already assigned to ${employee.name || 'this employee'}.`,
          409
        );
      }

      // Different employee — UPDATE to reassign
      console.log(
        `[assign-task] Reassigning task "${task.title}" from employee_id=${existing.employee_id} to ${employee.name} (id=${resolvedEmployeeId})`
      );

      const { data: updated, error: updateError } = await supabaseAdmin
        .from('task_assignments')
        .update({
          employee_id : resolvedEmployeeId,
          status      : 'assigned',
          assigned_at : now,
        })
        .eq('id', existing.id)
        .select()
        .single();

      if (updateError) {
        console.error('[assign-task] Reassignment update error:', updateError.message);
        return errorResponse('Failed to reassign task: ' + updateError.message, 500);
      }

      return jsonResponse(
        {
          success    : true,
          message    : `Task reassigned to ${employee.name} successfully`,
          assignment : updated,
        },
        200
      );
    }

    // 5. No existing assignment — INSERT fresh row using only real production columns
    console.log(
      `[assign-task] Creating new assignment: task="${task.title}" → employee="${employee.name}" (id=${resolvedEmployeeId})`
    );

    const { data: created, error: insertError } = await supabaseAdmin
      .from('task_assignments')
      .insert({
        task_id     : taskId,
        employee_id : resolvedEmployeeId,
        status      : 'assigned',
        assigned_at : now,
      })
      .select()
      .single();

    if (insertError) {
      console.error(
        '[assign-task] Assignment insert error:',
        insertError.message,
        insertError.details
      );
      return errorResponse('Failed to assign task: ' + insertError.message, 500);
    }

    console.log(`[assign-task] Assignment created id=${created.id}`);

    return jsonResponse(
      {
        success    : true,
        message    : `Task assigned to ${employee.name} successfully`,
        assignment : created,
      },
      201
    );
  } catch (err: any) {
    console.error('[assign-task] Unhandled error:', err?.message || String(err));
    return errorResponse('Internal Server Error', 500);
  }
});
