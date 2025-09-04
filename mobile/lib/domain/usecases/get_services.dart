import '../entities/service.dart';
import '../repositories/service_repository.dart';

class GetServices {
  final ServiceRepository _repository;

  GetServices(this._repository);

  Future<List<ServiceEntity>> call() async {
    return await _repository.getServices();
  }
}

class GetActiveServices {
  final ServiceRepository _repository;

  GetActiveServices(this._repository);

  Future<List<ServiceEntity>> call() async {
    return await _repository.getActiveServices();
  }
}

class GetServiceById {
  final ServiceRepository _repository;

  GetServiceById(this._repository);

  Future<ServiceEntity?> call(String serviceId) async {
    return await _repository.getServiceById(serviceId);
  }
}

class SearchServices {
  final ServiceRepository _repository;

  SearchServices(this._repository);

  Future<List<ServiceEntity>> call(String query) async {
    return await _repository.searchServices(query);
  }
}

class GetServicesByCategory {
  final ServiceRepository _repository;

  GetServicesByCategory(this._repository);

  Future<List<ServiceEntity>> call(String categoryId) async {
    return await _repository.getServicesByCategory(categoryId);
  }
}

class GetServicesByMaster {
  final ServiceRepository _repository;

  GetServicesByMaster(this._repository);

  Future<List<ServiceEntity>> call(String masterId) async {
    return await _repository.getServicesByMaster(masterId);
  }
}
