import 'package:supabase_flutter/supabase_flutter.dart';

class WhatsAppRepository {
  WhatsAppRepository(this._client);
  final SupabaseClient _client;

  Future<void> sendWhatsApp({
    required String recipient,
    required String message,
    Map<String, dynamic>? file,
  }) async {
    final response = await _client.functions.invoke(
      'send-whatsapp',
      body: {
        'recipient': recipient,
        'message': message,
        'file': file,
      },
    );

    if (response.status >= 400) {
      final errorMsg = response.data is Map && response.data['error'] != null
          ? response.data['error']
          : 'Failed to send WhatsApp message (status ${response.status})';
      throw Exception(errorMsg);
    }
  }
}
