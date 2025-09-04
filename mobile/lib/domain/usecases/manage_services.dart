import '../entities/service.dart';
import '../repositories/service_repository.dart';

class CreateService {
  final ServiceRepository _repository;

  CreateService(this._repository);

  Future<ServiceEntity> call(ServiceEntity service) async {
    return await _repository.createService(service);
  }
}

class UpdateService {
  final ServiceRepository _repository;

  UpdateService(this._repository);

  Future<ServiceEntity> call(ServiceEntity service) async {
    return await _repository.updateService(service);
  }
}

class DeleteService {
  final ServiceRepository _repository;

  DeleteService(this._repository);

  Future<void> call(String serviceId) async {
    return await _repository.deleteService(serviceId);
  }
}

class GetServiceCategories {
  final ServiceRepository _repository;

  GetServiceCategories(this._repository);

  Future<List<ServiceCategoryEntity>> call() async {
    return await _repository.getServiceCategories();
  }
}

class CreateServiceCategory {
  final ServiceRepository _repository;

  CreateServiceCategory(this._repository);

  Future<ServiceCategoryEntity> call(ServiceCategoryEntity category) async {
    return await _repository.createCategory(category);
  }
}

class UpdateServiceCategory {
  final ServiceRepository _repository;

  UpdateServiceCategory(this._repository);

  Future<ServiceCategoryEntity> call(ServiceCategoryEntity category) async {
    return await _repository.updateCategory(category);
  }
}

class DeleteServiceCategory {
  final ServiceRepository _repository;

  DeleteServiceCategory(this._repository);

  Future<void> call(String categoryId) async {
    return await _repository.deleteCategory(categoryId);
  }
}
