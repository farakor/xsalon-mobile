import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_datasource.dart';
import '../models/service.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource _remoteDataSource;

  ServiceRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ServiceEntity>> getServices() async {
    final services = await _remoteDataSource.getServices();
    return services.map((service) => _mapToEntity(service)).toList();
  }

  @override
  Future<ServiceEntity?> getServiceById(String serviceId) async {
    final service = await _remoteDataSource.getServiceById(serviceId);
    return service != null ? _mapToEntity(service) : null;
  }

  @override
  Future<ServiceEntity> createService(ServiceEntity service) async {
    final serviceModel = _mapToModel(service);
    final createdService = await _remoteDataSource.createService(serviceModel);
    return _mapToEntity(createdService);
  }

  @override
  Future<ServiceEntity> updateService(ServiceEntity service) async {
    final serviceModel = _mapToModel(service);
    final updatedService = await _remoteDataSource.updateService(serviceModel);
    return _mapToEntity(updatedService);
  }

  @override
  Future<void> deleteService(String serviceId) async {
    await _remoteDataSource.deleteService(serviceId);
  }

  @override
  Future<List<ServiceEntity>> searchServices(String query) async {
    final services = await _remoteDataSource.searchServices(query);
    return services.map((service) => _mapToEntity(service)).toList();
  }

  @override
  Future<List<ServiceEntity>> getServicesByCategory(String categoryId) async {
    final services = await _remoteDataSource.getServicesByCategory(categoryId);
    return services.map((service) => _mapToEntity(service)).toList();
  }

  @override
  Future<List<ServiceEntity>> getServicesByMaster(String masterId) async {
    final services = await _remoteDataSource.getServicesByMaster(masterId);
    return services.map((service) => _mapToEntity(service)).toList();
  }

  @override
  Future<List<ServiceEntity>> getActiveServices() async {
    final services = await _remoteDataSource.getActiveServices();
    return services.map((service) => _mapToEntity(service)).toList();
  }

  @override
  Future<List<ServiceCategoryEntity>> getServiceCategories() async {
    final categories = await _remoteDataSource.getServiceCategories();
    return categories.map((category) => _mapCategoryToEntity(category)).toList();
  }

  @override
  Future<ServiceCategoryEntity?> getCategoryById(String categoryId) async {
    final category = await _remoteDataSource.getCategoryById(categoryId);
    return category != null ? _mapCategoryToEntity(category) : null;
  }

  @override
  Future<ServiceCategoryEntity> createCategory(ServiceCategoryEntity category) async {
    final categoryModel = _mapCategoryToModel(category);
    final createdCategory = await _remoteDataSource.createCategory(categoryModel);
    return _mapCategoryToEntity(createdCategory);
  }

  @override
  Future<ServiceCategoryEntity> updateCategory(ServiceCategoryEntity category) async {
    final categoryModel = _mapCategoryToModel(category);
    final updatedCategory = await _remoteDataSource.updateCategory(categoryModel);
    return _mapCategoryToEntity(updatedCategory);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _remoteDataSource.deleteCategory(categoryId);
  }

  // Маппинг из модели в сущность
  ServiceEntity _mapToEntity(Service service) {
    return ServiceEntity(
      id: service.id,
      masterId: service.masterId,
      name: service.name,
      description: service.description,
      price: service.price,
      durationMinutes: service.durationMinutes,
      preparationTimeMinutes: service.preparationTimeMinutes,
      cleanupTimeMinutes: service.cleanupTimeMinutes,
      imageUrl: service.imageUrl,
      isActive: service.isActive,
      createdAt: service.createdAt,
      updatedAt: service.updatedAt,
    );
  }

  // Маппинг из сущности в модель
  Service _mapToModel(ServiceEntity service) {
    return Service(
      id: service.id,
      masterId: service.masterId,
      name: service.name,
      description: service.description,
      price: service.price,
      durationMinutes: service.durationMinutes,
      preparationTimeMinutes: service.preparationTimeMinutes,
      cleanupTimeMinutes: service.cleanupTimeMinutes,
      imageUrl: service.imageUrl,
      isActive: service.isActive,
      createdAt: service.createdAt,
      updatedAt: service.updatedAt,
    );
  }

  // Маппинг категории из модели в сущность
  ServiceCategoryEntity _mapCategoryToEntity(ServiceCategory category) {
    return ServiceCategoryEntity(
      id: category.id,
      name: category.name,
      description: category.description,
      iconName: category.iconName,
      imageUrl: category.imageUrl,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  // Маппинг категории из сущности в модель
  ServiceCategory _mapCategoryToModel(ServiceCategoryEntity category) {
    return ServiceCategory(
      id: category.id,
      name: category.name,
      description: category.description,
      iconName: category.iconName,
      imageUrl: category.imageUrl,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}
