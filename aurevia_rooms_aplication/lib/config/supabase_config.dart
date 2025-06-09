import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_constant.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.url,
      anonKey: SupabaseConstants.anonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}


