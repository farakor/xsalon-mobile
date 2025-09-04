import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/appointment.dart';
import '../../theme/app_theme.dart';
import 'widgets/day_schedule_view.dart';
import 'widgets/week_schedule_view.dart';
import 'widgets/month_schedule_view.dart';
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

  // Тестовые данные - в реальном приложении будут загружаться из API
  List<Appointment> get _mockAppointments => [
    Appointment(
      id: '1',
      clientId: 'client1',
      clientName: 'Анна Иванова',
      clientPhone: '+998 90 123 45 67',
      serviceId: 'service1',
      serviceName: 'Женская стрижка',
      startTime: DateTime.now().copyWith(hour: 9, minute: 0, second: 0),
      endTime: DateTime.now().copyWith(hour: 10, minute: 30, second: 0),
      status: AppointmentStatus.confirmed,
      price: 150000,
    ),
    Appointment(
      id: '2',
      clientId: 'client2',
      clientName: 'Мария Петрова',
      clientPhone: '+998 90 987 65 43',
      serviceId: 'service2',
      serviceName: 'Окрашивание волос',
      startTime: DateTime.now().copyWith(hour: 11, minute: 0, second: 0),
      endTime: DateTime.now().copyWith(hour: 13, minute: 30, second: 0),
      status: AppointmentStatus.pending,
      price: 300000,
    ),
    Appointment(
      id: '3',
      clientId: 'client3',
      clientName: 'Елена Сидорова',
      clientPhone: '+998 90 555 44 33',
      serviceId: 'service3',
      serviceName: 'Укладка',
      startTime: DateTime.now().copyWith(hour: 14, minute: 0, second: 0),
      endTime: DateTime.now().copyWith(hour: 15, minute: 0, second: 0),
      status: AppointmentStatus.inProgress,
      price: 80000,
    ),
    Appointment(
      id: '4',
      clientId: 'client4',
      clientName: 'Ольга Козлова',
      clientPhone: '+998 90 111 22 33',
      serviceId: 'service4',
      serviceName: 'Маникюр',
      startTime: DateTime.now().copyWith(hour: 16, minute: 0, second: 0),
      endTime: DateTime.now().copyWith(hour: 17, minute: 30, second: 0),
      status: AppointmentStatus.confirmed,
      price: 120000,
    ),
  ];

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
    final appointments = _getAppointmentsForCurrentView();
    
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

  List<Appointment> _getAppointmentsForCurrentView() {
    // В реальном приложении здесь будет фильтрация по дате из API
    return _mockAppointments.where((appointment) {
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
        // Запись была создана, можно обновить данные
        setState(() {
          // В реальном приложении здесь будет перезагрузка данных
        });
      }
    });
  }

  void _onAppointmentTap(Appointment appointment) {
    // TODO: Show appointment details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.serviceName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Клиент: ${appointment.clientName}'),
            Text('Телефон: ${appointment.clientPhone}'),
            Text('Время: ${_formatTime(appointment.startTime)} - ${_formatTime(appointment.endTime)}'),
            Text('Статус: ${appointment.status.displayName}'),
            Text('Цена: ${_formatPrice(appointment.price)}'),
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

  void _onDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentView = ScheduleViewType.day;
    });
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
