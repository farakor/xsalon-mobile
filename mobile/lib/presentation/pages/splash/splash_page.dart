import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/config/supabase_config.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeApp();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.longAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Инициализация Supabase
      await SupabaseConfig.initialize();
      
      // Инициализация провайдера аутентификации
      ref.read(authProvider.notifier).initialize();
      
      // Минимальное время показа splash
      await Future.delayed(const Duration(seconds: 2));
      
      final session = SupabaseConfig.auth.currentSession;
      
      if (mounted) {
        if (session != null) {
          // Пользователь авторизован
          context.go(AppConstants.homeRoute);
        } else {
          // Пользователь не авторизован
          context.go(AppConstants.authRoute);
        }
      }
    } catch (error) {
      // В случае ошибки переходим на страницу авторизации
      if (mounted) {
        context.go(AppConstants.authRoute);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Логотип приложения
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.content_cut,
                          size: 60,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Название приложения
                      Text(
                        AppConstants.appName,
                        style: AppTheme.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Подзаголовок
                      Text(
                        'Салон красоты в вашем кармане',
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      
                      const SizedBox(height: 64),
                      
                      // Индикатор загрузки
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.white,
                        size: 40,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Загрузка...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
