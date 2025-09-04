class MasterSchedule {
  final String id;
  final String masterId;
  final String organizationId;
  final String dayOfWeek;
  final bool isWorking;
  final String? startTime;
  final String? endTime;
  final String? breakStartTime;
  final String? breakEndTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MasterSchedule({
    required this.id,
    required this.masterId,
    required this.organizationId,
    required this.dayOfWeek,
    required this.isWorking,
    this.startTime,
    this.endTime,
    this.breakStartTime,
    this.breakEndTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MasterSchedule.fromJson(Map<String, dynamic> json) {
    return MasterSchedule(
      id: json['id'],
      masterId: json['master_id'],
      organizationId: json['organization_id'],
      dayOfWeek: json['day_of_week'],
      isWorking: json['is_working'] ?? false,
      startTime: json['start_time'],
      endTime: json['end_time'],
      breakStartTime: json['break_start_time'],
      breakEndTime: json['break_end_time'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'master_id': masterId,
      'organization_id': organizationId,
      'day_of_week': dayOfWeek,
      'is_working': isWorking,
      'start_time': startTime,
      'end_time': endTime,
      'break_start_time': breakStartTime,
      'break_end_time': breakEndTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MasterSchedule copyWith({
    String? id,
    String? masterId,
    String? organizationId,
    String? dayOfWeek,
    bool? isWorking,
    String? startTime,
    String? endTime,
    String? breakStartTime,
    String? breakEndTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MasterSchedule(
      id: id ?? this.id,
      masterId: masterId ?? this.masterId,
      organizationId: organizationId ?? this.organizationId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isWorking: isWorking ?? this.isWorking,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      breakEndTime: breakEndTime ?? this.breakEndTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MasterSchedule &&
        other.id == id &&
        other.masterId == masterId &&
        other.organizationId == organizationId &&
        other.dayOfWeek == dayOfWeek &&
        other.isWorking == isWorking &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.breakStartTime == breakStartTime &&
        other.breakEndTime == breakEndTime &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        masterId.hashCode ^
        organizationId.hashCode ^
        dayOfWeek.hashCode ^
        isWorking.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        breakStartTime.hashCode ^
        breakEndTime.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'MasterSchedule(id: $id, masterId: $masterId, organizationId: $organizationId, dayOfWeek: $dayOfWeek, isWorking: $isWorking, startTime: $startTime, endTime: $endTime, breakStartTime: $breakStartTime, breakEndTime: $breakEndTime, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// Класс для создания нового расписания
class CreateMasterSchedule {
  final String dayOfWeek;
  final bool isWorking;
  final String? startTime;
  final String? endTime;
  final String? breakStartTime;
  final String? breakEndTime;

  const CreateMasterSchedule({
    required this.dayOfWeek,
    required this.isWorking,
    this.startTime,
    this.endTime,
    this.breakStartTime,
    this.breakEndTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'is_working': isWorking,
      'start_time': startTime,
      'end_time': endTime,
      'break_start_time': breakStartTime,
      'break_end_time': breakEndTime,
    };
  }
}

/// Утилиты для работы с днями недели
class DayOfWeekUtils {
  static const Map<String, String> dayMapping = {
    'пн.': 'monday',
    'вт.': 'tuesday',
    'ср.': 'wednesday',
    'чт.': 'thursday',
    'пт.': 'friday',
    'сб.': 'saturday',
    'вс.': 'sunday',
  };

  static const Map<String, String> reverseDayMapping = {
    'monday': 'пн.',
    'tuesday': 'вт.',
    'wednesday': 'ср.',
    'thursday': 'чт.',
    'friday': 'пт.',
    'saturday': 'сб.',
    'sunday': 'вс.',
  };

  static String russianToEnglish(String russianDay) {
    return dayMapping[russianDay] ?? russianDay;
  }

  static String englishToRussian(String englishDay) {
    return reverseDayMapping[englishDay] ?? englishDay;
  }

  static List<String> get allRussianDays => dayMapping.keys.toList();
  static List<String> get allEnglishDays => dayMapping.values.toList();
}
