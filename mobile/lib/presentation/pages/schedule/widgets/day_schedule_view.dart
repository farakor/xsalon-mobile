import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/appointment.dart';
import '../../../theme/app_theme.dart';

class DayScheduleView extends StatelessWidget {
  final DateTime selectedDate;
  final List<Appointment> appointments;
  final Function(Appointment) onAppointmentTap;

  const DayScheduleView({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Today's Summary
          _buildDaySummary(),
          const SizedBox(height: 16),
          // Time Schedule
          _buildTimeSchedule(context),
        ],
      ),
    );
  }

  Widget _buildDaySummary() {
    final totalAppointments = appointments.length;
    final totalRevenue = appointments.fold<double>(
      0,
      (sum, appointment) => sum + appointment.price,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Записей на день',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$totalAppointments',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.primaryColor,
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
                  'Доход за день',
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

  Widget _buildTimeSchedule(BuildContext context) {
    const startHour = 8;
    const endHour = 20;
    const hourHeight = 80.0;

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
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Временная шкала',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Time slots
          SizedBox(
            height: (endHour - startHour) * hourHeight,
            child: Stack(
              children: [
                // Time labels and grid lines
                ..._buildTimeGrid(startHour, endHour, hourHeight),
                // Appointments
                ..._buildAppointmentBlocks(startHour, hourHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeGrid(int startHour, int endHour, double hourHeight) {
    final widgets = <Widget>[];

    for (int hour = startHour; hour <= endHour; hour++) {
      final top = (hour - startHour) * hourHeight;
      
      // Time label
      widgets.add(
        Positioned(
          left: 0,
          top: top - 10,
          child: Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );

      // Grid line
      if (hour < endHour) {
        widgets.add(
          Positioned(
            left: 60,
            right: 0,
            top: top,
            child: Container(
              height: 1,
              color: Colors.grey[200],
            ),
          ),
        );
      }

      // Half-hour line
      if (hour < endHour) {
        widgets.add(
          Positioned(
            left: 60,
            right: 0,
            top: top + hourHeight / 2,
            child: Container(
              height: 1,
              color: Colors.grey[100],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  List<Widget> _buildAppointmentBlocks(int startHour, double hourHeight) {
    return appointments.map((appointment) {
      final startMinutes = appointment.startTime.hour * 60 + appointment.startTime.minute;
      final endMinutes = appointment.endTime.hour * 60 + appointment.endTime.minute;
      final startHourMinutes = startHour * 60;

      final top = ((startMinutes - startHourMinutes) / 60) * hourHeight;
      final height = ((endMinutes - startMinutes) / 60) * hourHeight;

      return Positioned(
        left: 70,
        right: 16,
        top: top,
        child: GestureDetector(
          onTap: () => onAppointmentTap(appointment),
          child: Container(
            height: height,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment.serviceName,
                          style: AppTheme.titleSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          appointment.status.displayName,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.clientName,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_formatTime(appointment.startTime)} - ${_formatTime(appointment.endTime)}',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  if (height > 60) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(appointment.price),
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
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
}
