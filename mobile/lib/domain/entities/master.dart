class MasterEntity {
  final String id;
  final String userId;
  final String fullName;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final List<String> specialization;
  final String? description;
  final int experienceYears;
  final double rating;
  final int reviewsCount;
  final Map<String, dynamic> workingHours;
  final int breakDurationMinutes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MasterEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    this.phone,
    this.email,
    this.avatarUrl,
    required this.specialization,
    this.description,
    required this.experienceYears,
    required this.rating,
    required this.reviewsCount,
    required this.workingHours,
    required this.breakDurationMinutes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedRating => rating.toStringAsFixed(1);

  String get formattedExperience {
    if (experienceYears == 0) return 'Новичок';
    if (experienceYears == 1) return '1 год опыта';
    if (experienceYears < 5) return '$experienceYears года опыта';
    return '$experienceYears лет опыта';
  }

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return fullName.isNotEmpty ? fullName[0] : 'M';
  }

  MasterEntity copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    List<String>? specialization,
    String? description,
    int? experienceYears,
    double? rating,
    int? reviewsCount,
    Map<String, dynamic>? workingHours,
    int? breakDurationMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MasterEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      specialization: specialization ?? this.specialization,
      description: description ?? this.description,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      workingHours: workingHours ?? this.workingHours,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MasterEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MasterEntity(id: $id, fullName: $fullName, rating: $rating)';
  }
}

class MasterServiceEntity {
  final String id;
  final String masterId;
  final String serviceId;
  final double? customPrice;
  final DateTime createdAt;

  const MasterServiceEntity({
    required this.id,
    required this.masterId,
    required this.serviceId,
    this.customPrice,
    required this.createdAt,
  });

  MasterServiceEntity copyWith({
    String? id,
    String? masterId,
    String? serviceId,
    double? customPrice,
    DateTime? createdAt,
  }) {
    return MasterServiceEntity(
      id: id ?? this.id,
      masterId: masterId ?? this.masterId,
      serviceId: serviceId ?? this.serviceId,
      customPrice: customPrice ?? this.customPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MasterServiceEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MasterServiceEntity(id: $id, masterId: $masterId, serviceId: $serviceId)';
  }
}
