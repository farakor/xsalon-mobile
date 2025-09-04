class Client {
  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime createdAt;
  final DateTime? lastVisit;
  final int totalVisits;
  final double totalSpent;
  final int loyaltyPoints;
  final String loyaltyLevel;
  final String? notes;
  final List<String> preferredServices;
  final ClientStatus status;

  const Client({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    required this.createdAt,
    this.lastVisit,
    required this.totalVisits,
    required this.totalSpent,
    required this.loyaltyPoints,
    this.loyaltyLevel = 'Новичок',
    this.notes,
    required this.preferredServices,
    required this.status,
  });

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get displayPhone {
    if (phone == null) return 'Не указан';
    return phone!;
  }

  String get displayEmail {
    if (email == null) return 'Не указан';
    return email!;
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }



  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastVisit: json['last_visit'] != null 
          ? DateTime.parse(json['last_visit'] as String)
          : null,
      totalVisits: json['total_visits'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
      loyaltyLevel: json['loyalty_level'] as String? ?? 'Новичок',
      notes: json['notes'] as String?,
      preferredServices: (json['preferred_services'] as List<dynamic>?)
          ?.map((e) => e as String).toList() ?? [],
      status: ClientStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ClientStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
      'last_visit': lastVisit?.toIso8601String(),
      'total_visits': totalVisits,
      'total_spent': totalSpent,
      'loyalty_points': loyaltyPoints,
      'loyalty_level': loyaltyLevel,
      'notes': notes,
      'preferred_services': preferredServices,
      'status': status.name,
    };
  }

  Client copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
    DateTime? createdAt,
    DateTime? lastVisit,
    int? totalVisits,
    double? totalSpent,
    int? loyaltyPoints,
    String? loyaltyLevel,
    String? notes,
    List<String>? preferredServices,
    ClientStatus? status,
  }) {
    return Client(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
      totalVisits: totalVisits ?? this.totalVisits,
      totalSpent: totalSpent ?? this.totalSpent,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyLevel: loyaltyLevel ?? this.loyaltyLevel,
      notes: notes ?? this.notes,
      preferredServices: preferredServices ?? this.preferredServices,
      status: status ?? this.status,
    );
  }
}

enum ClientStatus {
  active,
  inactive,
  blocked,
}

extension ClientStatusExtension on ClientStatus {
  String get displayName {
    switch (this) {
      case ClientStatus.active:
        return 'Активный';
      case ClientStatus.inactive:
        return 'Неактивный';
      case ClientStatus.blocked:
        return 'Заблокирован';
    }
  }

  String get color {
    switch (this) {
      case ClientStatus.active:
        return '#4CAF50'; // Green
      case ClientStatus.inactive:
        return '#FF9800'; // Orange
      case ClientStatus.blocked:
        return '#F44336'; // Red
    }
  }
}

class ClientVisit {
  final String id;
  final String clientId;
  final DateTime visitDate;
  final List<String> services;
  final double totalAmount;
  final String masterId;
  final String masterName;
  final String? notes;
  final int loyaltyPointsEarned;

  const ClientVisit({
    required this.id,
    required this.clientId,
    required this.visitDate,
    required this.services,
    required this.totalAmount,
    required this.masterId,
    required this.masterName,
    this.notes,
    required this.loyaltyPointsEarned,
  });

  factory ClientVisit.fromJson(Map<String, dynamic> json) {
    return ClientVisit(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      visitDate: DateTime.parse(json['visit_date'] as String),
      services: (json['services'] as List<dynamic>)
          .map((e) => e as String).toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      masterId: json['master_id'] as String,
      masterName: json['master_name'] as String,
      notes: json['notes'] as String?,
      loyaltyPointsEarned: json['loyalty_points_earned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'visit_date': visitDate.toIso8601String(),
      'services': services,
      'total_amount': totalAmount,
      'master_id': masterId,
      'master_name': masterName,
      'notes': notes,
      'loyalty_points_earned': loyaltyPointsEarned,
    };
  }
}
