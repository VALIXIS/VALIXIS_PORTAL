import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/task.dart';
import 'mappers/task_mapper.dart';

/// Repository for fetching individual task assignment details from Supabase.
class TaskDetailsRepository {
  TaskDetailsRepository(this._client);

  final SupabaseClient _client;

  /// Fetches task details by [taskId] using task_assignments join or tasks table.
  Future<Task?> getTaskDetails(String taskId) async {
    try {
      final data = await _client
          .from('task_assignments')
          .select('*, tasks(*), employees(*)')
          .or('id.eq.$taskId,task_id.eq.$taskId')
          .maybeSingle();

      if (data != null) {
        return TaskMapper.fromJson(data);
      }
    } catch (_) {
      // Fall through to direct tasks table lookup
    }

    try {
      final data =
          await _client.from('tasks').select().eq('id', taskId).maybeSingle();

      if (data != null) {
        return TaskMapper.fromJson(data);
      }
    } catch (_) {
      // Return null if task does not exist
    }

    return null;
  }
}
