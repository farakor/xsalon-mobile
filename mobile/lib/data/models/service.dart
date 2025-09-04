class Service {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final double price;
  final int durationMinutes;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.durationMinutes,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Duration get duration => Duration(minutes: durationMinutes);

  String get formattedPrice => '${(price / 1000).toStringAsFixed(0)} тыс. сум';

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}ч ${minutes}мин';
    } else if (hours > 0) {
      return '${hours}ч';
    } else {
      return '${minutes}мин';
    }
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'price': price,
      'duration_minutes': durationMinutes,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Service copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    double? price,
    int? durationMinutes,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final String? iconName;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconName,
    this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      iconName: json['icon_name'] as String?,
      imageUrl: json['image_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'image_url': imageUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class BookingRequest {
  final String? clientId;
  final String? clientName;
  final String? clientPhone;
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;
  final String masterId;

  const BookingRequest({
    this.clientId,
    this.clientName,
    this.clientPhone,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    this.notes,
    required this.masterId,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'service_id': serviceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'notes': notes,
      'master_id': masterId,
    };
  }
}
