import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/auth/auth_selection_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/phone_auth_page.dart';
import '../../presentation/pages/auth/otp_verification_page.dart';
import '../../presentation/pages/auth/staff_login_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/booking/booking_page.dart';
import '../../presentation/pages/booking/client_booking_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/masters/masters_page.dart';
import '../../presentation/pages/services/services_page.dart';
import '../../presentation/pages/loyalty/loyalty_page.dart';
import '../../presentation/pages/schedule/schedule_settings_page.dart';
import '../constants/app_constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: AppConstants.authRoute,
        name: 'auth',
        builder: (context, state) => const AuthSelectionPage(),
      ),
      
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      GoRoute(
        path: AppConstants.phoneAuthRoute,
        name: 'phone_auth',
        builder: (context, state) => const PhoneAuthPage(),
      ),
      
      GoRoute(
        path: AppConstants.otpVerificationRoute,
        name: 'otp_verification',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OtpVerificationPage(phoneNumber: phoneNumber);
        },
      ),
      
      GoRoute(
        path: AppConstants.staffLoginRoute,
        name: 'staff_login',
        builder: (context, state) => const StaffLoginPage(),
      ),
      
      // Main App Routes
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      
      GoRoute(
        path: AppConstants.bookingRoute,
        name: 'booking',
        builder: (context, state) => const BookingPage(),
      ),
      
      GoRoute(
        path: AppConstants.clientBookingRoute,
        name: 'client_booking',
        builder: (context, state) => const ClientBookingPage(),
      ),
      
      GoRoute(
        path: AppConstants.profileRoute,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      
      GoRoute(
        path: AppConstants.historyRoute,
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      
      GoRoute(
        path: AppConstants.mastersRoute,
        name: 'masters',
        builder: (context, state) => const MastersPage(),
      ),
      
      GoRoute(
        path: AppConstants.servicesRoute,
        name: 'services',
        builder: (context, state) => const ServicesPage(),
      ),
      
      GoRoute(
        path: AppConstants.loyaltyRoute,
        name: 'loyalty',
        builder: (context, state) => const LoyaltyPage(),
      ),
      
      GoRoute(
        path: AppConstants.scheduleSettingsRoute,
        name: 'schedule_settings',
        builder: (context, state) => const ScheduleSettingsPage(),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Страница не найдена',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Путь: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
});
