import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/client.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/client_profile_provider.dart';
import '../../widgets/modern_app_header.dart';
import 'widgets/edit_profile_bottom_sheet.dart';

class ClientProfilePage extends ConsumerStatefulWidget {
  const ClientProfilePage({super.key});

  @override
  ConsumerState<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends ConsumerState<ClientProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final clientProfileState = ref.watch(currentClientProfileProvider);

    if (authState.profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (clientProfileState.status == ClientProfileStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (clientProfileState.status == ClientProfileStatus.error) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.alertCircle,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки профиля',
                style: AppTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                clientProfileState.errorMessage ?? 'Неизвестная ошибка',
                style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(clientProfileProvider.notifier)
                      .loadClientProfile(authState.user!.id);
                },
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final userProfile = authState.profile!;
    final client = clientProfileState.client;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Мой профиль',
          style: AppTheme.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _showEditProfile,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  LucideIcons.edit,
                  color: AppTheme.textSecondaryColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          _buildProfileHeader(userProfile, client),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              labelStyle: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: AppTheme.bodyMedium,
              tabs: const [
                Tab(text: 'Профиль'),
                Tab(text: 'История'),
                Tab(text: 'Настройки'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(userProfile, client),
                _buildHistoryTab(clientProfileState.appointments),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile userProfile, Client? client) {
    final stats = ref.watch(clientStatsProvider);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: userProfile.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Image.network(
                          userProfile.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          _getInitials(userProfile.displayName),
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 20),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.displayName,
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (userProfile.phone != null)
                      Text(
                        userProfile.phone!,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (client?.loyaltyLevel == 'VIP')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'VIP',
                              style: AppTheme.labelSmall.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (client?.loyaltyLevel == 'VIP')
                          const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            client?.loyaltyLevel ?? 'Новичок',
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
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
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  LucideIcons.calendar,
                  '${stats['totalVisits'] ?? 0}',
                  'визитов',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildQuickStat(
                  LucideIcons.gift,
                  '${stats['loyaltyPoints'] ?? 0}',
                  'бонусов',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildQuickStat(
                  LucideIcons.clock,
                  '${stats['upcomingAppointments'] ?? 0}',
                  'записей',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileTab(UserProfile userProfile, Client? client) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information
          _buildContactInfo(userProfile),
          const SizedBox(height: 16),
          
          // Personal Information
          _buildPersonalInfo(userProfile),
          const SizedBox(height: 16),
          
          // Loyalty Information
          if (client != null)
            _buildLoyaltyInfo(client),
        ],
      ),
    );
  }

  Widget _buildContactInfo(UserProfile userProfile) {
    return _buildSection(
      'Контактная информация',
      LucideIcons.phone,
      [
        if (userProfile.phone != null)
          _buildInfoRow(LucideIcons.phone, 'Телефон', userProfile.phone!),
        if (userProfile.email != null)
          _buildInfoRow(LucideIcons.mail, 'Email', userProfile.email!),
      ],
    );
  }

  Widget _buildPersonalInfo(UserProfile userProfile) {
    return _buildSection(
      'Личная информация',
      LucideIcons.userCheck,
      [
        if (userProfile.fullName != null)
          _buildInfoRow(LucideIcons.user, 'Имя', userProfile.fullName!),
        if (userProfile.dateOfBirth != null)
          _buildInfoRow(
            LucideIcons.cake,
            'Дата рождения',
            _formatDate(userProfile.dateOfBirth!),
          ),
        if (userProfile.gender != null)
          _buildInfoRow(LucideIcons.user, 'Пол', userProfile.gender!),
      ],
    );
  }

  Widget _buildLoyaltyInfo(Client client) {
    final stats = ref.watch(clientStatsProvider);
    
    return _buildSection(
      'Программа лояльности',
      LucideIcons.gift,
      [
        _buildInfoRow(
          LucideIcons.star,
          'Уровень',
          client.loyaltyLevel,
        ),
        _buildInfoRow(
          LucideIcons.gift,
          'Бонусные баллы',
          '${client.loyaltyPoints}',
        ),
        _buildInfoRow(
          LucideIcons.dollarSign,
          'Потрачено всего',
          _formatPrice(stats['totalSpent'] ?? 0.0),
        ),
        if (stats['lastVisit'] != null)
          _buildInfoRow(
            LucideIcons.calendarCheck,
            'Последний визит',
            _formatDate(stats['lastVisit']),
          ),
      ],
    );
  }

  Widget _buildHistoryTab(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  LucideIcons.clock,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'История пуста',
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ваши записи будут отображаться здесь',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push(AppConstants.clientBookingRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Записаться на услугу'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildHistoryItem(appointment);
      },
    );
  }

  Widget _buildHistoryItem(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Expanded(
                child: Text(
                  appointment.serviceName,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment.status.displayName,
                  style: AppTheme.labelSmall.copyWith(
                    color: _getStatusColor(appointment.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDateTime(appointment.startTime),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const Spacer(),
              Text(
                _formatPrice(appointment.price),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (appointment.masterName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  LucideIcons.user,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Мастер: ${appointment.masterName}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Настройки аккаунта',
            LucideIcons.settings,
            [
              _buildSettingsItem(
                LucideIcons.edit,
                'Редактировать профиль',
                'Изменить личные данные',
                onTap: _showEditProfile,
              ),
              _buildSettingsItem(
                LucideIcons.bell,
                'Уведомления',
                'Настроить уведомления',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('В разработке')),
                  );
                },
              ),
              _buildSettingsItem(
                LucideIcons.shield,
                'Безопасность',
                'Настройки безопасности',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('В разработке')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Приложение',
            LucideIcons.smartphone,
            [
              _buildSettingsItem(
                LucideIcons.helpCircle,
                'Помощь и поддержка',
                'Часто задаваемые вопросы',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('В разработке')),
                  );
                },
              ),
              _buildSettingsItem(
                LucideIcons.info,
                'О приложении',
                'Версия ${AppConstants.appVersion}',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('XSalon v${AppConstants.appVersion}')),
                  );
                },
              ),
              _buildSettingsItem(
                LucideIcons.logOut,
                'Выйти из аккаунта',
                'Завершить сеанс',
                isDestructive: true,
                onTap: _showLogoutDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? Colors.red : AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : AppTheme.textPrimaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfile() {
    final authState = ref.read(authProvider);
    if (authState.profile == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileBottomSheet(
        userProfile: authState.profile!,
        onProfileUpdated: (updatedProfile) {
          ref.read(clientProfileProvider.notifier)
              .updateUserProfile(updatedProfile);
          ref.read(authProvider.notifier).initialize(); // Обновляем auth state
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта'),
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

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} в ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
    }
    return '${price.toInt()} сум';
  }
}
