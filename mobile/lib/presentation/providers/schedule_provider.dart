import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/schedule_model.dart';
import '../../data/services/schedule_service.dart';

// Состояние загрузки расписания
enum ScheduleStatus {
  initial,
  loading,
  loaded,
  error,
}

// Модель состояния расписания
class ScheduleState {
  final ScheduleStatus status;
  final List<MasterSchedule> masterSchedules;
  final Map<DateTime, List<TimeOfDay>> availableSlots;
  final String? errorMessage;

  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.masterSchedules = const [],
    this.availableSlots = const {},
    this.errorMessage,
  });

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<MasterSchedule>? masterSchedules,
    Map<DateTime, List<TimeOfDay>>? availableSlots,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      masterSchedules: masterSchedules ?? this.masterSchedules,
      availableSlots: availableSlots ?? this.availableSlots,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Провайдер для управления расписанием
class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier(this._scheduleService) : super(const ScheduleState());

  final ScheduleService _scheduleService;

  // Загрузка расписания мастера
  Future<void> loadMasterSchedule() async {
    print('ScheduleProvider: Loading master schedule...');
    state = state.copyWith(status: ScheduleStatus.loading);

    try {
      final masterId = await _scheduleService.getCurrentMasterId();
      print('ScheduleProvider: Master ID: $masterId');
      if (masterId == null) {
        throw Exception('Мастер не найден');
      }

      final schedules = await _scheduleService.getMasterSchedule(masterId);
      print('ScheduleProvider: Loaded ${schedules.length} schedules');
      for (final schedule in schedules) {
        print('  ${schedule.dayOfWeek}: ${schedule.isWorking ? '${schedule.startTime}-${schedule.endTime}' : 'не работает'}');
      }
      
      state = state.copyWith(
        status: ScheduleStatus.loaded,
        masterSchedules: schedules,
        errorMessage: null,
      );
    } catch (error) {
      print('ScheduleProvider: Error loading master schedule: $error');
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Загрузка расписания конкретного мастера по ID
  Future<void> loadMasterScheduleById(String masterId) async {
    print('ScheduleProvider: Loading master schedule by ID: $masterId');
    state = state.copyWith(status: ScheduleStatus.loading);

    try {
      final schedules = await _scheduleService.getMasterSchedule(masterId);
      print('ScheduleProvider: Loaded ${schedules.length} schedules for master $masterId');
      for (final schedule in schedules) {
        print('  ${schedule.dayOfWeek}: ${schedule.isWorking ? '${schedule.startTime}-${schedule.endTime}' : 'не работает'}');
      }
      
      state = state.copyWith(
        status: ScheduleStatus.loaded,
        masterSchedules: schedules,
        errorMessage: null,
      );
    } catch (error) {
      print('ScheduleProvider: Error loading master schedule by ID: $error');
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Сохранение расписания мастера
  Future<void> saveMasterSchedule(List<MasterSchedule> schedules) async {
    state = state.copyWith(status: ScheduleStatus.loading);

    try {
      final masterId = await _scheduleService.getCurrentMasterId();
      
      if (masterId == null) {
        throw Exception('Не удалось определить мастера');
      }

      await _scheduleService.saveMasterSchedule(masterId, schedules);
      
      state = state.copyWith(
        status: ScheduleStatus.loaded,
        masterSchedules: schedules,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Получить расписание для определенного дня недели
  MasterSchedule? getScheduleForDay(String dayOfWeek) {
    try {
      return state.masterSchedules.firstWhere(
        (schedule) => schedule.dayOfWeek == dayOfWeek,
      );
    } catch (e) {
      return null;
    }
  }

  // Загрузка доступных слотов для указанной даты
  Future<void> loadAvailableSlots(
    DateTime date, {
    Duration? serviceDuration,
  }) async {
    print('ScheduleProvider: Loading available slots for $date with duration ${serviceDuration?.inMinutes} minutes');
    try {
      final slots = await _scheduleService.getAvailableTimeSlots(
        date,
        serviceDuration: serviceDuration,
      );
      
      print('ScheduleProvider: Found ${slots.length} available slots: ${slots.map((s) => '${s.hour}:${s.minute.toString().padLeft(2, '0')}').join(', ')}');
      
      final updatedSlots = Map<DateTime, List<TimeOfDay>>.from(state.availableSlots);
      final dateKey = DateTime(date.year, date.month, date.day);
      updatedSlots[dateKey] = slots;
      
      print('ScheduleProvider: Saving ${slots.length} slots for dateKey: $dateKey');
      print('ScheduleProvider: Current cache keys: ${updatedSlots.keys.toList()}');
      
      state = state.copyWith(
        availableSlots: updatedSlots,
        status: ScheduleStatus.loaded, // Принудительно обновляем статус
      );
    } catch (error) {
      print('ScheduleProvider: Error loading available slots: $error');
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Получить доступные слоты для даты из кэша
  List<TimeOfDay> getAvailableSlotsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final slots = state.availableSlots[dateKey] ?? [];
    print('ScheduleProvider: getAvailableSlotsForDate for $dateKey: ${slots.length} slots');
    return slots;
  }

  // Загрузка слотов с информацией о занятости
  Future<List<Map<String, dynamic>>> loadSlotsWithOccupancy(
    DateTime date, {
    Duration? serviceDuration,
  }) async {
    print('ScheduleProvider: Loading slots with occupancy for $date');
    try {
      final slotsWithOccupancy = await _scheduleService.getAvailableSlotsWithOccupancy(
        date,
        serviceDuration: serviceDuration,
      );
      
      print('ScheduleProvider: Found ${slotsWithOccupancy.length} slots with occupancy info');
      return slotsWithOccupancy;
    } catch (error) {
      print('ScheduleProvider: Error loading slots with occupancy: $error');
      return [];
    }
  }

  // Загрузка доступных слотов для конкретного мастера
  Future<void> loadAvailableSlotsForMaster(
    DateTime date, {
    required String masterId,
    Duration? serviceDuration,
  }) async {
    print('ScheduleProvider: Loading available slots for master $masterId on $date with duration ${serviceDuration?.inMinutes} minutes');
    try {
      final slots = await _scheduleService.getAvailableTimeSlotsForMaster(
        date,
        masterId: masterId,
        serviceDuration: serviceDuration,
      );
      
      print('ScheduleProvider: Found ${slots.length} available slots for master: ${slots.map((s) => '${s.hour}:${s.minute.toString().padLeft(2, '0')}').join(', ')}');
      
      final updatedSlots = Map<DateTime, List<TimeOfDay>>.from(state.availableSlots);
      final dateKey = DateTime(date.year, date.month, date.day);
      updatedSlots[dateKey] = slots;
      
      print('ScheduleProvider: Saving ${slots.length} slots for dateKey: $dateKey');
      print('ScheduleProvider: Current cache keys: ${updatedSlots.keys.toList()}');
      
      state = state.copyWith(
        availableSlots: updatedSlots,
        status: ScheduleStatus.loaded, // Принудительно обновляем статус
      );
    } catch (error) {
      print('ScheduleProvider: Error loading available slots for master: $error');
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Загрузка слотов с информацией о занятости для конкретного мастера
  Future<List<Map<String, dynamic>>> loadSlotsWithOccupancyForMaster(
    DateTime date, {
    required String masterId,
    Duration? serviceDuration,
  }) async {
    print('ScheduleProvider: Loading slots with occupancy for master $masterId on $date');
    try {
      final slotsWithOccupancy = await _scheduleService.getAvailableSlotsWithOccupancyForMaster(
        date,
        masterId: masterId,
        serviceDuration: serviceDuration,
      );
      
      print('ScheduleProvider: Found ${slotsWithOccupancy.length} slots with occupancy info for master');
      return slotsWithOccupancy;
    } catch (error) {
      print('ScheduleProvider: Error loading slots with occupancy for master: $error');
      return [];
    }
  }

  // Проверить доступность слота
  Future<bool> checkSlotAvailability(
    DateTime date, 
    TimeOfDay time, 
    Duration serviceDuration
  ) async {
    try {
      return await _scheduleService.isSlotAvailable(date, time, serviceDuration);
    } catch (e) {
      return false; // В случае ошибки считаем слот недоступным
    }
  }
}

// Провайдеры
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  final scheduleService = ref.watch(scheduleServiceProvider);
  return ScheduleNotifier(scheduleService);
});

// Вспомогательные провайдеры
final masterSchedulesProvider = Provider<List<MasterSchedule>>((ref) {
  final scheduleState = ref.watch(scheduleProvider);
  return scheduleState.masterSchedules;
});

final isScheduleLoadingProvider = Provider<bool>((ref) {
  final scheduleState = ref.watch(scheduleProvider);
  return scheduleState.status == ScheduleStatus.loading;
});

final scheduleErrorProvider = Provider<String?>((ref) {
  final scheduleState = ref.watch(scheduleProvider);
  return scheduleState.errorMessage;
});

// Провайдер для получения расписания для конкретного дня недели
final scheduleForDayProvider = Provider.family<MasterSchedule?, String>((ref, dayOfWeek) {
  final scheduleNotifier = ref.watch(scheduleProvider.notifier);
  return scheduleNotifier.getScheduleForDay(dayOfWeek);
});

// Провайдер для получения доступных слотов для конкретной даты
final availableSlotsProvider = Provider.family<List<TimeOfDay>, DateTime>((ref, date) {
  // Следим за изменениями состояния для автообновления
  final scheduleState = ref.watch(scheduleProvider);
  
  // Нормализуем дату до 00:00:00 для правильного поиска в кэше
  final normalizedDate = DateTime(date.year, date.month, date.day);
  
  // Получаем слоты напрямую из состояния
  final slots = scheduleState.availableSlots[normalizedDate] ?? [];
  
  print('availableSlotsProvider: Input date: $date, Normalized: $normalizedDate, State status: ${scheduleState.status}, Returning ${slots.length} slots');
  return slots;
});

// Асинхронный провайдер для проверки доступности слота
final slotAvailabilityProvider = FutureProvider.family<bool, ({DateTime date, TimeOfDay time, Duration duration})>((ref, params) {
  final scheduleNotifier = ref.watch(scheduleProvider.notifier);
  return scheduleNotifier.checkSlotAvailability(params.date, params.time, params.duration);
});
