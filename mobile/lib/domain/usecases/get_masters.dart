import '../entities/master.dart';
import '../repositories/master_repository.dart';

class GetMasters {
  final MasterRepository _repository;

  GetMasters(this._repository);

  Future<List<MasterEntity>> call() async {
    return await _repository.getMasters();
  }
}

class GetActiveMasters {
  final MasterRepository _repository;

  GetActiveMasters(this._repository);

  Future<List<MasterEntity>> call() async {
    return await _repository.getActiveMasters();
  }
}

class GetMasterById {
  final MasterRepository _repository;

  GetMasterById(this._repository);

  Future<MasterEntity?> call(String masterId) async {
    return await _repository.getMasterById(masterId);
  }
}

class GetMastersByService {
  final MasterRepository _repository;

  GetMastersByService(this._repository);

  Future<List<MasterEntity>> call(String serviceId) async {
    return await _repository.getMastersByService(serviceId);
  }
}

class GetMasterServiceIds {
  final MasterRepository _repository;

  GetMasterServiceIds(this._repository);

  Future<List<String>> call(String masterId) async {
    return await _repository.getMasterServiceIds(masterId);
  }
}
