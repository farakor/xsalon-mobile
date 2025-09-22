import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_theme.dart';
import '../../../../data/models/appointment.dart';

class AppointmentHistoryCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentHistoryCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildServiceInfo(),
            const SizedBox(height: 12),
            _buildTimeInfo(),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildNotes(),
            ],
            const SizedBox(height: 12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.serviceName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                appointment.masterName ?? 'Мастер',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.scissors,
            size: 16,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              appointment.serviceName,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          Text(
            '${appointment.price.toStringAsFixed(0)} ₽',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    final dateFormat = DateFormat('d MMMM yyyy', 'ru');
    final timeFormat = DateFormat('HH:mm');
    
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(
                LucideIcons.calendar,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(appointment.startTime),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(
              LucideIcons.clock,
              size: 16,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              '${timeFormat.format(appointment.startTime)} - ${timeFormat.format(appointment.endTime)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                LucideIcons.messageSquare,
                size: 16,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Text(
                'Заметки',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            appointment.notes!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final duration = appointment.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    String durationText = '';
    if (hours > 0) {
      durationText = '${hours}ч';
      if (minutes > 0) {
        durationText += ' ${minutes}м';
      }
    } else {
      durationText = '${minutes}м';
    }

    return Row(
      children: [
        Icon(
          LucideIcons.timer,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 6),
        Text(
          'Длительность: $durationText',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const Spacer(),
        if (appointment.status == AppointmentStatus.confirmed) ...[
          const Icon(
            LucideIcons.checkCircle,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          const Text(
            'Выполнено',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        appointment.status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return LucideIcons.clock;
      case AppointmentStatus.confirmed:
        return LucideIcons.checkCircle;
      case AppointmentStatus.cancelled:
        return LucideIcons.xCircle;
    }
  }
}
