import '../entities/service.dart';

abstract class ServiceRepository {
  /// Получить все услуги организации
  Future<List<ServiceEntity>> getServices();

  /// Получить услугу по ID
  Future<ServiceEntity?> getServiceById(String serviceId);

  /// Создать новую услугу
  Future<ServiceEntity> createService(ServiceEntity service);

  /// Обновить услугу
  Future<ServiceEntity> updateService(ServiceEntity service);

  /// Удалить услугу
  Future<void> deleteService(String serviceId);

  /// Поиск услуг по запросу
  Future<List<ServiceEntity>> searchServices(String query);

  /// Получить услуги по категории
  Future<List<ServiceEntity>> getServicesByCategory(String categoryId);

  /// Получить услуги мастера
  Future<List<ServiceEntity>> getServicesByMaster(String masterId);

  /// Получить активные услуги
  Future<List<ServiceEntity>> getActiveServices();

  /// Получить все категории услуг
  Future<List<ServiceCategoryEntity>> getServiceCategories();

  /// Получить категорию по ID
  Future<ServiceCategoryEntity?> getCategoryById(String categoryId);

  /// Создать новую категорию
  Future<ServiceCategoryEntity> createCategory(ServiceCategoryEntity category);

  /// Обновить категорию
  Future<ServiceCategoryEntity> updateCategory(ServiceCategoryEntity category);

  /// Удалить категорию
  Future<void> deleteCategory(String categoryId);
}
