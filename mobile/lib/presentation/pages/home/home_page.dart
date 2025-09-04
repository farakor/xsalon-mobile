import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../schedule/staff_schedule_page.dart';
import '../clients/staff_clients_page.dart';
import '../services/services_page.dart';
import '../profile/staff_profile_page.dart';
import '../booking/add_booking_page.dart';

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
      appBar: AppBar(
        title: const Text('XSalon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Добро пожаловать!',
                    style: AppTheme.titleLarge.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Запишитесь на услуги в лучших салонах города',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
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
                    onTap: () => context.go(AppConstants.bookingRoute),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.people,
                    title: 'Мастера',
                    subtitle: 'Выбрать',
                    onTap: () => context.go(AppConstants.mastersRoute),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.design_services,
                    title: 'Услуги',
                    subtitle: 'Каталог',
                    onTap: () => context.go(AppConstants.servicesRoute),
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTheme.titleSmall,
              ),
              Text(
                subtitle,
                style: AppTheme.bodySmall,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.content_cut, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Женская стрижка',
                        style: AppTheme.titleSmall,
                      ),
                      Text(
                        'Мастер Анна • 25 дек, 14:00',
                        style: AppTheme.bodySmall,
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
      ),
    );
  }
}

class _BookingTab extends StatelessWidget {
  const _BookingTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Страница записи'),
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
      appBar: AppBar(
        title: Text('Панель ${profile.isMaster ? 'мастера' : 'администратора'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card for Staff
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Добро пожаловать, ${profile.fullName ?? 'Сотрудник'}!',
                    style: AppTheme.titleLarge.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.isMaster 
                        ? 'Управляйте своими записями и клиентами'
                        : 'Управляйте салоном и персоналом',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Today's Stats
            Text(
              'Сегодня',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _StatsCard(
                    icon: Icons.event,
                    title: '8',
                    subtitle: 'Записей',
                    color: Colors.blue,
                    onTap: () => onTabChanged(1), // Переход на таб "Расписание"
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatsCard(
                    icon: Icons.attach_money,
                    title: '₽12,500',
                    subtitle: 'Доход',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            
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
            
            const _TodayAppointmentCard(),
            const SizedBox(height: 12),
            const _TodayAppointmentCard(),
          ],
        ),
      ),
    );
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(color: color),
              ),
              Text(
                subtitle,
                style: AppTheme.bodySmall,
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTheme.titleSmall,
              ),
              Text(
                subtitle,
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Карточка записи на сегодня
class _TodayAppointmentCard extends StatelessWidget {
  const _TodayAppointmentCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '14:00 - 15:30',
                    style: AppTheme.titleSmall.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Женская стрижка',
                    style: AppTheme.titleSmall,
                  ),
                  Text(
                    'Анна Иванова • +998 90 123 45 67',
                    style: AppTheme.bodySmall,
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
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Подтверждено',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
