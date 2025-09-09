import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
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
      appBar: AppBar(
        title: const Text('Расписание'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAppointment,
            tooltip: 'Добавить запись',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Настройки'),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Text('Экспорт'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // View Type Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // View Toggle Buttons
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<ScheduleViewType>(
                        segments: const [
                          ButtonSegment(
                            value: ScheduleViewType.day,
                            label: Text('День'),
                            icon: Icon(Icons.view_day),
                          ),
                          ButtonSegment(
                            value: ScheduleViewType.week,
                            label: Text('Неделя'),
                            icon: Icon(Icons.view_week),
                          ),
                          ButtonSegment(
                            value: ScheduleViewType.month,
                            label: Text('Месяц'),
                            icon: Icon(Icons.calendar_month),
                          ),
                        ],
                        selected: {_currentView},
                        onSelectionChanged: (Set<ScheduleViewType> selection) {
                          setState(() {
                            _currentView = selection.first;
                          });
                          _loadAppointments();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Date Navigation
                _buildDateNavigation(),
              ],
            ),
          ),
          // Schedule Content
          Expanded(
            child: _buildScheduleView(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigation() {
    String dateText;
    switch (_currentView) {
      case ScheduleViewType.day:
        dateText = _formatDate(_selectedDate);
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousPeriod,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dateText,
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _nextPeriod,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
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
              Icons.error_outline,
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
}
