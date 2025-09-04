import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/service.dart';
import '../../data/services/simple_service_service.dart';

// Состояние загрузки услуг
enum SimpleServicesStatus {
  initial,
  loading,
  loaded,
  error,
}

// Модель состояния услуг
class SimpleServicesState {
  final SimpleServicesStatus status;
  final List<Service> services;
  final List<ServiceCategory> categories;
  final String? errorMessage;

  const SimpleServicesState({
    this.status = SimpleServicesStatus.initial,
    this.services = const [],
    this.categories = const [],
    this.errorMessage,
  });

  SimpleServicesState copyWith({
    SimpleServicesStatus? status,
    List<Service>? services,
    List<ServiceCategory>? categories,
    String? errorMessage,
  }) {
    return SimpleServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Провайдер для управления услугами
class SimpleServicesNotifier extends StateNotifier<SimpleServicesState> {
  SimpleServicesNotifier(this._serviceService) : super(const SimpleServicesState());

  final SimpleServiceService _serviceService;

  // Загрузка категорий
  Future<void> loadCategories() async {
    state = state.copyWith(status: SimpleServicesStatus.loading);

    try {
      final categories = await _serviceService.getServiceCategories();
      state = state.copyWith(
        status: SimpleServicesStatus.loaded,
        categories: categories,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: SimpleServicesStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Загрузка всех услуг
  Future<void> loadServices() async {
    state = state.copyWith(status: SimpleServicesStatus.loading);

    try {
      final services = await _serviceService.getServices();
      state = state.copyWith(
        status: SimpleServicesStatus.loaded,
        services: services,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: SimpleServicesStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Загрузка услуг по категории
  Future<List<Service>> getServicesByCategory(String categoryId) async {
    try {
      return await _serviceService.getServicesByCategory(categoryId);
    } catch (error) {
      state = state.copyWith(
        status: SimpleServicesStatus.error,
        errorMessage: error.toString(),
      );
      return [];
    }
  }

  // Поиск услуг
  Future<List<Service>> searchServices(String query) async {
    try {
      return await _serviceService.searchServices(query);
    } catch (error) {
      state = state.copyWith(
        status: SimpleServicesStatus.error,
        errorMessage: error.toString(),
      );
      return [];
    }
  }
}

// Провайдеры
final simpleServiceServiceProvider = Provider<SimpleServiceService>((ref) {
  return SimpleServiceService();
});

final simpleServicesProvider = StateNotifierProvider<SimpleServicesNotifier, SimpleServicesState>((ref) {
  final serviceService = ref.watch(simpleServiceServiceProvider);
  return SimpleServicesNotifier(serviceService);
});

// Вспомогательные провайдеры
final simpleCategoriesProvider = Provider<List<ServiceCategory>>((ref) {
  final servicesState = ref.watch(simpleServicesProvider);
  return servicesState.categories;
});

final simpleServicesListProvider = Provider<List<Service>>((ref) {
  final servicesState = ref.watch(simpleServicesProvider);
  return servicesState.services;
});

final isSimpleServicesLoadingProvider = Provider<bool>((ref) {
  final servicesState = ref.watch(simpleServicesProvider);
  return servicesState.status == SimpleServicesStatus.loading;
});

final simpleServicesErrorProvider = Provider<String?>((ref) {
  final servicesState = ref.watch(simpleServicesProvider);
  return servicesState.errorMessage;
});

// Провайдер для получения услуг по категории
final simpleServicesByCategoryProvider = Provider.family<List<Service>, String>((ref, categoryId) {
  final services = ref.watch(simpleServicesListProvider);
  return services.where((service) => service.categoryId == categoryId).toList();
});
