import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/master_remote_datasource.dart';
import '../../data/repositories/master_repository_impl.dart';
import '../../data/services/master_service.dart';
import '../../data/services/mock_master_service.dart';
import '../../domain/entities/master.dart';
import '../../domain/repositories/master_repository.dart';
import '../../domain/usecases/get_masters.dart';

// Состояние загрузки мастеров
enum MastersStatus {
  initial,
  loading,
  loaded,
  error,
}

// Модель состояния мастеров
class MastersState {
  final MastersStatus status;
  final List<MasterEntity> masters;
  final String? errorMessage;

  const MastersState({
    this.status = MastersStatus.initial,
    this.masters = const [],
    this.errorMessage,
  });

  MastersState copyWith({
    MastersStatus? status,
    List<MasterEntity>? masters,
    String? errorMessage,
  }) {
    return MastersState(
      status: status ?? this.status,
      masters: masters ?? this.masters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Провайдер для управления мастерами
class MastersNotifier extends StateNotifier<MastersState> {
  MastersNotifier(this._masterService) : super(const MastersState());

  final MasterService _masterService;

  // Загрузка всех мастеров
  Future<void> loadMasters() async {
    state = state.copyWith(status: MastersStatus.loading);

    try {
      final masters = await _masterService.getMasters();
      state = state.copyWith(
        status: MastersStatus.loaded,
        masters: masters,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: MastersStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Загрузка активных мастеров
  Future<void> loadActiveMasters() async {
    print('MastersNotifier: Начинаем загрузку активных мастеров из БД...');
    state = state.copyWith(status: MastersStatus.loading);

    try {
      final masters = await _masterService.getActiveMasters();
      print('MastersNotifier: Загружено мастеров из БД: ${masters.length}');
      
      state = state.copyWith(
        status: MastersStatus.loaded,
        masters: masters,
        errorMessage: null,
      );
    } catch (error) {
      print('MastersNotifier: Ошибка загрузки мастеров из БД: $error');
      state = state.copyWith(
        status: MastersStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Получение мастеров для конкретной услуги
  Future<List<MasterEntity>> getMastersByService(String serviceId) async {
    try {
      print('MastersNotifier: Загружаем мастеров для услуги $serviceId из БД...');
      final masters = await _masterService.getMastersByService(serviceId);
      print('MastersNotifier: Найдено мастеров для услуги: ${masters.length}');
      return masters;
    } catch (error) {
      print('MastersNotifier: Ошибка загрузки мастеров для услуги: $error');
      state = state.copyWith(
        status: MastersStatus.error,
        errorMessage: error.toString(),
      );
      return [];
    }
  }

  // Получение мастера по ID
  Future<MasterEntity?> getMasterById(String masterId) async {
    try {
      return await _masterService.getMasterById(masterId);
    } catch (error) {
      state = state.copyWith(
        status: MastersStatus.error,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  // Очистка ошибок
  void clearError() {
    state = state.copyWith(
      status: MastersStatus.loaded,
      errorMessage: null,
    );
  }
}

// Провайдеры зависимостей
final masterRemoteDataSourceProvider = Provider<MasterRemoteDataSource>((ref) {
  return MasterRemoteDataSourceImpl();
});

final masterRepositoryProvider = Provider<MasterRepository>((ref) {
  final remoteDataSource = ref.watch(masterRemoteDataSourceProvider);
  return MasterRepositoryImpl(remoteDataSource);
});

final masterServiceProvider = Provider<MasterService>((ref) {
  final repository = ref.watch(masterRepositoryProvider);
  
  return MasterService(
    getMasters: GetMasters(repository),
    getActiveMasters: GetActiveMasters(repository),
    getMasterById: GetMasterById(repository),
    getMastersByService: GetMastersByService(repository),
    getMasterServiceIds: GetMasterServiceIds(repository),
  );
});

// Провайдер состояния мастеров
final mastersProvider = StateNotifierProvider<MastersNotifier, MastersState>((ref) {
  final masterService = ref.watch(masterServiceProvider);
  return MastersNotifier(masterService);
});

// Вспомогательные провайдеры
final mastersListProvider = Provider<List<MasterEntity>>((ref) {
  final mastersState = ref.watch(mastersProvider);
  return mastersState.masters;
});

final activeMastersProvider = Provider<List<MasterEntity>>((ref) {
  final masters = ref.watch(mastersListProvider);
  return masters.where((master) => master.isActive).toList();
});

final isMastersLoadingProvider = Provider<bool>((ref) {
  final mastersState = ref.watch(mastersProvider);
  return mastersState.status == MastersStatus.loading;
});

final mastersErrorProvider = Provider<String?>((ref) {
  final mastersState = ref.watch(mastersProvider);
  return mastersState.errorMessage;
});

// Провайдер для получения мастера по ID
final masterByIdProvider = Provider.family<MasterEntity?, String>((ref, masterId) {
  final masters = ref.watch(mastersListProvider);
  try {
    return masters.firstWhere((master) => master.id == masterId);
  } catch (e) {
    return null;
  }
});

// Провайдер для получения мастеров по услуге
final mastersByServiceProvider = FutureProvider.family<List<MasterEntity>, String>((ref, serviceId) async {
  final mastersNotifier = ref.watch(mastersProvider.notifier);
  return await mastersNotifier.getMastersByService(serviceId);
});

// Провайдер для статистики мастеров
final mastersStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final masters = ref.watch(mastersListProvider);
  
  final totalMasters = masters.length;
  final activeMasters = masters.where((m) => m.isActive).length;
  final avgRating = masters.isNotEmpty 
      ? masters.fold<double>(0, (sum, master) => sum + master.rating) / masters.length 
      : 0.0;
  final avgExperience = masters.isNotEmpty 
      ? masters.fold<int>(0, (sum, master) => sum + master.experienceYears) / masters.length 
      : 0;
  
  return {
    'totalMasters': totalMasters,
    'activeMasters': activeMasters,
    'avgRating': avgRating,
    'avgExperience': avgExperience,
  };
});
