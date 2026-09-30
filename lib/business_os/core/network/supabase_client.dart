import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  final url = dotenv.get(
    'SUPABASE_URL',
    fallback: 'https://qbvlzhjnqrwsoyvpomyt.supabase.co',
  );
  final anonKey = dotenv.get('SUPABASE_ANON_KEY', fallback: '');

  await Supabase.initialize(
    url: url,
    // ignore: deprecated_member_use
    anonKey: anonKey,
    debug: false,
  );
}

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final currentSessionProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
