class Appointment {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String serviceId;
  final String serviceName;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final double price;
  final String? notes; // client notes
  final String? masterNotes; // master notes
  final String? clientAvatarUrl;

  const Appointment({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.serviceId,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.price,
    this.notes,
    this.masterNotes,
    this.clientAvatarUrl,
  });

  Duration get duration => endTime.difference(startTime);

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      clientPhone: json['client_phone'] as String,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String?,
      masterNotes: json['master_notes'] as String?,
      clientAvatarUrl: json['client_avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'service_id': serviceId,
      'service_name': serviceName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.name,
      'price': price,
      'notes': notes,
      'master_notes': masterNotes,
      'client_avatar_url': clientAvatarUrl,
    };
  }

  Appointment copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? serviceId,
    String? serviceName,
    DateTime? startTime,
    DateTime? endTime,
    AppointmentStatus? status,
    double? price,
    String? notes,
    String? masterNotes,
    String? clientAvatarUrl,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      masterNotes: masterNotes ?? this.masterNotes,
      clientAvatarUrl: clientAvatarUrl ?? this.clientAvatarUrl,
    );
  }
}

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Ожидает';
      case AppointmentStatus.confirmed:
        return 'Подтверждено';
      case AppointmentStatus.inProgress:
        return 'В процессе';
      case AppointmentStatus.completed:
        return 'Завершено';
      case AppointmentStatus.cancelled:
        return 'Отменено';
      case AppointmentStatus.noShow:
        return 'Не явился';
    }
  }

  String get color {
    switch (this) {
      case AppointmentStatus.pending:
        return '#FFA726'; // Orange
      case AppointmentStatus.confirmed:
        return '#66BB6A'; // Green
      case AppointmentStatus.inProgress:
        return '#42A5F5'; // Blue
      case AppointmentStatus.completed:
        return '#4CAF50'; // Dark Green
      case AppointmentStatus.cancelled:
        return '#EF5350'; // Red
      case AppointmentStatus.noShow:
        return '#BDBDBD'; // Grey
    }
  }
}
