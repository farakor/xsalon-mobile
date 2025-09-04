import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Removed form_builder dependencies for MVP

import '../../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
// Removed custom_text_field import for MVP
import '../../widgets/common/custom_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        final email = _emailController.text;
        final password = _passwordController.text;
        
        // TODO: Implement login logic with Supabase
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        
        if (mounted) {
          context.go(AppConstants.homeRoute);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка входа: ${error.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.content_cut,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Добро пожаловать!',
                      style: AppTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Войдите в свой аккаунт',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Введите ваш email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Поле обязательно для заполнения';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Введите корректный email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        hintText: 'Введите ваш пароль',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Поле обязательно для заполнения';
                        }
                        if (value.length < AppConstants.minPasswordLength) {
                          return 'Минимум ${AppConstants.minPasswordLength} символов';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Login Button
                    CustomButton(
                      text: 'Войти',
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: const Text('Забыли пароль?'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'или',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Нет аккаунта? ',
                    style: AppTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      context.go(AppConstants.registerRoute);
                    },
                    child: const Text('Зарегистрироваться'),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
