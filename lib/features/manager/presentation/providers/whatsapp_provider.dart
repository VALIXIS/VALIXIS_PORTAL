import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/whatsapp_repository.dart';

final whatsappRepositoryProvider = Provider<WhatsAppRepository>((ref) {
  return WhatsAppRepository(ref.watch(supabaseClientProvider));
});

final whatsappSendNotifierProvider =
    StateNotifierProvider<WhatsAppSendNotifier, AsyncValue<void>>((ref) {
  return WhatsAppSendNotifier(ref);
});

class WhatsAppSendNotifier extends StateNotifier<AsyncValue<void>> {
  WhatsAppSendNotifier(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;

  Future<bool> sendWhatsApp({
    required String recipient,
    required String message,
    Map<String, dynamic>? file,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ref.read(whatsappRepositoryProvider).sendWhatsApp(
            recipient: recipient,
            message: message,
            file: file,
          );
    });
    return !state.hasError;
  }
}
