import 'package:flutter/material.dart';

class WorkingHours {
  final String dayOfWeek; // 'monday', 'tuesday', etc.
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isWorkingDay;
  final List<Break> breaks;

  const WorkingHours({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isWorkingDay,
    this.breaks = const [],
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      dayOfWeek: json['day_of_week'] as String,
      startTime: _timeFromString(json['start_time'] as String),
      endTime: _timeFromString(json['end_time'] as String),
      isWorkingDay: json['is_working_day'] as bool? ?? true,
      breaks: (json['breaks'] as List<dynamic>?)
          ?.map((breakJson) => Break.fromJson(breakJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'start_time': _timeToString(startTime),
      'end_time': _timeToString(endTime),
      'is_working_day': isWorkingDay,
      'breaks': breaks.map((b) => b.toJson()).toList(),
    };
  }

  static TimeOfDay _timeFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Получить все доступные временные слоты для этого дня
  List<TimeOfDay> getAvailableSlots({
    Duration slotDuration = const Duration(minutes: 30),
    Duration serviceDuration = const Duration(minutes: 60),
  }) {
    if (!isWorkingDay) return [];

    final slots = <TimeOfDay>[];
    var currentTime = startTime;

    while (_isTimeBeforeOrEqual(currentTime, _subtractDuration(endTime, serviceDuration))) {
      // Проверяем, не попадает ли слот на перерыв
      if (!_isInBreak(currentTime, serviceDuration)) {
        slots.add(currentTime);
      }
      currentTime = _addDuration(currentTime, slotDuration);
    }

    return slots;
  }

  bool _isInBreak(TimeOfDay startTime, Duration serviceDuration) {
    final endTime = _addDuration(startTime, serviceDuration);
    
    for (final breakPeriod in breaks) {
      // Проверяем пересечение времени услуги с перерывом
      if (_timesOverlap(startTime, endTime, breakPeriod.startTime, breakPeriod.endTime)) {
        return true;
      }
    }
    return false;
  }

  bool _timesOverlap(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;

    return start1Minutes < end2Minutes && end1Minutes > start2Minutes;
  }

  bool _isTimeBeforeOrEqual(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1 <= minutes2;
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
    return TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }
}

class Break {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? description;

  const Break({
    required this.startTime,
    required this.endTime,
    this.description,
  });

  factory Break.fromJson(Map<String, dynamic> json) {
    return Break(
      startTime: WorkingHours._timeFromString(json['start_time'] as String),
      endTime: WorkingHours._timeFromString(json['end_time'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': WorkingHours._timeToString(startTime),
      'end_time': WorkingHours._timeToString(endTime),
      'description': description,
    };
  }
}

class Booking {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String clientId;
  final String masterId;
  final List<String> serviceIds;
  final String status;

  const Booking({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.clientId,
    required this.masterId,
    required this.serviceIds,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      clientId: json['client_id'] as String,
      masterId: json['master_id'] as String,
      serviceIds: List<String>.from(json['service_ids'] as List),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'client_id': clientId,
      'master_id': masterId,
      'service_ids': serviceIds,
      'status': status,
    };
  }
}
