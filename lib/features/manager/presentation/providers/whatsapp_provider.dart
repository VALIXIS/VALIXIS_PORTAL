import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../shared/models/employee.dart';
import '../../../employee/data/mappers/employee_mapper.dart';
import '../../data/whatsapp_repository.dart';

final whatsappRepositoryProvider = Provider<WhatsAppRepository>((ref) {
  return WhatsAppRepository(ref.watch(supabaseClientProvider));
});

/// FutureProvider supplying list of ALL team contacts (employees, managers, co-founders) for Direct WhatsApp messaging.
final whatsappContactsProvider = FutureProvider<List<Employee>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  List<dynamic> list = [];

  try {
    final response = await client.from('employees').select();
    list = response as List<dynamic>;
  } catch (_) {}

  if (list.isEmpty) {
    try {
      final response = await client.functions.invoke('manager-dashboard');
      if (response.status < 400 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final raw = data['employees'] ??
            data['employee_list'] ??
            data['team'] ??
            data['workforce'];
        if (raw is List<dynamic> && raw.isNotEmpty) {
          list = raw;
        }
      }
    } catch (_) {}
  }

  final employees = <Employee>[];
  for (final item in list) {
    if (item is Map<String, dynamic>) {
      final emp = EmployeeMapper.fromJson(item);
      if (emp.id.isNotEmpty) {
        employees.add(emp);
      }
    }
  }
  return employees;
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
