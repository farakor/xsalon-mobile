import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_button.dart';

class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              const Spacer(),
              
              // Логотип и название
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добро пожаловать!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Кнопки выбора типа входа
              Column(
                children: [
                  // Вход для клиентов
                  CustomButton(
                    text: 'Я клиент',
                    onPressed: () => context.go(AppConstants.phoneAuthRoute),
                    backgroundColor: AppTheme.primaryColor,
                    textColor: Colors.white,
                    icon: Icons.person,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Вход для сотрудников
                  CustomButton(
                    text: 'Я сотрудник салона',
                    onPressed: () => context.go(AppConstants.staffLoginRoute),
                    backgroundColor: Colors.white,
                    textColor: AppTheme.primaryColor,
                    borderColor: AppTheme.primaryColor,
                    icon: Icons.work,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Информационный текст
              Text(
                'Выберите тип входа для продолжения',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
