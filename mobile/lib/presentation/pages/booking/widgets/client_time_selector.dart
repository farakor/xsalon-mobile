import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../providers/schedule_provider.dart';
import '../../../../domain/entities/master.dart';
import '../../../../domain/entities/service.dart';

class ClientTimeSelector extends ConsumerStatefulWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final MasterEntity? selectedMaster;
  final ServiceEntity? selectedService;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;

  const ClientTimeSelector({
    super.key,
    this.selectedDate,
    this.selectedTime,
    this.selectedMaster,
    this.selectedService,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  ConsumerState<ClientTimeSelector> createState() => _ClientTimeSelectorState();
}

class _ClientTimeSelectorState extends ConsumerState<ClientTimeSelector> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedDate ?? DateTime.now();
    
    // Загружаем расписание выбранного мастера при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedMaster != null) {
        print('ClientTimeSelector: Loading master schedule for ${widget.selectedMaster!.fullName}...');
        ref.read(scheduleProvider.notifier).loadMasterScheduleById(widget.selectedMaster!.id);
        
        // Если уже есть выбранная дата, загружаем для неё слоты
        if (widget.selectedDate != null) {
          print('ClientTimeSelector: Loading slots for initial selected date: ${widget.selectedDate}');
          _loadSlotsForDate(widget.selectedDate!);
        }
      }
    });
  }

  @override
  void didUpdateWidget(ClientTimeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Если изменился мастер, загружаем его расписание
    if (widget.selectedMaster?.id != oldWidget.selectedMaster?.id && widget.selectedMaster != null) {
      print('ClientTimeSelector: Master changed, loading new schedule...');
      ref.read(scheduleProvider.notifier).loadMasterScheduleById(widget.selectedMaster!.id);
    }
    
    // Если изменилась выбранная дата, загружаем слоты для новой даты
    if (widget.selectedDate != oldWidget.selectedDate && widget.selectedDate != null) {
      _loadSlotsForDate(widget.selectedDate!);
    }
  }

  void _loadSlotsForDate(DateTime date) {
    if (widget.selectedMaster == null || widget.selectedService == null) {
      print('ClientTimeSelector: Cannot load slots - master or service not selected');
      return;
    }
    
    print('ClientTimeSelector: Loading slots for date: $date');
    print('ClientTimeSelector: Service duration: ${Duration(minutes: widget.selectedService!.durationMinutes)}');
    
    ref.read(scheduleProvider.notifier).loadAvailableSlotsForMaster(
      date,
      masterId: widget.selectedMaster!.id,
      serviceDuration: Duration(minutes: widget.selectedService!.durationMinutes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selected Date and Time (if any)
        if (widget.selectedDate != null || widget.selectedTime != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.selectedDate != null && widget.selectedTime != null)
                        Text(
                          'Выбрано: ${_formatDate(widget.selectedDate!)} в ${_formatTime(widget.selectedTime!)}',
                          style: AppTheme.titleSmall.copyWith(
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else if (widget.selectedDate != null)
                        Text(
                          'Дата: ${_formatDate(widget.selectedDate!)}',
                          style: AppTheme.titleSmall.copyWith(
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (widget.selectedService != null && widget.selectedTime != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Окончание: ${_formatTime(_addDuration(widget.selectedTime!, Duration(minutes: widget.selectedService!.durationMinutes)))}',
                          style: AppTheme.bodySmall.copyWith(
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Calendar
        _buildCalendar(),
        
        const SizedBox(height: 24),
        
        // Time Slots
        if (widget.selectedDate != null && widget.selectedMaster != null && widget.selectedService != null) ...[
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
                  LucideIcons.clock,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Выберите время',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Container(
            height: 300,
            child: _buildTimeSlots(),
          ),
        ] else ...[
          Container(
            height: 300,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.calendarDays,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.selectedDate == null 
                      ? 'Выберите дату'
                      : widget.selectedMaster == null
                          ? 'Выберите мастера'
                          : 'Выберите услугу',
                  style: AppTheme.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Text(
                  widget.selectedDate == null
                      ? 'Сначала выберите дату для записи'
                      : widget.selectedMaster == null
                          ? 'Вернитесь и выберите мастера'
                          : 'Вернитесь и выберите услугу',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
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
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(LucideIcons.chevronLeft),
              ),
              Text(
                _formatMonth(_currentMonth),
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(LucideIcons.chevronRight),
              ),
            ],
          ),
          
          // Week Days Header
          Row(
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Calendar Days
          _buildCalendarDays(),
        ],
      ),
    );
  }

  Widget _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final daysFromPrevMonth = firstWeekday - 1;
    final totalCells = ((daysInMonth + daysFromPrevMonth) / 7).ceil() * 7;

    return Column(
      children: List.generate((totalCells / 7).ceil(), (weekIndex) {
        return Row(
          children: List.generate(7, (dayIndex) {
            final cellIndex = weekIndex * 7 + dayIndex;
            final dayNumber = cellIndex - daysFromPrevMonth + 1;
            
            if (cellIndex < daysFromPrevMonth || dayNumber > daysInMonth) {
              return const Expanded(child: SizedBox(height: 40));
            }

            final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
            final isToday = _isSameDay(date, DateTime.now());
            final isSelected = widget.selectedDate != null && _isSameDay(date, widget.selectedDate!);
            final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
            final isWeekend = date.weekday >= 6;

            return Expanded(
              child: GestureDetector(
                onTap: isPast ? null : () {
                  widget.onDateSelected(date);
                  _loadSlotsForDate(date);
                },
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryColor
                        : isToday 
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: AppTheme.primaryColor)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: AppTheme.bodyMedium.copyWith(
                        color: isPast
                            ? Colors.grey[400]
                            : isSelected
                                ? const Color(0xFF000000)
                                : isWeekend
                                    ? Colors.red[400]
                                    : isToday
                                        ? AppTheme.primaryColor
                                        : Colors.grey[800],
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildTimeSlots() {
    if (widget.selectedDate == null || widget.selectedMaster == null || widget.selectedService == null) {
      return Container(
        height: 300,
        child: const Center(
          child: Text('Выберите дату, мастера и услугу'),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(scheduleProvider.notifier).loadSlotsWithOccupancyForMaster(
        widget.selectedDate!,
        masterId: widget.selectedMaster!.id,
        serviceDuration: Duration(minutes: widget.selectedService!.durationMinutes),
      ),
      builder: (context, snapshot) {
        final isLoading = ref.watch(isScheduleLoadingProvider);
        final error = ref.watch(scheduleErrorProvider);

        // Показываем состояние загрузки
        if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
          return Container(
            height: 300,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Показываем ошибку
        if (error != null || snapshot.hasError) {
          return Container(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки времени',
                    style: AppTheme.titleMedium.copyWith(
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error ?? snapshot.error.toString(),
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.selectedDate != null) {
                        _loadSlotsForDate(widget.selectedDate!);
                      }
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }

        final slotsWithOccupancy = snapshot.data ?? [];

        // Показываем пустое состояние
        if (slotsWithOccupancy.isEmpty) {
          return Container(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет доступного времени',
                    style: AppTheme.titleMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'На выбранную дату у мастера нет свободных слотов',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          height: 300,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: slotsWithOccupancy.length,
            itemBuilder: (context, index) {
              final slotData = slotsWithOccupancy[index];
              final timeSlot = slotData['time'] as TimeOfDay;
              final isOccupied = slotData['isOccupied'] as bool;
              
              final isSelected = widget.selectedTime != null && 
                  widget.selectedTime!.hour == timeSlot.hour && 
                  widget.selectedTime!.minute == timeSlot.minute;
              
              // Проверяем, не прошло ли время (только для сегодняшнего дня)
              final isPast = widget.selectedDate != null && 
                  _isSameDay(widget.selectedDate!, DateTime.now()) &&
                  _isTimePast(timeSlot);

              final isDisabled = isPast || isOccupied;

              return GestureDetector(
                onTap: isDisabled ? null : () => widget.onTimeSelected(timeSlot),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : isOccupied
                            ? Colors.red[100]
                            : isPast
                                ? Colors.grey[200]
                                : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : isOccupied
                              ? Colors.red[300]!
                              : isPast
                                  ? Colors.grey[400]!
                                  : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(timeSlot),
                          style: AppTheme.bodyMedium.copyWith(
                            color: isSelected
                                ? const Color(0xFF000000)
                                : isOccupied
                                    ? Colors.red[600]
                                    : isPast
                                        ? Colors.grey[500]
                                        : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isOccupied)
                          Text(
                            'Занято',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.red[500],
                              fontSize: 10,
                            ),
                          ),
                        if (isPast && !isOccupied)
                          Text(
                            'Прошло',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isTimePast(TimeOfDay time) {
    final now = DateTime.now();
    final timeDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return timeDateTime.isBefore(now);
  }

  TimeOfDay _addDuration(TimeOfDay time, Duration duration) {
    final totalMinutes = time.hour * 60 + time.minute + duration.inMinutes;
    return TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
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

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
