import 'package:flutter/material.dart';

class StaffStatistics {
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final double totalRevenue;
  final double averageRating;
  final int totalClients;
  final int repeatClients;
  final Map<String, int> serviceStats;
  final Map<String, double> monthlyRevenue;
  final DateTime periodStart;
  final DateTime periodEnd;

  const StaffStatistics({
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.totalRevenue,
    required this.averageRating,
    required this.totalClients,
    required this.repeatClients,
    required this.serviceStats,
    required this.monthlyRevenue,
    required this.periodStart,
    required this.periodEnd,
  });

  double get completionRate {
    if (totalAppointments == 0) return 0.0;
    return (completedAppointments / totalAppointments) * 100;
  }

  double get cancellationRate {
    if (totalAppointments == 0) return 0.0;
    return (cancelledAppointments / totalAppointments) * 100;
  }

  double get repeatClientRate {
    if (totalClients == 0) return 0.0;
    return (repeatClients / totalClients) * 100;
  }

  double get averageRevenuePerClient {
    if (totalClients == 0) return 0.0;
    return totalRevenue / totalClients;
  }

  String get mostPopularService {
    if (serviceStats.isEmpty) return 'Нет данных';
    return serviceStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  factory StaffStatistics.fromJson(Map<String, dynamic> json) {
    return StaffStatistics(
      totalAppointments: json['total_appointments'] as int? ?? 0,
      completedAppointments: json['completed_appointments'] as int? ?? 0,
      cancelledAppointments: json['cancelled_appointments'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalClients: json['total_clients'] as int? ?? 0,
      repeatClients: json['repeat_clients'] as int? ?? 0,
      serviceStats: Map<String, int>.from(json['service_stats'] ?? {}),
      monthlyRevenue: Map<String, double>.from(
        (json['monthly_revenue'] as Map?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ?? {},
      ),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_appointments': totalAppointments,
      'completed_appointments': completedAppointments,
      'cancelled_appointments': cancelledAppointments,
      'total_revenue': totalRevenue,
      'average_rating': averageRating,
      'total_clients': totalClients,
      'repeat_clients': repeatClients,
      'service_stats': serviceStats,
      'monthly_revenue': monthlyRevenue,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }
}

class WorkingHours {
  final Map<int, DaySchedule> schedule; // weekday (1-7) -> schedule

  const WorkingHours({required this.schedule});

  bool isWorkingDay(int weekday) {
    return schedule.containsKey(weekday) && schedule[weekday]!.isWorking;
  }

  DaySchedule? getScheduleForDay(int weekday) {
    return schedule[weekday];
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    final scheduleMap = <int, DaySchedule>{};
    for (final entry in json.entries) {
      final weekday = int.parse(entry.key);
      scheduleMap[weekday] = DaySchedule.fromJson(entry.value);
    }
    return WorkingHours(schedule: scheduleMap);
  }

  Map<String, dynamic> toJson() {
    return schedule.map(
      (key, value) => MapEntry(key.toString(), value.toJson()),
    );
  }
}

class DaySchedule {
  final bool isWorking;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final TimeOfDay? breakStart;
  final TimeOfDay? breakEnd;

  const DaySchedule({
    required this.isWorking,
    this.startTime,
    this.endTime,
    this.breakStart,
    this.breakEnd,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      isWorking: json['is_working'] as bool? ?? false,
      startTime: json['start_time'] != null 
          ? _parseTimeOfDay(json['start_time'])
          : null,
      endTime: json['end_time'] != null 
          ? _parseTimeOfDay(json['end_time'])
          : null,
      breakStart: json['break_start'] != null 
          ? _parseTimeOfDay(json['break_start'])
          : null,
      breakEnd: json['break_end'] != null 
          ? _parseTimeOfDay(json['break_end'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_working': isWorking,
      'start_time': startTime != null ? _formatTimeOfDay(startTime!) : null,
      'end_time': endTime != null ? _formatTimeOfDay(endTime!) : null,
      'break_start': breakStart != null ? _formatTimeOfDay(breakStart!) : null,
      'break_end': breakEnd != null ? _formatTimeOfDay(breakEnd!) : null,
    };
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
