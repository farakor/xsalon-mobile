import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final dynamic profile;

  const ProfileHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar and Basic Info
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: profile.avatarUrl != null 
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? Text(
                            _getInitials(profile.fullName ?? 'Сотрудник'),
                            style: AppTheme.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _getStatusIcon(),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName ?? 'Сотрудник',
                      style: AppTheme.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRoleDisplayName(profile.role),
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Верифицированный сотрудник',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Achievement Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAchievementBadge(
                Icons.star,
                'Топ мастер',
                'Высокий рейтинг',
              ),
              _buildAchievementBadge(
                Icons.favorite,
                'Любимец клиентов',
                '90% повторных записей',
              ),
              _buildAchievementBadge(
                Icons.trending_up,
                'Растущий доход',
                '+25% за месяц',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'master':
        return 'Мастер';
      case 'admin':
        return 'Администратор';
      case 'owner':
        return 'Владелец';
      default:
        return 'Сотрудник';
    }
  }

  Color _getStatusColor() {
    // В реальном приложении статус может зависеть от различных факторов
    return Colors.green; // Онлайн/Активен
  }

  IconData _getStatusIcon() {
    return Icons.check; // Активен
  }
}
