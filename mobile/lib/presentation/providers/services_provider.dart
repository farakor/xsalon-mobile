import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../data/services/service_service.dart';
import '../../data/services/default_categories_service.dart';
import '../../data/services/mock_service_service.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/usecases/get_services.dart';
import '../../domain/usecases/manage_services.dart';

// Состояние загрузки услуг
enum ServicesStatus {
  initial,
  loading,
  loaded,
  error,
}

// Модель состояния услуг
class ServicesState {
  final ServicesStatus status;
  final List<ServiceEntity> services;
  final List<ServiceCategoryEntity> categories;
  final String? errorMessage;

  const ServicesState({
    this.status = ServicesStatus.initial,
    this.services = const [],
    this.categories = const [],
    this.errorMessage,
  });

  ServicesState copyWith({
    ServicesStatus? status,
    List<ServiceEntity>? services,
    List<ServiceCategoryEntity>? categories,
    String? errorMessage,
  }) {
    return ServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Провайдер для управления услугами
class ServicesNotifier extends StateNotifier<ServicesState> {
  ServicesNotifier(this._serviceService, this._defaultCategoriesService) : super(const ServicesState());

  final ServiceService _serviceService;
  final DefaultCategoriesService _defaultCategoriesService;

  // Загрузка всех услуг
  Future<void> loadServices() async {
    state = state.copyWith(status: ServicesStatus.loading);

    try {
      final services = await _serviceService.getServices();
      state = state.copyWith(
        status: ServicesStatus.loaded,
        services: services,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Загрузка активных услуг
  Future<void> loadActiveServices() async {
    print('ServicesNotifier: Начинаем загрузку активных услуг из БД...');
    state = state.copyWith(status: ServicesStatus.loading);

    try {
      final services = await _serviceService.getActiveServices();
      print('ServicesNotifier: Загружено услуг из БД: ${services.length}');
      
      state = state.copyWith(
        status: ServicesStatus.loaded,
        services: services,
        errorMessage: null,
      );
    } catch (error) {
      print('ServicesNotifier: Ошибка загрузки услуг из БД: $error');
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Загрузка категорий
  Future<void> loadCategories() async {
    try {
      // Сначала пытаемся создать категории по умолчанию, если их нет
      await _ensureDefaultCategories();
      
      final categories = await _serviceService.getServiceCategories();
      state = state.copyWith(categories: categories);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Создает категории по умолчанию, если их нет
  Future<void> _ensureDefaultCategories() async {
    try {
      // Создаем категории по умолчанию, если их нет
      await _defaultCategoriesService.createDefaultCategoriesIfNeeded();
    } catch (e) {
      // Игнорируем ошибки создания категорий по умолчанию
      // Пользователь сможет создать категории вручную
    }
  }

  // Добавление новой услуги
  Future<void> addService(ServiceEntity service) async {
    try {
      final newService = await _serviceService.createService(service);
      final updatedServices = [...state.services, newService];
      state = state.copyWith(services: updatedServices);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // Обновление услуги
  Future<void> updateService(ServiceEntity service) async {
    try {
      final updatedService = await _serviceService.updateService(service);
      final updatedServices = state.services.map((s) {
        return s.id == service.id ? updatedService : s;
      }).toList();
      state = state.copyWith(services: updatedServices);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // Удаление услуги
  Future<void> deleteService(String serviceId) async {
    try {
      await _serviceService.deleteService(serviceId);
      final updatedServices = state.services.where((s) => s.id != serviceId).toList();
      state = state.copyWith(services: updatedServices);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // Поиск услуг
  Future<List<ServiceEntity>> searchServices(String query) async {
    try {
      return await _serviceService.searchServices(query);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
      return [];
    }
  }

  // Получение услуг по категории
  Future<List<ServiceEntity>> getServicesByCategory(String categoryId) async {
    try {
      return await _serviceService.getServicesByCategory(categoryId);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
      return [];
    }
  }

  // Получение услуг мастера
  Future<List<ServiceEntity>> getServicesByMaster(String masterId) async {
    try {
      return await _serviceService.getServicesByMaster(masterId);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
      return [];
    }
  }

  // Добавление новой категории
  Future<void> addCategory(ServiceCategoryEntity category) async {
    try {
      final newCategory = await _serviceService.createServiceCategory(category);
      final updatedCategories = [...state.categories, newCategory];
      state = state.copyWith(categories: updatedCategories);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // Обновление категории
  Future<void> updateCategory(ServiceCategoryEntity category) async {
    try {
      final updatedCategory = await _serviceService.updateServiceCategory(category);
      final updatedCategories = state.categories.map((c) {
        return c.id == category.id ? updatedCategory : c;
      }).toList();
      state = state.copyWith(categories: updatedCategories);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // Удаление категории
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _serviceService.deleteServiceCategory(categoryId);
      final updatedCategories = state.categories.where((c) => c.id != categoryId).toList();
      state = state.copyWith(categories: updatedCategories);
    } catch (error) {
      state = state.copyWith(
        status: ServicesStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // Очистка ошибок
  void clearError() {
    state = state.copyWith(
      status: ServicesStatus.loaded,
      errorMessage: null,
    );
  }
}

// Провайдеры зависимостей
final serviceRemoteDataSourceProvider = Provider<ServiceRemoteDataSource>((ref) {
  return ServiceRemoteDataSourceImpl();
});

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final remoteDataSource = ref.watch(serviceRemoteDataSourceProvider);
  return ServiceRepositoryImpl(remoteDataSource);
});

final defaultCategoriesServiceProvider = Provider<DefaultCategoriesService>((ref) {
  return DefaultCategoriesService();
});

final serviceServiceProvider = Provider<ServiceService>((ref) {
  final repository = ref.watch(serviceRepositoryProvider);
  
  return ServiceService(
    getServices: GetServices(repository),
    getActiveServices: GetActiveServices(repository),
    getServiceById: GetServiceById(repository),
    searchServices: SearchServices(repository),
    getServicesByCategory: GetServicesByCategory(repository),
    getServicesByMaster: GetServicesByMaster(repository),
    createService: CreateService(repository),
    updateService: UpdateService(repository),
    deleteService: DeleteService(repository),
    getServiceCategories: GetServiceCategories(repository),
    createServiceCategory: CreateServiceCategory(repository),
    updateServiceCategory: UpdateServiceCategory(repository),
    deleteServiceCategory: DeleteServiceCategory(repository),
  );
});

// Провайдер состояния услуг
final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  final serviceService = ref.watch(serviceServiceProvider);
  final defaultCategoriesService = ref.watch(defaultCategoriesServiceProvider);
  return ServicesNotifier(serviceService, defaultCategoriesService);
});

// Вспомогательные провайдеры
final servicesListProvider = Provider<List<ServiceEntity>>((ref) {
  final servicesState = ref.watch(servicesProvider);
  return servicesState.services;
});

final activeServicesProvider = Provider<List<ServiceEntity>>((ref) {
  final services = ref.watch(servicesListProvider);
  return services.where((service) => service.isActive).toList();
});

final serviceCategoriesProvider = Provider<List<ServiceCategoryEntity>>((ref) {
  final servicesState = ref.watch(servicesProvider);
  return servicesState.categories;
});

final isServicesLoadingProvider = Provider<bool>((ref) {
  final servicesState = ref.watch(servicesProvider);
  return servicesState.status == ServicesStatus.loading;
});

final servicesErrorProvider = Provider<String?>((ref) {
  final servicesState = ref.watch(servicesProvider);
  return servicesState.errorMessage;
});

// Провайдер для получения услуги по ID
final serviceByIdProvider = Provider.family<ServiceEntity?, String>((ref, serviceId) {
  final services = ref.watch(servicesListProvider);
  try {
    return services.firstWhere((service) => service.id == serviceId);
  } catch (e) {
    return null;
  }
});

// Провайдер для получения услуг по мастеру
final servicesByMasterProvider = Provider.family<List<ServiceEntity>, String>((ref, masterId) {
  final services = ref.watch(servicesListProvider);
  return services.where((service) => service.masterId == masterId).toList();
});

// Устаревший провайдер для совместимости (возвращает пустой список)
final servicesByCategoryProvider = Provider.family<List<ServiceEntity>, String>((ref, categoryId) {
  // В новой архитектуре услуги не привязаны к категориям
  return <ServiceEntity>[];
});

// Провайдер для получения категории по ID
final categoryByIdProvider = Provider.family<ServiceCategoryEntity?, String>((ref, categoryId) {
  final categories = ref.watch(serviceCategoriesProvider);
  try {
    return categories.firstWhere((category) => category.id == categoryId);
  } catch (e) {
    return null;
  }
});

// Провайдер для статистики услуг
final servicesStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final services = ref.watch(servicesListProvider);
  
  final totalServices = services.length;
  final activeServices = services.where((s) => s.isActive).length;
  final avgPrice = services.isNotEmpty 
      ? services.fold<double>(0, (sum, service) => sum + service.price) / services.length 
      : 0.0;
  final avgDuration = services.isNotEmpty 
      ? services.fold<int>(0, (sum, service) => sum + service.durationMinutes) / services.length 
      : 0;
  
  return {
    'totalServices': totalServices,
    'activeServices': activeServices,
    'avgPrice': avgPrice,
    'avgDuration': avgDuration,
  };
});
