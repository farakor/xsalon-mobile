import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static bool get debugSmsToConsole => dotenv.env['DEBUG_SMS_TO_CONSOLE'] == 'true';
  
  static Future<void> initialize() async {
    // Загружаем переменные окружения
    await dotenv.load(fileName: ".env");
    
    print('🔧 Загружаем конфигурацию Supabase...');
    print('📍 URL: $supabaseUrl');
    print('🔑 ANON Key: ${supabaseAnonKey.substring(0, 20)}...');
    
    // Проверяем, что ключи загружены
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase configuration not found. Please check your .env file.'
      );
    }
    
    // Проверяем формат ключа
    if (!supabaseAnonKey.startsWith('eyJ')) {
      throw Exception(
        'Invalid Supabase ANON key format. Key should start with "eyJ"'
      );
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Включить в development режиме
    );
    
    print('✅ Supabase инициализирован успешно');
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
}
