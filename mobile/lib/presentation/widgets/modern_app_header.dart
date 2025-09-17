import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ModernAppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showProfile;
  final bool showNotifications;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final Color? backgroundColor;
  final bool centerTitle;

  const ModernAppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showProfile = true,
    this.showNotifications = true,
    this.onProfileTap,
    this.onNotificationTap,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;
    
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Leading button
              if (context.canPop())
                Container(
                  margin: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderColor,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.textPrimaryColor,
                          size: 18,
                        ),
                      ),
                    onPressed: () {
                      try {
                        if (context.canPop()) {
                          context.pop();
                        }
                      } catch (e) {
                        // Если не можем вернуться назад, ничего не делаем
                        debugPrint('Cannot pop: $e');
                      }
                    },
                  ),
                ),
              
              // Title section
              Expanded(
                child: Column(
                  crossAxisAlignment: centerTitle 
                    ? CrossAxisAlignment.center 
                    : CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        fontSize: 24,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actions != null) ...actions!,
                  
                  // Уведомления
                  if (showNotifications)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppTheme.borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: AppTheme.textSecondaryColor,
                                size: 20,
                              ),
                            ),
                            onPressed: onNotificationTap ?? () {
                              // TODO: Implement notifications
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Уведомления будут доступны скоро'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          // Индикатор новых уведомлений
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Профиль пользователя
                  if (showProfile && profile != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: onProfileTap ?? () {
                          // TODO: Navigate to profile
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: AppTheme.borderColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.transparent,
                            child: profile.avatarUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(
                                    profile.avatarUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar(profile);
                                    },
                                  ),
                                )
                              : _buildDefaultAvatar(profile),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(dynamic profile) {
    final initials = _getInitials(profile.fullName ?? profile.email ?? 'U');
    // Определяем размер на основе контекста использования
    final isWelcomeHeader = this is WelcomeAppHeader;
    final size = isWelcomeHeader ? 52.0 : 40.0;
    final radius = size / 2;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          initials,
          style: (isWelcomeHeader ? AppTheme.titleMedium : AppTheme.labelLarge).copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }


  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return 'U';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}

// Специализированный header для главной страницы с приветствием
class WelcomeAppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String greeting;
  final String? userName;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const WelcomeAppHeader({
    super.key,
    required this.greeting,
    this.userName,
    this.subtitle,
    this.actions,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;
    
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Приветствие и информация о пользователе
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      greeting,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName ?? profile?.fullName ?? 'Пользователь',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions и профиль
              Row(
                children: [
                  if (actions != null) ...actions!,
                  
                  // Уведомления
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: AppTheme.textSecondaryColor,
                              size: 22,
                            ),
                          ),
                          onPressed: onNotificationTap ?? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Уведомления будут доступны скоро'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        // Индикатор новых уведомлений
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Профиль пользователя
                  if (profile != null)
                    GestureDetector(
                      onTap: onProfileTap ?? () {
                        // TODO: Navigate to profile
                      },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppTheme.borderColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.transparent,
                            child: profile.avatarUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: Image.network(
                                    profile.avatarUrl!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar(profile);
                                    },
                                  ),
                                )
                              : _buildDefaultAvatar(profile),
                          ),
                        ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(dynamic profile) {
    final initials = _getInitials(profile.fullName ?? profile.email ?? 'U');
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTheme.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return 'U';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
