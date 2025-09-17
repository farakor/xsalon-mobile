import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/services/schedule_service.dart';
import '../../../data/models/schedule_model.dart';
import '../../theme/app_theme.dart';

class ScheduleSettingsPage extends ConsumerStatefulWidget {
  const ScheduleSettingsPage({super.key});

  @override
  ConsumerState<ScheduleSettingsPage> createState() => _ScheduleSettingsPageState();
}

class _ScheduleSettingsPageState extends ConsumerState<ScheduleSettingsPage> {
  final ScheduleService _scheduleService = ScheduleService();
  bool _isLoading = false;
  
  // Состояние для рабочих дней
  Map<String, bool> workingDays = {
    'пн.': true,
    'вт.': true,
    'ср.': true,
    'чт.': true,
    'пт.': true,
    'сб.': true,
    'вс.': true,
  };

  // Состояние для времени работы
  Map<String, Map<String, TimeOfDay>> workingHours = {
    'пн.': {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 21, minute: 5)},
    'вт.': {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 21, minute: 0)},
    'ср.': {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 21, minute: 0)},
    'чт.': {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 21, minute: 0)},
    'пт.': {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 21, minute: 0)},
    'сб.': {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 21, minute: 0)},
    'вс.': {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 21, minute: 0)},
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentSchedule();
  }

  Future<void> _loadCurrentSchedule() async {
    try {
      setState(() => _isLoading = true);
      
      final masterId = await _scheduleService.getCurrentMasterId();
      if (masterId != null) {
        final schedules = await _scheduleService.getMasterSchedule(masterId);
        _updateUIFromSchedules(schedules);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки расписания: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateUIFromSchedules(List<MasterSchedule> schedules) {
    for (final schedule in schedules) {
      final russianDay = DayOfWeekUtils.englishToRussian(schedule.dayOfWeek);
      
      workingDays[russianDay] = schedule.isWorking;
      
      if (schedule.isWorking && schedule.startTime != null && schedule.endTime != null) {
        final startParts = schedule.startTime!.split(':');
        final endParts = schedule.endTime!.split(':');
        
        workingHours[russianDay] = {
          'start': TimeOfDay(
            hour: int.parse(startParts[0]), 
            minute: int.parse(startParts[1])
          ),
          'end': TimeOfDay(
            hour: int.parse(endParts[0]), 
            minute: int.parse(endParts[1])
          ),
        };
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Настройте график работы'),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.02),
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок с иконкой
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Настройка расписания',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Укажите часовой пояс и часы работы. Не беспокойтесь: если что, это можно будет отредактировать позже',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Карточка с расписанием
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок секции
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_view_week,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Рабочие дни',
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Список дней недели
                        ...workingDays.entries.map((entry) {
                          final dayKey = entry.key;
                          final isWorking = entry.value;
                          final hours = workingHours[dayKey]!;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isWorking 
                                  ? AppTheme.primaryColor.withValues(alpha: 0.05)
                                  : Colors.grey.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isWorking 
                                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                    : AppTheme.borderColor,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // День недели
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isWorking 
                                        ? AppTheme.primaryColor 
                                        : Colors.grey.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      dayKey.toUpperCase(),
                                      style: AppTheme.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isWorking ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Время работы или переключатель
                                if (isWorking) ...[
                                  Expanded(
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () => _selectTime(context, dayKey, 'start'),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: AppTheme.primaryColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatTime(hours['start']!),
                                                  style: AppTheme.bodyMedium.copyWith(
                                                    color: AppTheme.primaryColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '—',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => _selectTime(context, dayKey, 'end'),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: AppTheme.primaryColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatTime(hours['end']!),
                                                  style: AppTheme.bodyMedium.copyWith(
                                                    color: AppTheme.primaryColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: Text(
                                      'Выходной',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],

                                // Переключатель работы/выходного
                                Switch(
                                  value: isWorking,
                                  onChanged: (value) {
                                    setState(() {
                                      workingDays[dayKey] = value;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Кнопка сохранить
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Сохранить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, String dayKey, String timeType) async {
    final currentTime = workingHours[dayKey]![timeType]!;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        workingHours[dayKey]![timeType] = picked;
      });
    }
  }

  Future<void> _saveSchedule() async {
    try {
      setState(() => _isLoading = true);
      
      final masterId = await _scheduleService.getCurrentMasterId();
      
      if (masterId == null) {
        throw Exception('Мастер не найден. Проверьте, что вы авторизованы как мастер.');
      }
      
      // Конвертируем UI данные в модели
      final schedules = <MasterSchedule>[];
      for (final entry in workingDays.entries) {
        final russianDay = entry.key;
        final isWorking = entry.value;
        final englishDay = DayOfWeekUtils.russianToEnglish(russianDay);
        
        String? startTime, endTime;
        if (isWorking && workingHours[russianDay] != null) {
          final hours = workingHours[russianDay]!;
          startTime = _formatTimeOfDay(hours['start']!);
          endTime = _formatTimeOfDay(hours['end']!);
        }
        
        schedules.add(MasterSchedule(
          id: '', // Будет сгенерирован в базе
          masterId: masterId,
          dayOfWeek: englishDay,
          isWorking: isWorking,
          startTime: startTime,
          endTime: endTime,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
      
      await _scheduleService.saveMasterSchedule(masterId, schedules);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Расписание сохранено успешно!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Возвращаемся на главную страницу
        context.go(AppConstants.homeRoute);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
