import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_theme.dart';
import '../../../providers/client_history_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../data/models/appointment.dart';

class HistoryFilterBottomSheet extends ConsumerStatefulWidget {
  const HistoryFilterBottomSheet({super.key});

  @override
  ConsumerState<HistoryFilterBottomSheet> createState() => _HistoryFilterBottomSheetState();
}

class _HistoryFilterBottomSheetState extends ConsumerState<HistoryFilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  AppointmentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final state = ref.read(clientHistoryProvider);
    _startDate = state.filterStartDate;
    _endDate = state.filterEndDate;
    _selectedStatus = state.filterStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildContent(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.filter,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Фильтры',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Очистить',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateFilters(),
          const SizedBox(height: 24),
          _buildStatusFilter(),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Период',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'От',
                date: _startDate,
                onTap: () => _selectStartDate(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'До',
                date: _endDate,
                onTap: () => _selectEndDate(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('d MMM yyyy', 'ru');
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    date != null ? dateFormat.format(date) : 'Выберите дату',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null 
                          ? AppTheme.textPrimaryColor 
                          : AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  LucideIcons.calendar,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Статус записи',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatusChip(
              status: null,
              label: 'Все',
              isSelected: _selectedStatus == null,
            ),
            ...AppointmentStatus.values.map(
              (status) => _buildStatusChip(
                status: status,
                label: status.displayName,
                isSelected: _selectedStatus == status,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required AppointmentStatus? status,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor 
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected 
                ? Colors.white 
                : AppTheme.textPrimaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: const Text(
                'Отмена',
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Применить',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ru'),
    );
    
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ru'),
    );
    
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedStatus = null;
    });
  }

  void _applyFilters() {
    final notifier = ref.read(clientHistoryProvider.notifier);
    
    // Применяем фильтры
    notifier.setDateFilter(_startDate, _endDate);
    notifier.setStatusFilter(_selectedStatus);
    
    // Перезагружаем данные с новыми фильтрами
    final user = ref.read(currentUserProvider);
    if (user != null) {
      notifier.loadClientHistory(user.id);
    }
    
    Navigator.of(context).pop();
  }
}
