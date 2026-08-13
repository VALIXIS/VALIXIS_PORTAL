import { corsHeaders } from '../_shared/cors.ts';
import { errorResponse, jsonResponse } from '../_shared/responses.ts';
import { requireManager } from '../_shared/auth.ts';

interface SendWhatsAppPayload {
  recipient: string;
  message: string;
  file?: {
    mimetype: string;
    base64: string;
    filename?: string;
  };
}

Deno.serve(async (req: Request) => {
  // CORS Preflight
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
    const body: SendWhatsAppPayload = await req.json().catch(
      () => ({}) as SendWhatsAppPayload
    );

    // 2. Validation
    if (!body.recipient || typeof body.recipient !== 'string' || !body.recipient.trim()) {
      return errorResponse('recipient is required', 400);
    }

    if (!body.message || typeof body.message !== 'string' || !body.message.trim()) {
      return errorResponse('message is required', 400);
    }

    if (body.file) {
      if (!body.file.mimetype || typeof body.file.mimetype !== 'string') {
        return errorResponse('file.mimetype is required when file is supplied', 400);
      }
      if (!body.file.base64 || typeof body.file.base64 !== 'string') {
        return errorResponse('file.base64 is required when file is supplied', 400);
      }
    }

    const payload = {
      recipient: body.recipient.trim(),
      message: body.message.trim(),
      file: body.file
    };

    console.log(`[send-whatsapp] Forwarding request to Cloudflare tunnel, recipient=${payload.recipient}`);

    // 3. Forward to WhatsApp Service on Cloudflare Tunnel
    const response = await fetch('https://href-plugins-pavilion-usa.trycloudflare.com/send-task-alert', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    const result = await response.json().catch(() => ({}));

    if (!response.ok) {
      console.error(`[send-whatsapp] Cloudflare request failed: status=${response.status}`, result);
      return errorResponse(result.error || 'Failed to send WhatsApp message', response.status);
    }

    console.log(`[send-whatsapp] Message forwarded successfully`);
    return jsonResponse(result, 200);

  } catch (err: any) {
    console.error('[send-whatsapp] Unhandled error:', err?.message || String(err));
    return errorResponse('Internal Server Error', 500);
  }
});
