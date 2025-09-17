import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/sms_debug_service.dart';

// Состояние аутентификации
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// Модель состояния аутентификации
class AuthState {
  final AuthStatus status;
  final User? user;
  final UserProfile? profile;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.profile,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Провайдер для управления аутентификацией
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  SupabaseClient get _supabase => SupabaseConfig.client;

  // Публичный метод для инициализации аутентификации
  void initialize() {
    _initializeAuth();
  }

  // Инициализация аутентификации
  void _initializeAuth() {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: session.user,
      );
      _loadUserProfile();
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    // Слушаем изменения состояния аутентификации
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        // Проверяем, изменился ли пользователь
        final currentUserId = state.user?.id;
        final newUserId = session.user.id;
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: session.user,
        );
        
        // Загружаем профиль только если пользователь изменился
        if (currentUserId != newUserId) {
          _loadUserProfile();
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          profile: null,
        );
      }
    });
  }

  // Загрузка профиля пользователя
  Future<void> _loadUserProfile() async {
    if (state.user == null) return;
    
    // Если профиль уже загружен для этого пользователя, не загружаем повторно
    if (state.profile != null && state.profile!.id == state.user!.id) {
      return;
    }

    try {
      print('Загружаем профиль для пользователя: ${state.user!.id}');
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', state.user!.id)
          .single();

      print('Получен ответ из БД: $response');
      final profile = UserProfile.fromJson(response);
      print('Создан профиль: ${profile.toString()}');
      state = state.copyWith(profile: profile);
    } catch (error) {
      print('Ошибка загрузки профиля: $error');
      // Профиль не найден или ошибка загрузки
      // TODO: Добавить логирование через Logger
    }
  }

  // Вход по email и паролю (для сотрудников)
  Future<void> signInWithEmailPassword(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        await _loadUserProfile();
      }
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(error),
      );
    }
  }

  // Отправка OTP на телефон
  Future<void> signInWithPhone(String phone) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // В тестовом режиме не отправляем реальный SMS через Supabase
      // Имитируем задержку отправки SMS
      await Future.delayed(const Duration(seconds: 1));
      
      // Логируем информацию о тестовом SMS
      SmsDebugService.logSmsInfo(phone);
      
      // OTP "отправлен" успешно (тестовый режим)
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (error) {
      print('Ошибка отправки OTP: $error');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(error),
      );
    }
  }

  // Верификация OTP кода
  Future<void> verifyOTP(String phone, String token) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // В тестовом режиме принимаем любой 6-значный код
      if (SmsDebugService.isValidDebugCode(token)) {
        SmsDebugService.logCodeVerification(phone, token);
        
        // Создаем пользователя через Supabase с email/password для тестирования
        final phoneClean = phone.replaceAll('+', '').replaceAll(' ', '');
        final debugEmail = 'client_$phoneClean@xsalon.test';
        final debugPassword = 'test123456';
        
        try {
          print('🔧 Создаем/ищем пользователя с email: $debugEmail');
          
          // Сначала пытаемся создать пользователя
          var response = await _supabase.auth.signUp(
            email: debugEmail,
            password: debugPassword,
            data: {
              'phone': phone,
              'full_name': 'Клиент ($phone)',
            },
          );
          
          print('📊 Результат создания: ${response.user != null ? "Пользователь создан" : "Ошибка создания"}');
          
          // Если пользователь уже существует, пытаемся войти
          if (response.user == null) {
            print('🔧 Пользователь уже существует, пытаемся войти...');
            response = await _supabase.auth.signInWithPassword(
              email: debugEmail,
              password: debugPassword,
            );
            print('📊 Результат входа: ${response.user != null ? "Вход успешен" : "Ошибка входа"}');
          }
          
          if (response.user != null) {
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: response.user,
            );
            
            // Создаем или обновляем профиль клиента
            await _createOrUpdateClientProfile(phone);
            await _loadUserProfile();
            
            print('✅ Тестовая авторизация успешна! Пользователь: ${response.user!.id}');
            return;
          }
        } catch (supabaseError) {
          print('❌ Ошибка работы с Supabase: $supabaseError');
          
          // Если это ошибка "пользователь уже существует", пытаемся войти
          if (supabaseError.toString().contains('already registered') || 
              supabaseError.toString().contains('User already registered')) {
            try {
              print('🔄 Пользователь уже зарегистрирован, пытаемся войти...');
              final loginResponse = await _supabase.auth.signInWithPassword(
                email: debugEmail,
                password: debugPassword,
              );
              
              if (loginResponse.user != null) {
                state = state.copyWith(
                  status: AuthStatus.authenticated,
                  user: loginResponse.user,
                );
                
                await _createOrUpdateClientProfile(phone);
                await _loadUserProfile();
                
                print('✅ Вход существующего пользователя успешен!');
                return;
              }
            } catch (loginError) {
              print('❌ Ошибка входа существующего пользователя: $loginError');
            }
          }
          
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Ошибка авторизации: ${_getErrorMessage(supabaseError)}',
          );
          return;
        }
      }
      
      // Если код неверный
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Неверный код подтверждения',
      );
    } catch (error) {
      print('Ошибка верификации OTP: $error');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(error),
      );
    }
  }

  // Создание debug профиля клиента (без обращения к Supabase)
  Future<void> _createDebugClientProfile(String phone, String userId) async {
    try {
      print('🔧 Создаем debug профиль клиента...');
      
      // Создаем локальный профиль для debug режима
      final debugProfile = UserProfile(
        id: userId,
        phone: phone,
        role: 'client',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fullName: 'Debug User ($phone)',
      );
      
      // Устанавливаем профиль в состояние
      state = state.copyWith(profile: debugProfile);
      
      print('✅ Debug профиль создан: ${debugProfile.displayName}');
    } catch (error) {
      print('❌ Ошибка создания debug профиля: $error');
    }
  }

  // Создание или обновление профиля клиента
  Future<void> _createOrUpdateClientProfile(String phone) async {
    if (state.user == null) return;

    try {
      print('Создаем/обновляем профиль клиента для пользователя: ${state.user!.id}');
      
      // Проверяем, существует ли профиль
      final existingProfile = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', state.user!.id)
          .maybeSingle();

      if (existingProfile == null) {
        print('Профиль не найден, создаем новый...');
        
        // Создаем новый профиль клиента
        final newProfile = {
          'id': state.user!.id,
          'phone': phone,
          'role': 'client',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        await _supabase.from('user_profiles').insert(newProfile);
        print('✅ Новый профиль клиента создан успешно');
        
        // Дополнительная проверка: убеждаемся, что запись в clients создалась
        await _ensureClientRecordExists(phone);
        
      } else {
        print('Профиль уже существует, обновляем данные...');
        
        // Обновляем существующий профиль
        await _supabase.from('user_profiles').update({
          'phone': phone,
          'last_login_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', state.user!.id);
        
        print('✅ Профиль клиента обновлен успешно');
        
        // Дополнительная проверка: убеждаемся, что запись в clients существует
        await _ensureClientRecordExists(phone);
      }
    } catch (error) {
      print('❌ Ошибка создания/обновления профиля клиента: $error');
      // Не прерываем процесс авторизации из-за ошибки профиля
    }
  }

  // Дополнительная проверка и создание записи в таблице clients
  Future<void> _ensureClientRecordExists(String phone) async {
    if (state.user == null) return;

    try {
      print('Проверяем существование записи в таблице clients...');
      
      // Проверяем, есть ли запись в clients
      final existingClient = await _supabase
          .from('clients')
          .select('id')
          .eq('user_profile_id', state.user!.id)
          .maybeSingle();

      if (existingClient == null) {
        print('Запись в clients не найдена, создаем...');
        
        // Создаем запись в clients
        final clientData = {
          'user_profile_id': state.user!.id,
          'full_name': 'Клиент ($phone)',
          'phone': phone,
          'status': 'active',
          'total_visits': 0,
          'total_spent': 0.00,
          'loyalty_points': 0,
          'loyalty_level': 'Новичок',
        };
        
        await _supabase.from('clients').insert(clientData);
        print('✅ Запись в таблице clients создана успешно');
      } else {
        print('✅ Запись в таблице clients уже существует');
      }
    } catch (error) {
      print('❌ Ошибка проверки/создания записи в clients: $error');
      // Не критично, триггер БД должен справиться
    }
  }

  // Выход из системы
  Future<void> signOut() async {
    try {
      print('Начинаем выход из аккаунта...');
      await _supabase.auth.signOut();
      print('Supabase signOut завершен');
      
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        profile: null,
      );
      print('Состояние обновлено: ${state.status}');
    } catch (error) {
      print('Ошибка при выходе: $error');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(error),
      );
    }
  }

  // Очистка ошибок
  void clearError() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }

  // Получение сообщения об ошибке
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Неверный email или пароль';
        case 'Email not confirmed':
          return 'Email не подтвержден';
        case 'Invalid phone number':
          return 'Неверный номер телефона';
        case 'Token has expired or is invalid':
          return 'Код подтверждения истек или неверен';
        default:
          return error.message;
      }
    }
    return 'Произошла ошибка: ${error.toString()}';
  }
}

// Провайдер состояния аутентификации
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Провайдер для проверки аутентификации
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.authenticated;
});

// Провайдер для получения текущего пользователя
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

// Провайдер для получения профиля пользователя
final userProfileProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.profile;
});

// Провайдер для проверки роли пользователя
final isStaffProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.role == 'master' || 
         profile?.role == 'admin' || 
         profile?.role == 'owner';
});
