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
      appBar: AppBar(
        title: const Text('Настройте график работы'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и описание
                    Text(
                      'Настройте график работы',
                      style: AppTheme.titleLarge.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Укажите часовой пояс и часы работы. Не беспокойтесь: если что, это можно будет отредактировать позже',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Список дней недели
                    ...workingDays.entries.map((entry) {
                      final dayKey = entry.key;
                      final isWorking = entry.value;
                      final hours = workingHours[dayKey]!;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // День недели
                            SizedBox(
                              width: 30,
                              child: Text(
                                dayKey,
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Время работы или переключатель
                            if (isWorking) ...[
                              Expanded(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _selectTime(context, dayKey, 'start'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _formatTime(hours['start']!),
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.pink,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      ' — ',
                                      style: AppTheme.bodyMedium,
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _selectTime(context, dayKey, 'end'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _formatTime(hours['end']!),
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.pink,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                                    color: Colors.grey[500],
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
                              activeColor: Colors.green,
                              activeTrackColor: Colors.green.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Кнопка продолжить
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
              primary: Colors.pink,
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
      final organizationId = await _scheduleService.getCurrentOrganizationId();
      
      if (masterId == null) {
        throw Exception('Мастер не найден. Проверьте, что вы авторизованы как мастер.');
      }
      
      if (organizationId == null) {
        throw Exception('Организация не найдена. Обратитесь к администратору.');
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
          organizationId: organizationId,
          dayOfWeek: englishDay,
          isWorking: isWorking,
          startTime: startTime,
          endTime: endTime,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
      
      await _scheduleService.saveMasterSchedule(masterId, organizationId, schedules);
      
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
