import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointments_provider.dart';
import '../../../data/models/appointment.dart';
import '../schedule/staff_schedule_page.dart';
import '../schedule/widgets/appointment_details_bottom_sheet.dart';
import '../clients/staff_clients_page.dart';
import '../services/services_page.dart';
import '../profile/staff_profile_page.dart';
import '../booking/add_booking_page.dart';
import '../../widgets/modern_app_header.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;

    // Если профиль еще не загружен, показываем загрузку
    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Определяем интерфейс в зависимости от роли
    if (profile.isStaff) {
      return _StaffInterface(
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
        profile: profile,
      );
    } else {
      return _ClientInterface(
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
      );
    }
  }
}

// Интерфейс для клиентов
class _ClientInterface extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const _ClientInterface({
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _ClientHomeTab(),
      const _BookingTab(),
      const _HistoryTab(),
      const _ClientProfileTab(),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onIndexChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Запись',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'История',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

// Интерфейс для сотрудников
class _StaffInterface extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final dynamic profile;

  const _StaffInterface({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _StaffHomeTab(
        profile: profile,
        onTabChanged: onIndexChanged,
      ),
      const StaffSchedulePage(),
      const StaffClientsPage(),
      const ServicesPage(),
      const StaffProfilePage(),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onIndexChanged,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Панель',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Клиенты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services_outlined),
            activeIcon: Icon(Icons.design_services),
            label: 'Услуги',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class _ClientHomeTab extends StatelessWidget {
  const _ClientHomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WelcomeAppHeader(
        greeting: 'Добро пожаловать в',
        userName: 'XSalon',
        subtitle: 'Запишитесь на услуги в лучших салонах города',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Quick Actions
            Text(
              'Быстрые действия',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.calendar_today,
                    title: 'Записаться',
                    subtitle: 'На услугу',
                    onTap: () => context.go(AppConstants.clientBookingRoute),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.card_giftcard,
                    title: 'Бонусы',
                    subtitle: 'Программа',
                    onTap: () => context.go(AppConstants.loyaltyRoute),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Bookings
            Text(
              'Последние записи',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            const _RecentBookingCard(),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
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
      ),
    );
  }
}

class _RecentBookingCard extends StatelessWidget {
  const _RecentBookingCard();

  @override
  Widget build(BuildContext context) {
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
                  Icons.history,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Последние записи',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.content_cut, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Женская стрижка',
                      style: AppTheme.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Мастер Анна • 25 дек, 14:00',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Завершено',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingTab extends StatelessWidget {
  const _BookingTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись на услугу'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Записаться на услугу',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Выберите услугу, мастера и удобное время',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(AppConstants.clientBookingRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Начать запись',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('История записей'),
      ),
    );
  }
}



// Главная страница для сотрудников
class _StaffHomeTab extends StatelessWidget {
  final dynamic profile;
  final ValueChanged<int> onTabChanged;

  const _StaffHomeTab({
    required this.profile,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WelcomeAppHeader(
        greeting: profile.isMaster ? 'Добро пожаловать' : 'Добро пожаловать',
        userName: profile.fullName ?? 'Сотрудник',
        subtitle: profile.isMaster 
            ? 'Мастер салона'
            : 'Администратор салона',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Today's Stats
            Text(
              'Сегодня',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            _TodayStatsRow(onTabChanged: onTabChanged),
            
            const SizedBox(height: 24),
            
            // Quick Actions for Staff
            Text(
              'Быстрые действия',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _StaffActionCard(
                    icon: Icons.add_circle,
                    title: 'Новая запись',
                    subtitle: 'Добавить',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddBookingPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StaffActionCard(
                    icon: Icons.schedule,
                    title: 'Расписание',
                    subtitle: 'Настроить',
                    onTap: () => context.go(AppConstants.scheduleSettingsRoute),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Today's Appointments
            Text(
              'Записи на сегодня',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            const _TodayAppointmentsList(),
          ],
        ),
      ),
    );
  }
}





// Строка статистики на сегодня
class _TodayStatsRow extends ConsumerWidget {
  final ValueChanged<int> onTabChanged;

  const _TodayStatsRow({required this.onTabChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(appointmentsProvider);
    
    // Подсчитываем записи на сегодня
    final todayAppointments = appointmentsState.appointments
        .where((appointment) => _isSameDay(appointment.startTime, DateTime.now()))
        .toList();
    
    // Подсчитываем доход на сегодня
    final todayRevenue = todayAppointments
        .where((appointment) => appointment.status == AppointmentStatus.completed)
        .fold<double>(0, (sum, appointment) => sum + appointment.price);

    return Row(
      children: [
        Expanded(
          child: _StatsCard(
            icon: Icons.event,
            title: todayAppointments.length.toString(),
            subtitle: 'Записей',
            color: Colors.blue,
            onTap: () => onTabChanged(1), // Переход на таб "Расписание"
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatsCard(
            icon: Icons.attach_money,
            title: todayRevenue > 0 ? '₽${_formatPrice(todayRevenue)}' : '₽0',
            subtitle: 'Доход',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    } else {
      return price.toInt().toString();
    }
  }
}

// Карточка статистики
class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _StatsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

// Карточка действия для сотрудников
class _StaffActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StaffActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
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
      ),
    );
  }
}

// Список записей на сегодня
class _TodayAppointmentsList extends ConsumerStatefulWidget {
  const _TodayAppointmentsList();

  @override
  ConsumerState<_TodayAppointmentsList> createState() => _TodayAppointmentsListState();
}

class _TodayAppointmentsListState extends ConsumerState<_TodayAppointmentsList> {
  @override
  void initState() {
    super.initState();
    // Загружаем записи на сегодня при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentsProvider.notifier).loadAppointmentsForDate(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsState = ref.watch(appointmentsProvider);
    
    if (appointmentsState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (appointmentsState.errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Ошибка загрузки записей',
                style: AppTheme.titleSmall,
              ),
              Text(
                appointmentsState.errorMessage!,
                style: AppTheme.bodySmall.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final todayAppointments = appointmentsState.appointments
        .where((appointment) => _isSameDay(appointment.startTime, DateTime.now()))
        .toList();

    if (todayAppointments.isEmpty) {
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
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_available,
                color: Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Нет записей на сегодня',
              style: AppTheme.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            Text(
              'Сегодня у вас свободный день',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddBookingPage(),
                    ),
                  ).then((result) {
                    if (result == true) {
                      // Запись была создана, перезагружаем данные
                      ref.read(appointmentsProvider.notifier).loadAppointmentsForDate(DateTime.now());
                    }
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  'Добавить запись',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: todayAppointments
          .map((appointment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TodayAppointmentCard(
                  appointment: appointment,
                  onAppointmentUpdated: () {
                    // Перезагружаем записи после изменения
                    ref.read(appointmentsProvider.notifier).loadAppointmentsForDate(DateTime.now());
                  },
                ),
              ))
          .toList(),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

// Карточка записи на сегодня
class _TodayAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onAppointmentUpdated;
  
  const _TodayAppointmentCard({
    required this.appointment,
    this.onAppointmentUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = '${_formatTime(appointment.startTime)} - ${_formatTime(appointment.endTime)}';
    
    return Container(
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
      child: InkWell(
        onTap: () => _showAppointmentDetails(context, appointment),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeFormat,
                      style: AppTheme.titleSmall.copyWith(
                        color: _getStatusColor(appointment.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.serviceName,
                      style: AppTheme.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      '${appointment.clientName} • ${appointment.clientPhone}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(appointment.status),
                  style: AppTheme.bodySmall.copyWith(
                    color: _getStatusColor(appointment.status),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) => AppointmentDetailsBottomSheet(
          appointment: appointment,
        ),
      ),
    ).then((_) {
      // После закрытия модального окна обновляем данные
      if (onAppointmentUpdated != null) {
        onAppointmentUpdated!();
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.inProgress:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.purple;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Ожидает';
      case AppointmentStatus.confirmed:
        return 'Подтверждено';
      case AppointmentStatus.inProgress:
        return 'В процессе';
      case AppointmentStatus.completed:
        return 'Завершено';
      case AppointmentStatus.cancelled:
        return 'Отменено';
      case AppointmentStatus.noShow:
        return 'Не пришел';
    }
  }
}

// Простой профиль для клиентов
class _ClientProfileTab extends StatelessWidget {
  const _ClientProfileTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Профиль клиента',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Здесь будет профиль клиента',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
