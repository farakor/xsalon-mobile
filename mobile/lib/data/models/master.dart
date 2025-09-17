import '../../domain/entities/master.dart';

class MasterModel extends MasterEntity {
  const MasterModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.phone,
    super.email,
    super.avatarUrl,
    required super.specialization,
    super.description,
    required super.experienceYears,
    required super.rating,
    required super.reviewsCount,
    required super.workingHours,
    required super.breakDurationMinutes,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MasterModel.fromJson(Map<String, dynamic> json) {
    return MasterModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      specialization: (json['specialization'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      description: json['description'] as String?,
      experienceYears: json['experience_years'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      workingHours: json['working_hours'] as Map<String, dynamic>? ?? {},
      breakDurationMinutes: json['break_duration_minutes'] as int? ?? 15,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Создание из данных с джойном user_profiles
  factory MasterModel.fromJoinedJson(Map<String, dynamic> json) {
    return MasterModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['user_profiles']?['full_name'] as String? ?? 
                json['full_name'] as String? ?? '',
      phone: json['user_profiles']?['phone'] as String? ?? 
             json['phone'] as String?,
      email: json['user_profiles']?['email'] as String? ?? 
             json['email'] as String?,
      avatarUrl: json['user_profiles']?['avatar_url'] as String? ?? 
                 json['avatar_url'] as String?,
      specialization: (json['specialization'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      description: json['description'] as String?,
      experienceYears: json['experience_years'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      workingHours: json['working_hours'] as Map<String, dynamic>? ?? {},
      breakDurationMinutes: json['break_duration_minutes'] as int? ?? 15,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'specialization': specialization,
      'description': description,
      'experience_years': experienceYears,
      'rating': rating,
      'reviews_count': reviewsCount,
      'working_hours': workingHours,
      'break_duration_minutes': breakDurationMinutes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  MasterModel copyWith({
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
    return MasterModel(
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
}

class MasterServiceModel extends MasterServiceEntity {
  const MasterServiceModel({
    required super.id,
    required super.masterId,
    required super.serviceId,
    super.customPrice,
    required super.createdAt,
  });

  factory MasterServiceModel.fromJson(Map<String, dynamic> json) {
    return MasterServiceModel(
      id: json['id'] as String,
      masterId: json['master_id'] as String,
      serviceId: json['service_id'] as String,
      customPrice: (json['custom_price'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'master_id': masterId,
      'service_id': serviceId,
      'custom_price': customPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  MasterServiceModel copyWith({
    String? id,
    String? masterId,
    String? serviceId,
    double? customPrice,
    DateTime? createdAt,
  }) {
    return MasterServiceModel(
      id: id ?? this.id,
      masterId: masterId ?? this.masterId,
      serviceId: serviceId ?? this.serviceId,
      customPrice: customPrice ?? this.customPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
