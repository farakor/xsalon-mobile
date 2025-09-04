import 'package:flutter/material.dart';

import '../../../../data/models/appointment.dart';
import '../../../theme/app_theme.dart';

class MonthScheduleView extends StatelessWidget {
  final DateTime selectedDate;
  final List<Appointment> appointments;
  final Function(Appointment) onAppointmentTap;
  final Function(DateTime) onDateTap;

  const MonthScheduleView({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.onAppointmentTap,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month Summary
          _buildMonthSummary(),
          const SizedBox(height: 16),
          // Calendar Grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthSummary() {
    final totalAppointments = appointments.length;
    final totalRevenue = appointments.fold<double>(
      0,
      (sum, appointment) => sum + appointment.price,
    );
    final workingDays = _getWorkingDaysInMonth();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Записей в месяце',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '$totalAppointments',
                      style: AppTheme.headlineMedium.copyWith(
                        color: Colors.purple[600],
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
                      'Доход за месяц',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рабочих дней',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '$workingDays',
                      style: AppTheme.titleLarge.copyWith(
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
                      'Средний доход/день',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      workingDays > 0 ? _formatPrice(totalRevenue / workingDays) : '0',
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.orange[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
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
              color: Colors.purple.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Календарь месяца',
                  style: AppTheme.titleMedium.copyWith(
                    color: Colors.purple[600],
                  ),
                ),
              ],
            ),
          ),
          // Week days header
          _buildWeekDaysHeader(),
          // Calendar days
          _buildCalendarDays(),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    const weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: weekDays.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarDays() {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate how many days to show from previous month
    final daysFromPrevMonth = firstWeekday - 1;
    final totalCells = ((daysInMonth + daysFromPrevMonth) / 7).ceil() * 7;

    return Column(
      children: List.generate((totalCells / 7).ceil(), (weekIndex) {
        return Row(
          children: List.generate(7, (dayIndex) {
            final cellIndex = weekIndex * 7 + dayIndex;
            final dayNumber = cellIndex - daysFromPrevMonth + 1;
            
            if (cellIndex < daysFromPrevMonth || dayNumber > daysInMonth) {
              return const Expanded(child: SizedBox(height: 80));
            }

            final date = DateTime(selectedDate.year, selectedDate.month, dayNumber);
            return Expanded(
              child: _buildCalendarDay(date),
            );
          }),
        );
      }),
    );
  }

  Widget _buildCalendarDay(DateTime date) {
    final dayAppointments = appointments.where((appointment) =>
        _isSameDay(appointment.startTime, date)).toList();
    
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, selectedDate);
    final isWeekend = date.weekday >= 6;

    return GestureDetector(
      onTap: () => onDateTap(date),
      child: Container(
        height: 80,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : isToday 
                  ? Colors.blue.withValues(alpha: 0.05)
                  : null,
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor
                : isToday 
                    ? Colors.blue
                    : Colors.transparent,
            width: isSelected || isToday ? 2 : 0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${date.day}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isWeekend 
                          ? Colors.red[400]
                          : isToday 
                              ? Colors.blue[600]
                              : Colors.grey[800],
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (dayAppointments.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${dayAppointments.length}',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              // Appointments indicators
              if (dayAppointments.isNotEmpty) ...[
                const SizedBox(height: 2),
                Expanded(
                  child: Column(
                    children: dayAppointments.take(3).map((appointment) {
                      return Container(
                        width: double.infinity,
                        height: 12,
                        margin: const EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appointment.status),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: Text(
                            _formatTime(appointment.startTime),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (dayAppointments.length > 3)
                  Text(
                    '+${dayAppointments.length - 3}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _getWorkingDaysInMonth() {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    
    int workingDays = 0;
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);
      final hasAppointments = appointments.any((appointment) =>
          _isSameDay(appointment.startTime, date));
      if (hasAppointments) {
        workingDays++;
      }
    }
    return workingDays;
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
