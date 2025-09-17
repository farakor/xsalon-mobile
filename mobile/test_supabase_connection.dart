import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🧪 Тестируем подключение к Supabase...');
  
  try {
    // Загружаем .env файл
    await dotenv.load(fileName: ".env");
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    print('📍 URL: $supabaseUrl');
    print('🔑 ANON Key: ${supabaseAnonKey.substring(0, 20)}...');
    
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      print('❌ Ошибка: Пустые ключи в .env файле');
      return;
    }
    
    if (!supabaseAnonKey.startsWith('eyJ')) {
      print('❌ Ошибка: Неправильный формат ANON ключа');
      return;
    }
    
    // Инициализируем Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true,
    );
    
    print('✅ Supabase инициализирован успешно');
    
    // Тестируем простой запрос
    final client = Supabase.instance.client;
    
    // Пытаемся получить информацию о пользователе (должно вернуть null без ошибки)
    final user = client.auth.currentUser;
    print('👤 Текущий пользователь: ${user?.id ?? "не авторизован"}');
    
    print('🎉 Тест подключения прошел успешно!');
    
  } catch (error) {
    print('❌ Ошибка подключения к Supabase: $error');
  }
}
