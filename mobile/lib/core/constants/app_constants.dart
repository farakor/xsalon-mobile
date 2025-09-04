class AppConstants {
  // App Info
  static const String appName = 'XSalon';
  static const String appVersion = '1.0.0';
  
  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Booking
  static const int maxBookingDaysAhead = 30;
  static const int minBookingHoursAhead = 2;
  static const int defaultServiceDuration = 60; // minutes
  
  // Loyalty
  static const double defaultPointsPerRuble = 0.01;
  static const int minPointsToRedeem = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  
  // Phone
  static const String phonePattern = r'^\+998\d{9}$';
  static const String phoneMask = '+998 ## ### ## ##';
  
  // Date & Time
  static const String dateFormat = 'dd.MM.yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userProfileKey = 'user_profile';
  static const String selectedOrganizationKey = 'selected_organization';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Routes
  static const String splashRoute = '/';
  static const String authRoute = '/auth';
  static const String loginRoute = '/auth/login';
  static const String registerRoute = '/auth/register';
  static const String phoneAuthRoute = '/auth/phone';
  static const String otpVerificationRoute = '/auth/otp';
  static const String staffLoginRoute = '/auth/staff';
  static const String homeRoute = '/home';
  static const String bookingRoute = '/booking';
  static const String profileRoute = '/profile';
  static const String historyRoute = '/history';
  static const String mastersRoute = '/masters';
  static const String servicesRoute = '/services';
  static const String loyaltyRoute = '/loyalty';
  static const String scheduleSettingsRoute = '/schedule-settings';
  
  // Error Messages
  static const String networkErrorMessage = 'Проблемы с интернет соединением';
  static const String serverErrorMessage = 'Ошибка сервера. Попробуйте позже';
  static const String unknownErrorMessage = 'Произошла неизвестная ошибка';
  static const String validationErrorMessage = 'Проверьте правильность данных';
  
  // Success Messages
  static const String bookingCreatedMessage = 'Запись успешно создана';
  static const String bookingCancelledMessage = 'Запись отменена';
  static const String profileUpdatedMessage = 'Профиль обновлен';
}
