import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/staff_statistics.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/statistics_section.dart';
import 'widgets/settings_section.dart';

class StaffProfilePage extends ConsumerStatefulWidget {
  const StaffProfilePage({super.key});

  @override
  ConsumerState<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends ConsumerState<StaffProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Тестовые данные статистики
  StaffStatistics get _mockStatistics => StaffStatistics(
    totalAppointments: 156,
    completedAppointments: 142,
    cancelledAppointments: 8,
    totalRevenue: 2850000,
    averageRating: 4.8,
    totalClients: 89,
    repeatClients: 67,
    serviceStats: {
      'Женская стрижка': 45,
      'Окрашивание волос': 32,
      'Укладка': 28,
      'Маникюр': 25,
      'Косметология': 15,
      'Массаж': 11,
    },
    monthlyRevenue: {
      'Январь': 420000,
      'Февраль': 380000,
      'Март': 450000,
      'Апрель': 520000,
      'Май': 480000,
      'Июнь': 600000,
    },
    periodStart: DateTime.now().subtract(const Duration(days: 180)),
    periodEnd: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;

    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
            tooltip: 'Редактировать профиль',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'help':
                  _showHelp();
                  break;
                case 'about':
                  _showAbout();
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 8),
                    Text('Помощь'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('О приложении'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Выйти'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Профиль', icon: Icon(Icons.person)),
            Tab(text: 'Статистика', icon: Icon(Icons.analytics)),
            Tab(text: 'Настройки', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(profile),
          _buildStatisticsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab(dynamic profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          ProfileHeader(profile: profile),
          const SizedBox(height: 24),
          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 24),
          // Profile Information
          _buildProfileInfo(profile),
          const SizedBox(height: 24),
          // Working Hours
          _buildWorkingHours(),
          const SizedBox(height: 24),
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return StatisticsSection(statistics: _mockStatistics);
  }

  Widget _buildSettingsTab() {
    return const SettingsSection();
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Быстрая статистика',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatItem(
                  'Записей сегодня',
                  '8',
                  Icons.event,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatItem(
                  'Рейтинг',
                  '${_mockStatistics.averageRating}',
                  Icons.star,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatItem(
                  'Доход за месяц',
                  _formatPrice(_mockStatistics.monthlyRevenue.values.last),
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatItem(
                  'Клиентов',
                  '${_mockStatistics.totalClients}',
                  Icons.people,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Информация о профиле',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email, 'Email', profile.email ?? 'Не указан'),
          _buildInfoRow(Icons.phone, 'Телефон', profile.phone ?? 'Не указан'),
          _buildInfoRow(Icons.work, 'Роль', _getRoleDisplayName(profile.role)),
          _buildInfoRow(Icons.business, 'Организация', 'Beauty Studio Элегант'),
          _buildInfoRow(Icons.calendar_today, 'Дата регистрации', _formatDate(profile.createdAt)),
          if (profile.lastLoginAt != null)
            _buildInfoRow(Icons.login, 'Последний вход', _formatDateTime(profile.lastLoginAt)),
        ],
      ),
    );
  }

  Widget _buildWorkingHours() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Рабочие часы',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _editWorkingHours,
                child: const Text('Изменить'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWorkingDayRow('Понедельник', '09:00 - 18:00'),
          _buildWorkingDayRow('Вторник', '09:00 - 18:00'),
          _buildWorkingDayRow('Среда', '09:00 - 18:00'),
          _buildWorkingDayRow('Четверг', '09:00 - 18:00'),
          _buildWorkingDayRow('Пятница', '09:00 - 18:00'),
          _buildWorkingDayRow('Суббота', '10:00 - 16:00'),
          _buildWorkingDayRow('Воскресенье', 'Выходной', isWorking: false),
        ],
      ),
    );
  }

  Widget _buildWorkingDayRow(String day, String hours, {bool isWorking = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            hours,
            style: AppTheme.bodyMedium.copyWith(
              color: isWorking ? Colors.grey[700] : Colors.grey[500],
              fontStyle: isWorking ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit),
            label: const Text('Редактировать профиль'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.lock),
                label: const Text('Сменить пароль'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportData,
                icon: const Icon(Icons.download),
                label: const Text('Экспорт данных'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Выйти из аккаунта'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} в ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Редактирование профиля - в разработке')),
    );
  }

  void _editWorkingHours() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Изменение рабочих часов - в разработке')),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Смена пароля - в разработке')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Экспорт данных - в разработке')),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Помощь'),
        content: const Text(
          'Если у вас возникли вопросы, обратитесь к администратору салона или в службу поддержки.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('XSalon - приложение для управления салоном красоты'),
            SizedBox(height: 8),
            Text('Версия: 1.0.0'),
            Text('Разработчик: XSalon Team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
