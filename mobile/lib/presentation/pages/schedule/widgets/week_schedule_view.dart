import 'package:flutter/material.dart';

import '../../../../data/models/appointment.dart';
import '../../../theme/app_theme.dart';

class WeekScheduleView extends StatelessWidget {
  final DateTime selectedDate;
  final List<Appointment> appointments;
  final Function(Appointment) onAppointmentTap;
  final Function(DateTime) onDateTap;

  const WeekScheduleView({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.onAppointmentTap,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart = _getWeekStart(selectedDate);
    final weekDays = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Week Summary
          _buildWeekSummary(),
          const SizedBox(height: 16),
          // Week Grid
          _buildWeekGrid(weekDays),
        ],
      ),
    );
  }

  Widget _buildWeekSummary() {
    final totalAppointments = appointments.length;
    final totalRevenue = appointments.fold<double>(
      0,
      (sum, appointment) => sum + appointment.price,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Записей на неделю',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$totalAppointments',
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Доход за неделю',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _formatPrice(totalRevenue),
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekGrid(List<DateTime> weekDays) {
    return Container(
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.view_week, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Недельное расписание',
                  style: AppTheme.titleMedium.copyWith(
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
          // Days
          ...weekDays.map((day) => _buildDayRow(day)),
        ],
      ),
    );
  }

  Widget _buildDayRow(DateTime day) {
    final dayAppointments = appointments.where((appointment) =>
        _isSameDay(appointment.startTime, day)).toList();
    
    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _isSameDay(day, selectedDate);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: InkWell(
        onTap: () => onDateTap(day),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDayName(day),
                          style: AppTheme.titleSmall.copyWith(
                            color: isToday ? AppTheme.primaryColor : Colors.grey[700],
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          '${day.day}',
                          style: AppTheme.headlineSmall.copyWith(
                            color: isToday ? AppTheme.primaryColor : Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: dayAppointments.isEmpty
                        ? Text(
                            'Свободный день',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${dayAppointments.length} записей',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: dayAppointments.take(3).map((appointment) =>
                                    _buildAppointmentChip(appointment)).toList(),
                              ),
                              if (dayAppointments.length > 3)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '+${dayAppointments.length - 3} еще',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
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

  Widget _buildAppointmentChip(Appointment appointment) {
    return GestureDetector(
      onTap: () => onAppointmentTap(appointment),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(appointment.status).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${_formatTime(appointment.startTime)} ${appointment.serviceName}',
              style: AppTheme.bodySmall.copyWith(
                color: _getStatusColor(appointment.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
        return Colors.teal;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }

  String _getDayName(DateTime date) {
    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return dayNames[date.weekday - 1];
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
