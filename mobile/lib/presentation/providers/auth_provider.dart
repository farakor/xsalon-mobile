import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../data/models/user_profile.dart';

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
      await _supabase.auth.signInWithOtp(
        phone: phone,
      );
      
      // OTP отправлен успешно
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (error) {
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
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );

      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        
        // Создаем или обновляем профиль клиента
        await _createOrUpdateClientProfile(phone);
        await _loadUserProfile();
      }
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(error),
      );
    }
  }

  // Создание или обновление профиля клиента
  Future<void> _createOrUpdateClientProfile(String phone) async {
    if (state.user == null) return;

    try {
      // Проверяем, существует ли профиль
      final existingProfile = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', state.user!.id)
          .maybeSingle();

      if (existingProfile == null) {
        // Создаем новый профиль клиента
        await _supabase.from('user_profiles').insert({
          'id': state.user!.id,
          'phone': phone,
          'role': 'client',
          'is_active': true,
        });
      }
    } catch (error) {
      // TODO: Добавить логирование через Logger
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
