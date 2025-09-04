import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static Future<void> initialize() async {
    // Загружаем переменные окружения
    await dotenv.load(fileName: ".env");
    
    // Проверяем, что ключи загружены
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase configuration not found. Please check your .env file.'
      );
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Включить в development режиме
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
}
