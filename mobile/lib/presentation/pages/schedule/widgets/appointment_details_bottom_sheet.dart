import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/appointment.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/appointments_provider.dart';

class AppointmentDetailsBottomSheet extends ConsumerStatefulWidget {
  final Appointment appointment;

  const AppointmentDetailsBottomSheet({
    super.key,
    required this.appointment,
  });

  @override
  ConsumerState<AppointmentDetailsBottomSheet> createState() =>
      _AppointmentDetailsBottomSheetState();
}

class _AppointmentDetailsBottomSheetState
    extends ConsumerState<AppointmentDetailsBottomSheet> {
  bool _isEditingNotes = false;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.appointment.masterNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Детали записи',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(appointment.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    appointment.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client info
                  _buildInfoSection(
                    icon: Icons.person,
                    title: 'Клиент',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.clientName,
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              appointment.clientPhone,
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Service info
                  _buildInfoSection(
                    icon: Icons.design_services,
                    title: 'Услуга',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.serviceName,
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Длительность: ${_formatDuration(appointment.duration)}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Time info
                  _buildInfoSection(
                    icon: Icons.schedule,
                    title: 'Время',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateTime(appointment.startTime),
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatTime(appointment.startTime)} - ${_formatTime(appointment.endTime)}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Price info
                  _buildInfoSection(
                    icon: Icons.payments,
                    title: 'Стоимость',
                    content: Text(
                      '${_formatPrice(appointment.price)} сум',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                // Client notes section
                _buildClientNotesSection(),
                
                const SizedBox(height: 24),
                
                // Master notes section
                _buildMasterNotesSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              children: [
                // Status change buttons
                if (appointment.status != AppointmentStatus.completed &&
                    appointment.status != AppointmentStatus.cancelled)
                  _buildStatusActions(),
                
                const SizedBox(height: 16),
                
                // Main actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement edit appointment
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Редактировать'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCancelDialog(),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Отменить'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              content,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientNotesSection() {
    return _buildInfoSection(
      icon: Icons.comment,
      title: 'Заметки клиента',
      content: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          widget.appointment.notes?.isNotEmpty == true
              ? widget.appointment.notes!
              : 'Заметок нет',
          style: AppTheme.bodyMedium.copyWith(
            color: widget.appointment.notes?.isNotEmpty == true
                ? Colors.black87
                : Colors.grey[500],
            fontStyle: widget.appointment.notes?.isNotEmpty == true
                ? FontStyle.normal
                : FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildMasterNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.note,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Мои заметки',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!_isEditingNotes)
              IconButton(
                onPressed: () => setState(() => _isEditingNotes = true),
                icon: const Icon(Icons.edit, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[600],
                  minimumSize: const Size(32, 32),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isEditingNotes)
          Column(
            children: [
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Добавить заметку...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _notesController.text = widget.appointment.masterNotes ?? '';
                      setState(() => _isEditingNotes = false);
                    },
                    child: const Text('Отмена'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveNotes,
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              widget.appointment.masterNotes?.isNotEmpty == true
                  ? widget.appointment.masterNotes!
                  : 'Заметок нет',
              style: AppTheme.bodyMedium.copyWith(
                color: widget.appointment.masterNotes?.isNotEmpty == true
                    ? Colors.black87
                    : Colors.grey[500],
                fontStyle: widget.appointment.masterNotes?.isNotEmpty == true
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusActions() {
    final currentStatus = widget.appointment.status;
    final availableStatuses = <AppointmentStatus>[];

    // Определяем доступные статусы в зависимости от текущего
    switch (currentStatus) {
      case AppointmentStatus.pending:
        availableStatuses.addAll([
          AppointmentStatus.confirmed,
          AppointmentStatus.cancelled,
        ]);
        break;
      case AppointmentStatus.confirmed:
        availableStatuses.addAll([
          AppointmentStatus.inProgress,
          AppointmentStatus.cancelled,
        ]);
        break;
      case AppointmentStatus.inProgress:
        availableStatuses.addAll([
          AppointmentStatus.completed,
          AppointmentStatus.cancelled,
        ]);
        break;
      default:
        break;
    }

    if (availableStatuses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Изменить статус:',
          style: AppTheme.bodySmall.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: availableStatuses.map((status) {
            return ActionChip(
              label: Text(status.displayName),
              onPressed: () => _changeStatus(status),
              backgroundColor: _getStatusColor(status).withOpacity(0.1),
              side: BorderSide(color: _getStatusColor(status)),
              labelStyle: TextStyle(
                color: _getStatusColor(status),
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
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
        return Colors.green[700]!;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    
    const weekdays = [
      'пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final weekday = weekdays[dateTime.weekday - 1];

    return '$day $month, $weekday';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}ч ${minutes}м' : '${hours}ч';
    } else {
      return '${minutes}м';
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  void _changeStatus(AppointmentStatus newStatus) {
    ref.read(appointmentsProvider.notifier).updateAppointmentStatus(
      widget.appointment.id,
      newStatus,
    );
    Navigator.pop(context);
  }

  void _saveNotes() async {
    try {
      await ref.read(appointmentsProvider.notifier).updateAppointmentNotes(
        widget.appointment.id,
        _notesController.text,
      );
      
      setState(() => _isEditingNotes = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заметки сохранены'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения заметок: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить запись?'),
        content: const Text(
          'Вы уверены, что хотите отменить эту запись? Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Нет'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _changeStatus(AppointmentStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Да, отменить'),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the bottom sheet
void showAppointmentDetails(BuildContext context, Appointment appointment) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,  // Увеличили с 0.7 до 0.85 (85% экрана)
      minChildSize: 0.6,       // Увеличили с 0.5 до 0.6 (60% экрана)
      maxChildSize: 0.95,      // Оставили максимум 95%
      builder: (context, scrollController) => AppointmentDetailsBottomSheet(
        appointment: appointment,
      ),
    ),
  );
}
