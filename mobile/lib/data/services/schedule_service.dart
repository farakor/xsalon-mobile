import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/timezone_utils.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Получить расписание мастера
  Future<List<MasterSchedule>> getMasterSchedule(String masterId) async {
    try {
      final response = await _supabase
          .from('master_schedules')
          .select()
          .eq('master_id', masterId)
          .order('day_of_week');

      if (response.isEmpty) {
        return [];
      }

      return response.map((data) => MasterSchedule.fromJson(data)).toList();
    } catch (e) {
      throw ServerFailure('Ошибка получения расписания: $e');
    }
  }

  /// Сохранить расписание мастера
  Future<void> saveMasterSchedule(String masterId, List<MasterSchedule> schedules) async {
    try {
      // Начинаем транзакцию - удаляем старое расписание
      await _supabase
          .from('master_schedules')
          .delete()
          .eq('master_id', masterId);

      // Подготавливаем данные для вставки
      final scheduleData = schedules.map((schedule) => {
        'master_id': masterId,
        'day_of_week': schedule.dayOfWeek,
        'is_working': schedule.isWorking,
        'start_time': schedule.isWorking ? schedule.startTime : null,
        'end_time': schedule.isWorking ? schedule.endTime : null,
      }).toList();

      // Вставляем новое расписание
      if (scheduleData.isNotEmpty) {
        await _supabase
            .from('master_schedules')
            .insert(scheduleData);
      }
    } catch (e) {
      throw ServerFailure('Ошибка сохранения расписания: $e');
    }
  }

  /// Создать стандартное расписание для нового мастера
  Future<void> createDefaultSchedule(String masterId) async {
    try {
      await _supabase.rpc('create_default_master_schedule', params: {
        'master_uuid': masterId,
      });
    } catch (e) {
      throw ServerFailure('Ошибка создания стандартного расписания: $e');
    }
  }

  /// Получить ID мастера текущего пользователя
  Future<String?> getCurrentMasterId() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerFailure('Пользователь не авторизован');
      }

      // Сначала проверяем, что пользователь является мастером
      final userProfile = await _supabase
          .from('user_profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (userProfile == null) {
        throw ServerFailure('Профиль пользователя не найден');
      }

      if (userProfile['role'] != 'master') {
        throw ServerFailure('Пользователь не является мастером');
      }

      // Проверяем существующую запись мастера
      var masterResponse = await _supabase
          .from('masters')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (masterResponse == null) {
        // Создаем запись мастера автоматически
        try {
          masterResponse = await _supabase
              .from('masters')
              .insert({
                'user_id': userId,
                'is_active': true,
              })
              .select('id')
              .single();
        } catch (e) {
          throw ServerFailure(
            'Не удалось создать профиль мастера. Возможно нужно применить миграцию RLS политик:\n'
            '20250102_fix_masters_rls_policies.sql\n\n'
            'Ошибка: $e'
          );
        }
      }

      return masterResponse['id'];
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Ошибка получения ID мастера: $e');
    }
  }


   /// Получить доступные временные слоты для указанной даты
   Future<List<TimeOfDay>> getAvailableTimeSlots(
     DateTime date, {
     Duration? serviceDuration,
   }) async {
     print('ScheduleService: Getting available slots for $date');
     try {
       final masterId = await getCurrentMasterId();
       print('ScheduleService: Master ID: $masterId');
       if (masterId == null) {
         throw ServerFailure('Мастер не найден');
       }

       return await getAvailableTimeSlotsForMaster(
         date,
         masterId: masterId,
         serviceDuration: serviceDuration,
       );
     } catch (e) {
       if (e is ServerFailure) rethrow;
       throw ServerFailure('Ошибка получения доступных слотов: $e');
     }
   }

   /// Получить доступные временные слоты для указанного мастера и даты
   Future<List<TimeOfDay>> getAvailableTimeSlotsForMaster(
     DateTime date, {
     required String masterId,
     Duration? serviceDuration,
   }) async {
     print('ScheduleService: Getting available slots for master $masterId on $date');
     try {
       final schedules = await getMasterSchedule(masterId);
       print('ScheduleService: Got ${schedules.length} schedule entries');
       
       // Если расписание пустое, создаем временное расписание
       if (schedules.isEmpty) {
         print('ScheduleService: No schedule found, using default schedule');
         return _getDefaultSlotsForDate(date, serviceDuration);
       }
       
       final dayOfWeek = _getDayOfWeek(date);
       print('ScheduleService: Looking for schedule for day: $dayOfWeek');
       
       // Находим расписание для указанного дня недели
       final daySchedule = schedules.where((s) => s.dayOfWeek == dayOfWeek).isNotEmpty
           ? schedules.where((s) => s.dayOfWeek == dayOfWeek).first
           : null;
       
       print('ScheduleService: Day schedule: $daySchedule');
       
       if (daySchedule == null || !daySchedule.isWorking) {
         print('ScheduleService: Non-working day, returning empty slots');
         return []; // Нерабочий день
       }

       // Парсим время начала и окончания работы
       final startTime = _parseTimeString(daySchedule.startTime);
       final endTime = _parseTimeString(daySchedule.endTime);
       
       print('ScheduleService: Start time: $startTime, End time: $endTime');
       
       if (startTime == null || endTime == null) {
         print('ScheduleService: Invalid time in schedule, returning empty slots');
         return []; // Некорректное время в расписании
       }

       // Генерируем временные слоты
       final slots = _generateTimeSlots(
         startTime: startTime,
         endTime: endTime,
         breakStartTime: _parseTimeString(daySchedule.breakStartTime),
         breakEndTime: _parseTimeString(daySchedule.breakEndTime),
         serviceDuration: serviceDuration ?? const Duration(minutes: 60),
         slotInterval: const Duration(minutes: 30),
       );

       print('ScheduleService: Generated ${slots.length} slots before filtering');

       // Фильтруем прошедшие слоты для сегодняшнего дня
       if (_isSameDay(date, DateTime.now())) {
         final now = TimeOfDay.now();
         final filteredSlots = slots.where((slot) => _isTimeAfter(slot, now)).toList();
         print('ScheduleService: Filtered to ${filteredSlots.length} slots after removing past times');
         return filteredSlots;
       }

       print('ScheduleService: Returning ${slots.length} slots');
       return slots;
     } catch (e) {
       if (e is ServerFailure) rethrow;
       throw ServerFailure('Ошибка получения доступных слотов для мастера: $e');
     }
   }

  /// Получить слоты с информацией о занятости
  Future<List<Map<String, dynamic>>> getAvailableSlotsWithOccupancy(
    DateTime date, {
    Duration? serviceDuration,
  }) async {
    print('ScheduleService: Getting slots with occupancy for $date');
    try {
      final masterId = await getCurrentMasterId();
      if (masterId == null) {
        throw ServerFailure('Мастер не найден');
      }

      return await getAvailableSlotsWithOccupancyForMaster(
        date,
        masterId: masterId,
        serviceDuration: serviceDuration,
      );
    } catch (e) {
      print('ScheduleService: Error getting slots with occupancy: $e');
      return [];
    }
  }

  /// Получить слоты с информацией о занятости для конкретного мастера
  Future<List<Map<String, dynamic>>> getAvailableSlotsWithOccupancyForMaster(
    DateTime date, {
    required String masterId,
    Duration? serviceDuration,
  }) async {
    print('ScheduleService: Getting slots with occupancy for master $masterId on $date');
    try {
      // Получаем все доступные слоты для мастера
      final allSlots = await getAvailableTimeSlotsForMaster(
        date, 
        masterId: masterId, 
        serviceDuration: serviceDuration,
      );

      // Получаем существующие записи на эту дату
      final existingBookings = await getBookingsForDate(masterId, date);
      print('ScheduleService: Found ${existingBookings.length} existing bookings for occupancy check');

      // Создаем список слотов с информацией о занятости
      final slotsWithOccupancy = <Map<String, dynamic>>[];
      
      for (final slot in allSlots) {
        final slotDateTime = DateTime(date.year, date.month, date.day, slot.hour, slot.minute);
        final serviceDur = serviceDuration ?? const Duration(minutes: 30);
        final slotEndTime = slotDateTime.add(serviceDur);
        
        // Проверяем занятость слота
        bool isOccupied = false;
        for (final booking in existingBookings) {
          final bookingStart = TimezoneUtils.toSamarkandTime(DateTime.parse(booking['start_time']));
          final bookingEnd = TimezoneUtils.toSamarkandTime(DateTime.parse(booking['end_time']));
          
          // Создаем время слота в самаркандском времени
          final slotSamarkandTime = TimezoneUtils.createSamarkandDateTime(date, slot);
          final slotEndSamarkandTime = slotSamarkandTime.add(serviceDur);
          
          // Проверяем пересечение
          if (slotSamarkandTime.isBefore(bookingEnd) && slotEndSamarkandTime.isAfter(bookingStart)) {
            isOccupied = true;
            print('ScheduleService: Slot ${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')} is occupied by booking ${TimezoneUtils.formatTimeForDisplay(bookingStart)} - ${TimezoneUtils.formatTimeForDisplay(bookingEnd)}');
            break;
          }
        }
        
        slotsWithOccupancy.add({
          'time': slot,
          'isOccupied': isOccupied,
          'startDateTime': slotDateTime,
          'endDateTime': slotEndTime,
        });
      }
      
      print('ScheduleService: Returning ${slotsWithOccupancy.length} slots with occupancy info');
      return slotsWithOccupancy;
    } catch (e) {
      print('ScheduleService: Error getting slots with occupancy for master: $e');
      return [];
    }
  }

  /// Получить существующие записи на указанную дату
  Future<List<Map<String, dynamic>>> getBookingsForDate(String masterId, DateTime date) async {
     try {
       // Создаем начало и конец дня в самаркандском времени, затем конвертируем в UTC для запроса
       final startOfDay = TimezoneUtils.createSamarkandDateTime(date, const TimeOfDay(hour: 0, minute: 0));
       final endOfDay = TimezoneUtils.createSamarkandDateTime(date, const TimeOfDay(hour: 23, minute: 59));
       
       final startOfDayUtc = TimezoneUtils.samarkandToUtc(startOfDay);
       final endOfDayUtc = TimezoneUtils.samarkandToUtc(endOfDay);

       final response = await _supabase
           .from('bookings')
           .select('start_time, end_time, status')
           .eq('master_id', masterId)
           .gte('start_time', startOfDayUtc.toIso8601String())
           .lte('start_time', endOfDayUtc.toIso8601String())
           .neq('status', 'cancelled');

       return List<Map<String, dynamic>>.from(response);
     } catch (e) {
       if (e is ServerFailure) rethrow;
       throw ServerFailure('Ошибка получения записей: $e');
     }
   }

   /// Проверить доступность временного слота
   Future<bool> isSlotAvailable(
     DateTime date, 
     TimeOfDay time, 
     Duration serviceDuration
   ) async {
     try {
       final masterId = await getCurrentMasterId();
      if (masterId == null) {
        throw ServerFailure('Мастер не найден');
      }
      final bookings = await getBookingsForDate(masterId, date);
       final slotStart = DateTime(date.year, date.month, date.day, time.hour, time.minute);
       final slotEnd = slotStart.add(serviceDuration);

       // Проверяем пересечение с существующими записями
       for (final booking in bookings) {
         final bookingStart = DateTime.parse(booking['start_time']);
         final bookingEnd = DateTime.parse(booking['end_time']);
         
         if (slotStart.isBefore(bookingEnd) && slotEnd.isAfter(bookingStart)) {
           return false; // Слот занят
         }
       }

       return true; // Слот свободен
     } catch (e) {
       // В случае ошибки считаем слот недоступным для безопасности
       return false;
     }
   }

   // Приватные методы
   
   String _getDayOfWeek(DateTime date) {
     const days = [
       'monday', 'tuesday', 'wednesday', 'thursday',
       'friday', 'saturday', 'sunday'
     ];
     return days[date.weekday - 1];
   }

   TimeOfDay? _parseTimeString(String? timeString) {
     if (timeString == null || timeString.isEmpty) return null;
     
     try {
       // Удаляем возможные лишние символы и разделяем по ':'
       final cleanTimeString = timeString.trim();
       final parts = cleanTimeString.split(':');
       
       // Поддерживаем форматы HH:MM и HH:MM:SS
       if (parts.length < 2 || parts.length > 3) {
         print('ScheduleService: Invalid time format: $timeString (parts: ${parts.length})');
         return null;
       }
       
       final hour = int.parse(parts[0]);
       final minute = int.parse(parts[1]);
       
       if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
         print('ScheduleService: Time out of range: $hour:$minute');
         return null;
       }
       
       print('ScheduleService: Parsed time $timeString to TimeOfDay($hour:$minute)');
       return TimeOfDay(hour: hour, minute: minute);
     } catch (e) {
       print('ScheduleService: Error parsing time $timeString: $e');
       return null;
     }
   }

   List<TimeOfDay> _generateTimeSlots({
     required TimeOfDay startTime,
     required TimeOfDay endTime,
     TimeOfDay? breakStartTime,
     TimeOfDay? breakEndTime,
     required Duration serviceDuration,
     required Duration slotInterval,
   }) {
     final slots = <TimeOfDay>[];
     var currentTime = startTime;

     while (_isTimeBefore(currentTime, _subtractDuration(endTime, serviceDuration))) {
       // Проверяем, не попадает ли слот на перерыв
       if (!_isInBreakTime(currentTime, serviceDuration, breakStartTime, breakEndTime)) {
         slots.add(currentTime);
       }
       currentTime = _addDuration(currentTime, slotInterval);
     }

     return slots;
   }

   bool _isInBreakTime(
     TimeOfDay slotStart, 
     Duration serviceDuration,
     TimeOfDay? breakStart,
     TimeOfDay? breakEnd,
   ) {
     if (breakStart == null || breakEnd == null) return false;
     
     final slotEnd = _addDuration(slotStart, serviceDuration);
     
     // Проверяем пересечение времени услуги с перерывом
     return _timesOverlap(slotStart, slotEnd, breakStart, breakEnd);
   }

   bool _timesOverlap(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
     final start1Minutes = start1.hour * 60 + start1.minute;
     final end1Minutes = end1.hour * 60 + end1.minute;
     final start2Minutes = start2.hour * 60 + start2.minute;
     final end2Minutes = end2.hour * 60 + end2.minute;

     return start1Minutes < end2Minutes && end1Minutes > start2Minutes;
   }

   bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
     final minutes1 = time1.hour * 60 + time1.minute;
     final minutes2 = time2.hour * 60 + time2.minute;
     return minutes1 < minutes2;
   }

   bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
     final minutes1 = time1.hour * 60 + time1.minute;
     final minutes2 = time2.hour * 60 + time2.minute;
     return minutes1 > minutes2;
   }

   TimeOfDay _addDuration(TimeOfDay time, Duration duration) {
     final totalMinutes = time.hour * 60 + time.minute + duration.inMinutes;
     return TimeOfDay(
       hour: (totalMinutes ~/ 60) % 24,
       minute: totalMinutes % 60,
     );
   }

   TimeOfDay _subtractDuration(TimeOfDay time, Duration duration) {
     final totalMinutes = time.hour * 60 + time.minute - duration.inMinutes;
     if (totalMinutes < 0) {
       return const TimeOfDay(hour: 0, minute: 0);
     }
     return TimeOfDay(
       hour: (totalMinutes ~/ 60) % 24,
       minute: totalMinutes % 60,
     );
   }

   bool _isSameDay(DateTime a, DateTime b) {
     return a.year == b.year && a.month == b.month && a.day == b.day;
   }

   /// Временные стандартные слоты если расписание не настроено
   List<TimeOfDay> _getDefaultSlotsForDate(DateTime date, Duration? serviceDuration) {
     // Воскресенье - выходной
     if (date.weekday == 7) {
       return [];
     }

     // Стандартные рабочие часы: 9:00-18:00 пн-пт, 10:00-17:00 сб
     final startTime = date.weekday == 6 
         ? const TimeOfDay(hour: 10, minute: 0)  // Суббота
         : const TimeOfDay(hour: 9, minute: 0);   // Пн-Пт
     
     final endTime = date.weekday == 6
         ? const TimeOfDay(hour: 17, minute: 0)   // Суббота  
         : const TimeOfDay(hour: 18, minute: 0);  // Пн-Пт

     // Обеденный перерыв: 13:00-14:00
     final breakStart = const TimeOfDay(hour: 13, minute: 0);
     final breakEnd = const TimeOfDay(hour: 14, minute: 0);

     final slots = _generateTimeSlots(
       startTime: startTime,
       endTime: endTime,
       breakStartTime: breakStart,
       breakEndTime: breakEnd,
       serviceDuration: serviceDuration ?? const Duration(minutes: 60),
       slotInterval: const Duration(minutes: 30),
     );

     // Фильтруем прошедшие слоты для сегодняшнего дня
     if (_isSameDay(date, DateTime.now())) {
       final now = TimeOfDay.now();
       return slots.where((slot) => _isTimeAfter(slot, now)).toList();
     }

     return slots;
   }
 }