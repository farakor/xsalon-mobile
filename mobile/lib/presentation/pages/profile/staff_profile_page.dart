import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/services/schedule_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_statistics_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/statistics_section.dart';
import 'widgets/settings_section.dart';
import 'widgets/quick_statistics_widget.dart';

class StaffProfilePage extends ConsumerStatefulWidget {
  const StaffProfilePage({super.key});

  @override
  ConsumerState<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends ConsumerState<StaffProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScheduleService _scheduleService = ScheduleService();
  List<MasterSchedule> _masterSchedules = [];
  bool _isLoadingSchedule = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMasterSchedule();
  }

  Future<void> _loadMasterSchedule() async {
    try {
      setState(() => _isLoadingSchedule = true);
      
      final masterId = await _scheduleService.getCurrentMasterId();
      if (masterId != null) {
        final schedules = await _scheduleService.getMasterSchedule(masterId);
        setState(() => _masterSchedules = schedules);
      }
    } catch (e) {
      print('Error loading master schedule: $e');
    } finally {
      setState(() => _isLoadingSchedule = false);
    }
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
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Unified Header with Profile and Tabs
          _buildUnifiedHeader(profile),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(profile),
                _buildStatisticsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedHeader(dynamic profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with title and menu
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  Text(
                    'Профиль',
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.moreVertical,
                        color: AppTheme.textSecondaryColor,
                        size: 18,
                      ),
                    ),
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
                            Icon(LucideIcons.helpCircle),
                            SizedBox(width: 8),
                            Text('Помощь'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'about',
                        child: Row(
                          children: [
                            Icon(LucideIcons.info),
                            SizedBox(width: 8),
                            Text('О приложении'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(LucideIcons.logOut, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Выйти'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Profile Info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: ProfileHeader(profile: profile),
            ),
            // Tab Bar
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
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
                labelColor: Colors.black,
                unselectedLabelColor: AppTheme.textSecondaryColor,
                labelStyle: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: AppTheme.bodyMedium,
                tabs: const [
                  Tab(text: 'Профиль'),
                  Tab(text: 'Статистика'),
                  Tab(text: 'Настройки'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(dynamic profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          // Quick Stats (сохраняем оригинальный стиль)
          const QuickStatisticsWidget(),
          const SizedBox(height: 20),
          // Profile Information
          _buildProfileInfo(profile),
          const SizedBox(height: 16),
          // Working Hours
          _buildWorkingHours(),
          const SizedBox(height: 16),
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final statisticsAsync = ref.watch(staffStatisticsProvider);
        
        return statisticsAsync.when(
          data: (statistics) => StatisticsSection(statistics: statistics),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки статистики',
                    style: AppTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Попробуйте обновить страницу',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return const SettingsSection();
  }



  Widget _buildProfileInfo(dynamic profile) {
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
                  LucideIcons.info,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Информация о профиле',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.mail, 'Email', profile.email ?? 'Не указан'),
          _buildInfoRow(LucideIcons.phone, 'Телефон', profile.phone ?? 'Не указан'),
          _buildInfoRow(LucideIcons.briefcase, 'Роль', _getRoleDisplayName(profile.role)),
          _buildInfoRow(LucideIcons.building, 'Организация', 'Beauty Studio Элегант'),
          _buildInfoRow(LucideIcons.calendarDays, 'Дата регистрации', _formatDate(profile.createdAt)),
          if (profile.lastLoginAt != null)
            _buildInfoRow(LucideIcons.logIn, 'Последний вход', _formatDateTime(profile.lastLoginAt)),
        ],
      ),
    );
  }

  Widget _buildWorkingHours() {
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
                  LucideIcons.calendarCheck,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Рабочие часы',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: _editWorkingHours,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Изменить',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingSchedule)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ..._buildWorkingDaysFromSchedule(),
        ],
      ),
    );
  }

  Widget _buildWorkingDayRow(String day, String hours, {bool isWorking = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            day,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
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
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(LucideIcons.logOut, color: Colors.red, size: 18),
            label: Text(
              'Выйти из аккаунта',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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

  String _formatTimeWithoutSeconds(String time) {
    // Убираем секунды из времени (например, "09:00:00" -> "09:00")
    if (time.contains(':')) {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
    }
    return time;
  }


  List<Widget> _buildWorkingDaysFromSchedule() {
    // Порядок дней недели для отображения
    const daysOrder = [
      'monday', 'tuesday', 'wednesday', 'thursday', 
      'friday', 'saturday', 'sunday'
    ];
    
    const dayNames = {
      'monday': 'Понедельник',
      'tuesday': 'Вторник', 
      'wednesday': 'Среда',
      'thursday': 'Четверг',
      'friday': 'Пятница',
      'saturday': 'Суббота',
      'sunday': 'Воскресенье',
    };

    if (_masterSchedules.isEmpty) {
      // Показываем стандартное расписание, если данных нет
      return [
        _buildWorkingDayRow('Понедельник', '09:00 - 18:00'),
        _buildWorkingDayRow('Вторник', '09:00 - 18:00'),
        _buildWorkingDayRow('Среда', '09:00 - 18:00'),
        _buildWorkingDayRow('Четверг', '09:00 - 18:00'),
        _buildWorkingDayRow('Пятница', '09:00 - 18:00'),
        _buildWorkingDayRow('Суббота', '10:00 - 16:00'),
        _buildWorkingDayRow('Воскресенье', 'Выходной', isWorking: false),
      ];
    }

    // Создаем карту расписания для быстрого поиска
    final scheduleMap = <String, MasterSchedule>{};
    for (final schedule in _masterSchedules) {
      scheduleMap[schedule.dayOfWeek] = schedule;
    }

    // Строим виджеты для каждого дня
    return daysOrder.map((englishDay) {
      final dayName = dayNames[englishDay]!;
      final schedule = scheduleMap[englishDay];
      
      if (schedule == null || !schedule.isWorking) {
        return _buildWorkingDayRow(dayName, 'Выходной', isWorking: false);
      }
      
      final startTime = _formatTimeWithoutSeconds(schedule.startTime ?? '09:00');
      final endTime = _formatTimeWithoutSeconds(schedule.endTime ?? '18:00');
      final hours = '$startTime - $endTime';
      
      return _buildWorkingDayRow(dayName, hours, isWorking: true);
    }).toList();
  }

  void _editWorkingHours() {
    // Навигация к экрану настроек расписания
    context.push(AppConstants.scheduleSettingsRoute).then((_) {
      // Обновляем данные после возврата с экрана настроек
      _loadMasterSchedule();
    });
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.logOut,
                color: Colors.red,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Выход из аккаунта',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Вы уверены, что хотите выйти из аккаунта?',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Отмена',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Сохраняем ссылку на GoRouter перед любыми операциями
              final router = GoRouter.of(context);
              
              Navigator.of(context).pop(); // Закрываем диалог подтверждения
              
              try {
                // Выполняем выход из аккаунта
                await ref.read(authProvider.notifier).signOut();
                
                // Ждем, пока состояние действительно изменится
                int attempts = 0;
                while (attempts < 10) {
                  await Future.delayed(const Duration(milliseconds: 100));
                  final authState = ref.read(authProvider);
                  print('Попытка $attempts: состояние ${authState.status}');
                  
                  if (authState.status == AuthStatus.unauthenticated) {
                    print('Состояние изменилось, переходим на экран авторизации');
                    break;
                  }
                  attempts++;
                }
                
                // Перенаправление на экран авторизации используя сохраненную ссылку
                router.go(AppConstants.authRoute);
              } catch (error) {
                // Логируем ошибку, но не показываем пользователю
                print('Ошибка при выходе из аккаунта: $error');
                // В случае ошибки все равно пытаемся перейти на экран авторизации
                router.go(AppConstants.authRoute);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Выйти',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
