import '../../domain/entities/service.dart';
import '../../domain/usecases/get_services.dart';
import '../../domain/usecases/manage_services.dart';

class ServiceService {
  final GetServices _getServices;
  final GetActiveServices _getActiveServices;
  final GetServiceById _getServiceById;
  final SearchServices _searchServices;
  final GetServicesByCategory _getServicesByCategory;
  final GetServicesByMaster _getServicesByMaster;
  final CreateService _createService;
  final UpdateService _updateService;
  final DeleteService _deleteService;
  final GetServiceCategories _getServiceCategories;
  final CreateServiceCategory _createServiceCategory;
  final UpdateServiceCategory _updateServiceCategory;
  final DeleteServiceCategory _deleteServiceCategory;

  ServiceService({
    required GetServices getServices,
    required GetActiveServices getActiveServices,
    required GetServiceById getServiceById,
    required SearchServices searchServices,
    required GetServicesByCategory getServicesByCategory,
    required GetServicesByMaster getServicesByMaster,
    required CreateService createService,
    required UpdateService updateService,
    required DeleteService deleteService,
    required GetServiceCategories getServiceCategories,
    required CreateServiceCategory createServiceCategory,
    required UpdateServiceCategory updateServiceCategory,
    required DeleteServiceCategory deleteServiceCategory,
  })  : _getServices = getServices,
        _getActiveServices = getActiveServices,
        _getServiceById = getServiceById,
        _searchServices = searchServices,
        _getServicesByCategory = getServicesByCategory,
        _getServicesByMaster = getServicesByMaster,
        _createService = createService,
        _updateService = updateService,
        _deleteService = deleteService,
        _getServiceCategories = getServiceCategories,
        _createServiceCategory = createServiceCategory,
        _updateServiceCategory = updateServiceCategory,
        _deleteServiceCategory = deleteServiceCategory;

  // Методы для работы с услугами
  Future<List<ServiceEntity>> getServices() => _getServices();
  
  Future<List<ServiceEntity>> getActiveServices() => _getActiveServices();
  
  Future<ServiceEntity?> getServiceById(String serviceId) => _getServiceById(serviceId);
  
  Future<List<ServiceEntity>> searchServices(String query) => _searchServices(query);
  
  Future<List<ServiceEntity>> getServicesByCategory(String categoryId) => 
      _getServicesByCategory(categoryId);
  
  Future<List<ServiceEntity>> getServicesByMaster(String masterId) => 
      _getServicesByMaster(masterId);
  
  Future<ServiceEntity> createService(ServiceEntity service) => _createService(service);
  
  Future<ServiceEntity> updateService(ServiceEntity service) => _updateService(service);
  
  Future<void> deleteService(String serviceId) => _deleteService(serviceId);

  // Методы для работы с категориями
  Future<List<ServiceCategoryEntity>> getServiceCategories() => _getServiceCategories();
  
  Future<ServiceCategoryEntity> createServiceCategory(ServiceCategoryEntity category) => 
      _createServiceCategory(category);
  
  Future<ServiceCategoryEntity> updateServiceCategory(ServiceCategoryEntity category) => 
      _updateServiceCategory(category);
  
  Future<void> deleteServiceCategory(String categoryId) => _deleteServiceCategory(categoryId);
}
