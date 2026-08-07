import { errorResponse } from './responses.ts';
import { getSupabaseAdmin, getSupabaseUserClient } from './supabase.ts';

export interface ManagerAuthResult {
  user?: any;
  errorResponse?: Response;
}

/**
 * Shared helper enforcing manager authorization on Edge Functions.
 *
 * 1. Retrieves authenticated user from Authorization header. (401 if missing/invalid)
 * 2. Looks up employee role in employees table where auth_id == user.id.
 * 3. Returns 403 Forbidden if role != manager.
 */
export async function requireManager(req: Request): Promise<ManagerAuthResult> {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return {
      errorResponse: errorResponse('Unauthorized', 401),
    };
  }

  try {
    const supabaseUser = getSupabaseUserClient(authHeader);
    const { data: { user }, error: userError } = await supabaseUser.auth.getUser();

    if (userError || !user) {
      return {
        errorResponse: errorResponse('Unauthorized', 401),
      };
    }

    const supabaseAdmin = getSupabaseAdmin();
    const { data: employee, error: empError } = await supabaseAdmin
      .from('employees')
      .select('role')
      .eq('auth_id', user.id)
      .maybeSingle();

    if (empError || !employee || !employee.role) {
      return {
        errorResponse: errorResponse('Forbidden', 403),
      };
    }

    const roleNormalized = String(employee.role).toLowerCase().trim();
    const isManagerRole =
      roleNormalized === 'manager' ||
      roleNormalized === 'admin' ||
      roleNormalized === 'lead';

    if (!isManagerRole) {
      return {
        errorResponse: errorResponse('Forbidden', 403),
      };
    }

    return { user };
  } catch (err: any) {
    return {
      errorResponse: errorResponse('Forbidden', 403),
    };
  }
}
