import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/app_router.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Настройка системного UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Блокировка поворота экрана (только портретная ориентация)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: XSalonApp(),
    ),
  );
}

class XSalonApp extends ConsumerWidget {
  const XSalonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'XSalon',
      debugShowCheckedModeBanner: false,
      
      // Тема приложения
      theme: AppTheme.lightTheme,
      
      // Роутинг
      routerConfig: router,
      
      // Локализация
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('uz', 'UZ'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ru', 'RU'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Настройки приложения
      builder: (context, child) {
        return MediaQuery(
          // Отключаем масштабирование шрифтов системой
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}