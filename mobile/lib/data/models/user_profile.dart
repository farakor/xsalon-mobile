class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final String role;
  final String? organizationId;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    required this.role,
    this.organizationId,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      role: json['role'] as String? ?? 'client',
      organizationId: json['organization_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
      'role': role,
      'organization_id': organizationId,
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? role,
    String? organizationId,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Проверка ролей
  bool get isClient => role == 'client';
  bool get isMaster => role == 'master';
  bool get isAdmin => role == 'admin';
  bool get isOwner => role == 'owner';
  bool get isStaff => isMaster || isAdmin || isOwner;

  // Отображаемое имя
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    if (email != null && email!.isNotEmpty) {
      return email!;
    }
    if (phone != null && phone!.isNotEmpty) {
      return phone!;
    }
    return 'Пользователь';
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, fullName: $fullName, phone: $phone, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
