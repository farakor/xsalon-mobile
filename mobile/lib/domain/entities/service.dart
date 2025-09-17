class ServiceEntity {
  final String id;
  final String masterId;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final int preparationTimeMinutes;
  final int cleanupTimeMinutes;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceEntity({
    required this.id,
    required this.masterId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.preparationTimeMinutes = 5,
    this.cleanupTimeMinutes = 5,
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

  ServiceEntity copyWith({
    String? id,
    String? masterId,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    int? preparationTimeMinutes,
    int? cleanupTimeMinutes,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      masterId: masterId ?? this.masterId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      cleanupTimeMinutes: cleanupTimeMinutes ?? this.cleanupTimeMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ServiceEntity(id: $id, name: $name, price: $price)';
  }
}

class ServiceCategoryEntity {
  final String id;
  final String name;
  final String description;
  final String? iconName;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceCategoryEntity({
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

  ServiceCategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceCategoryEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ServiceCategoryEntity(id: $id, name: $name)';
  }
}
