import '../../core/config/supabase_config.dart';

/// Сервис для отладки SMS кодов в development режиме
class SmsDebugService {
  static const String _debugCode = '123456';
  
  /// Проверяет, включен ли debug режим для SMS (всегда true для тестирования)
  static bool get isDebugMode => true;
  
  /// Возвращает debug код для тестирования
  static String get debugCode => _debugCode;
  
  /// Логирует информацию об отправке SMS в консоль
  static void logSmsInfo(String phone) {
    print('');
    print('🔐 ═══════════════════════════════════════════════════════════');
    print('📱 ТЕСТОВЫЙ РЕЖИМ SMS');
    print('🔐 ═══════════════════════════════════════════════════════════');
    print('📞 Номер телефона: $phone');
    print('🔑 Рекомендуемый код: $_debugCode');
    print('✅ Любой 6-значный код будет принят');
    print('🚀 SMS не отправляется - только имитация');
    print('💡 Для production подключите реального SMS провайдера');
    print('🔐 ═══════════════════════════════════════════════════════════');
    print('');
  }
  
  /// Логирует информацию о верификации кода
  static void logCodeVerification(String phone, String code) {
    print('');
    print('🔐 ═══════════════════════════════════════════════════════════');
    print('✅ ВЕРИФИКАЦИЯ КОДА (ТЕСТОВЫЙ РЕЖИМ)');
    print('🔐 ═══════════════════════════════════════════════════════════');
    print('📞 Номер: $phone');
    print('🔑 Введенный код: $code');
    print('✅ Код принят - создаем пользователя в Supabase');
    print('🚀 SMS не проверяется - используем email/password авторизацию');
    print('🔐 ═══════════════════════════════════════════════════════════');
    print('');
  }
  
  /// Проверяет, является ли код валидным в тестовом режиме
  static bool isValidDebugCode(String code) {
    // В тестовом режиме принимаем любой 6-значный код
    return code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code);
  }
}
