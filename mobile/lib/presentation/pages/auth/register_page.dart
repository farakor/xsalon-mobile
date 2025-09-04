import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Страница регистрации',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              'В разработке...',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppConstants.loginRoute),
        label: const Text('К входу'),
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }
}
