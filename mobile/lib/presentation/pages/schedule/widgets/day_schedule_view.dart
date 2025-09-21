import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    if (appointments.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern Day Summary
          _buildModernDaySummary(),
          // Time Schedule
          Expanded(
            child: _buildModernTimeSchedule(context),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDaySummary() {
    final totalAppointments = appointments.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.calendarDays,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatSelectedDate(),
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$totalAppointments записей на день',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (totalAppointments > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$totalAppointments',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTimeSchedule(BuildContext context) {
    const startHour = 8;
    const endHour = 20;
    const hourHeight = 120.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: (endHour - startHour) * hourHeight,
        child: Stack(
          children: [
            // Modern Time Grid
            ..._buildModernTimeGrid(startHour, endHour, hourHeight),
            // Modern Appointment Blocks
            ..._buildModernAppointmentBlocks(startHour, hourHeight),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildModernTimeGrid(int startHour, int endHour, double hourHeight) {
    final widgets = <Widget>[];

    for (int hour = startHour; hour <= endHour; hour++) {
      final top = (hour - startHour) * hourHeight;
      
      // Time label with modern styling
      widgets.add(
        Positioned(
          left: 0,
          top: top - 12,
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      // Modern grid line (более заметная)
      if (hour < endHour) {
        widgets.add(
          Positioned(
            left: 80,
            right: 0,
            top: top,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.borderColor.withValues(alpha: 0.8),
                    AppTheme.borderColor.withValues(alpha: 0.6),
                    AppTheme.borderColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Half-hour time label
      if (hour < endHour) {
        widgets.add(
          Positioned(
            left: 0,
            top: top + hourHeight / 2 - 8,
            child: Container(
              width: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:30',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      // Half-hour line with better visibility
      if (hour < endHour) {
        widgets.add(
          Positioned(
            left: 80,
            right: 0,
            top: top + hourHeight / 2,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.borderColor.withValues(alpha: 0.5),
                    AppTheme.borderColor.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }


  Widget _buildTimeSchedule(BuildContext context) {
    const startHour = 8;
    const endHour = 20;
    const hourHeight = 120.0;

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
                const Icon(LucideIcons.calendarCheck, color: AppTheme.primaryColor),
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

      // Grid line (более заметная)
      if (hour < endHour) {
        widgets.add(
          Positioned(
            left: 60,
            right: 0,
            top: top,
            child: Container(
              height: 1.5,
              color: Colors.grey[300],
            ),
          ),
        );
      }

      // Half-hour time label
      if (hour < endHour) {
        widgets.add(
          Positioned(
            left: 0,
            top: top + hourHeight / 2 - 8,
            child: Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:30',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        );
      }

      // Half-hour line (более заметная)
      if (hour < endHour) {
        widgets.add(
          Positioned(
            left: 60,
            right: 0,
            top: top + hourHeight / 2,
            child: Container(
              height: 1,
              color: Colors.grey[250],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  List<Widget> _buildModernAppointmentBlocks(int startHour, double hourHeight) {
    return appointments.map((appointment) {
      final startMinutes = appointment.startTime.hour * 60 + appointment.startTime.minute;
      final endMinutes = appointment.endTime.hour * 60 + appointment.endTime.minute;
      final startHourMinutes = startHour * 60;

      final top = ((startMinutes - startHourMinutes) / 60) * hourHeight;
      final calculatedHeight = ((endMinutes - startMinutes) / 60) * hourHeight;
      // С увеличенным масштабом (120px/час) даже 30 мин = 60px, достаточно для контента
      final height = calculatedHeight;

      return Positioned(
        left: 90,
        right: 16,
        top: top,
        child: GestureDetector(
          onTap: () => onAppointmentTap(appointment),
          child: Container(
            height: height,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getStatusColor(appointment.status),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(appointment.status).withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
              ),
              child: Padding(
                padding: EdgeInsets.all(height < 40 ? 1.0 : (height < 60 ? 2.0 : 4.0)),
                child: height < 30 
                  ? Center(
                      // Для экстремально коротких записей - всё в одной строке
                      child: Text(
                        '${appointment.clientName} ${_formatTime(appointment.startTime)}-${_formatTime(appointment.endTime)}',
                        style: AppTheme.bodySmall.copyWith(
                          color: _getStatusColor(appointment.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : height < 50 
                    ? Center(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                          children: [
                            // Имя клиента (компактно)
                            Text(
                              appointment.clientName,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textPrimaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            // Время (очень компактно)
                            Text(
                              '${_formatTime(appointment.startTime)}-${_formatTime(appointment.endTime)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: _getStatusColor(appointment.status),
                                fontWeight: FontWeight.w500,
                                fontSize: 7,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          ),
                        ),
                      )
                    : Center(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Имя клиента
                              Text(
                                appointment.clientName,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // Время
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.clock,
                                    size: 12,
                                    color: _getStatusColor(appointment.status),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_formatTime(appointment.startTime)} - ${_formatTime(appointment.endTime)}',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: _getStatusColor(appointment.status),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Статус
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(appointment.status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  appointment.status.displayName,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    }).toList();
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
        return const Color(0xFFFF9500); // Modern orange
      case AppointmentStatus.confirmed:
        return const Color(0xFF34C759); // Modern green
      case AppointmentStatus.cancelled:
        return const Color(0xFFFF3B30); // Modern red
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.calendarCheck,
                    color: AppTheme.textSecondaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatSelectedDate(),
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Свободный день',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Empty content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      LucideIcons.calendarCheck,
                      size: 64,
                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Записей нет',
                    style: AppTheme.titleLarge.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'На этот день записи отсутствуют.\nВремя свободно для новых клиентов.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate() {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    const weekdays = [
      'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'
    ];
    
    return '${weekdays[selectedDate.weekday - 1]}, ${selectedDate.day} ${months[selectedDate.month - 1]}';
  }
}
