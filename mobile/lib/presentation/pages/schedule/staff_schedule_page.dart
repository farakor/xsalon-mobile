import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/appointment.dart';
import '../../theme/app_theme.dart';
import '../../providers/appointments_provider.dart';
import 'widgets/day_schedule_view.dart';
import 'widgets/week_schedule_view.dart';
import 'widgets/month_schedule_view.dart';
import 'widgets/appointment_details_bottom_sheet.dart';
import '../booking/add_booking_page.dart';

enum ScheduleViewType { day, week, month }

class StaffSchedulePage extends ConsumerStatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  ConsumerState<StaffSchedulePage> createState() => _StaffSchedulePageState();
}

class _StaffSchedulePageState extends ConsumerState<StaffSchedulePage> {
  ScheduleViewType _currentView = ScheduleViewType.day;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Загружаем записи при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  void _loadAppointments() {
    switch (_currentView) {
      case ScheduleViewType.day:
        ref.read(appointmentsProvider.notifier).loadAppointmentsForDate(_selectedDate);
        break;
      case ScheduleViewType.week:
        final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        ref.read(appointmentsProvider.notifier).loadAppointmentsForDateRange(startOfWeek, endOfWeek);
        break;
      case ScheduleViewType.month:
        final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
        ref.read(appointmentsProvider.notifier).loadAppointmentsForDateRange(startOfMonth, endOfMonth);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar like Profile
          SliverToBoxAdapter(
            child: Container(
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
                    // Header with title and actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Row(
                        children: [
                          Text(
                            'Расписание',
                            style: AppTheme.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const Spacer(),
                          _buildHeaderActions(),
                        ],
                      ),
                    ),
                    
                    // View Selector (Tab Bar)
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _buildModernViewSelector(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Date Navigation
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildModernDateNavigation(),
            ),
          ),
          
          // Schedule Content
          SliverFillRemaining(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: _buildScheduleView(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search button
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
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
                LucideIcons.search,
                color: AppTheme.textSecondaryColor,
                size: 18,
              ),
            ),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ),
        
        // Menu button
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
              case 'today':
                setState(() {
                  _selectedDate = DateTime.now();
                });
                _loadAppointments();
                break;
              case 'refresh':
                _loadAppointments();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'today',
              child: Row(
                children: [
                  Icon(LucideIcons.calendar),
                  SizedBox(width: 8),
                  Text('Сегодня'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(LucideIcons.refreshCw),
                  SizedBox(width: 8),
                  Text('Обновить'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernViewSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildViewButton(
            'День',
            LucideIcons.calendar,
            ScheduleViewType.day,
            _currentView == ScheduleViewType.day,
          ),
          _buildViewButton(
            'Неделя',
            LucideIcons.calendar,
            ScheduleViewType.week,
            _currentView == ScheduleViewType.week,
          ),
          _buildViewButton(
            'Месяц',
            LucideIcons.calendar,
            ScheduleViewType.month,
            _currentView == ScheduleViewType.month,
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String label, IconData icon, ScheduleViewType type, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentView = type;
          });
          _loadAppointments();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : AppTheme.textSecondaryColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: isSelected ? Colors.black : AppTheme.textSecondaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDateNavigation() {
    String dateText;
    switch (_currentView) {
      case ScheduleViewType.day:
        dateText = _formatDateFull(_selectedDate);
        break;
      case ScheduleViewType.week:
        final weekStart = _getWeekStart(_selectedDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        dateText = '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
        break;
      case ScheduleViewType.month:
        dateText = _formatMonth(_selectedDate);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _previousPeriod,
              icon: const Icon(
                LucideIcons.chevronLeft,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      dateText,
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _nextPeriod,
              icon: const Icon(
                LucideIcons.chevronRight,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildScheduleView() {
    final appointmentsState = ref.watch(appointmentsProvider);
    
    // Показываем индикатор загрузки
    if (appointmentsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Показываем ошибку
    if (appointmentsState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              appointmentsState.errorMessage!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(appointmentsProvider.notifier).clearError();
                _loadAppointments();
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    
    final appointments = _getAppointmentsForCurrentView(appointmentsState.appointments);
    
    switch (_currentView) {
      case ScheduleViewType.day:
        return DayScheduleView(
          selectedDate: _selectedDate,
          appointments: appointments,
          onAppointmentTap: _onAppointmentTap,
        );
      case ScheduleViewType.week:
        return WeekScheduleView(
          selectedDate: _selectedDate,
          appointments: appointments,
          onAppointmentTap: _onAppointmentTap,
          onDateTap: _onDateTap,
        );
      case ScheduleViewType.month:
        return MonthScheduleView(
          selectedDate: _selectedDate,
          appointments: appointments,
          onAppointmentTap: _onAppointmentTap,
          onDateTap: _onDateTap,
        );
    }
  }

  List<Appointment> _getAppointmentsForCurrentView(List<Appointment> allAppointments) {
    return allAppointments.where((appointment) {
      switch (_currentView) {
        case ScheduleViewType.day:
          return _isSameDay(appointment.startTime, _selectedDate);
        case ScheduleViewType.week:
          final weekStart = _getWeekStart(_selectedDate);
          final weekEnd = weekStart.add(const Duration(days: 7));
          return appointment.startTime.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                 appointment.startTime.isBefore(weekEnd);
        case ScheduleViewType.month:
          return appointment.startTime.year == _selectedDate.year &&
                 appointment.startTime.month == _selectedDate.month;
      }
    }).toList();
  }

  void _previousPeriod() {
    setState(() {
      switch (_currentView) {
        case ScheduleViewType.day:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case ScheduleViewType.week:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case ScheduleViewType.month:
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
          break;
      }
    });
    _loadAppointments();
  }

  void _nextPeriod() {
    setState(() {
      switch (_currentView) {
        case ScheduleViewType.day:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
        case ScheduleViewType.week:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case ScheduleViewType.month:
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
          break;
      }
    });
    _loadAppointments();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      _loadAppointments();
    }
  }

  void _addAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookingPage(
          preselectedDate: _selectedDate,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Запись была создана, перезагружаем данные
        _loadAppointments();
      }
    });
  }

  void _onAppointmentTap(Appointment appointment) {
    showAppointmentDetails(context, appointment);
  }

  void _onDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentView = ScheduleViewType.day;
    });
    _loadAppointments();
  }

  // Helper methods
  String _formatDate(DateTime date) {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }


  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateFull(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'
    ];
    return days[date.weekday - 1];
  }



}
