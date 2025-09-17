import '../../domain/entities/master.dart';
import '../../domain/repositories/master_repository.dart';
import '../datasources/master_remote_datasource.dart';

class MasterRepositoryImpl implements MasterRepository {
  final MasterRemoteDataSource _remoteDataSource;

  MasterRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<MasterEntity>> getMasters() async {
    try {
      final masters = await _remoteDataSource.getMasters();
      return masters;
    } catch (e) {
      throw Exception('Ошибка при получении мастеров: $e');
    }
  }

  @override
  Future<List<MasterEntity>> getActiveMasters() async {
    try {
      final masters = await _remoteDataSource.getActiveMasters();
      return masters;
    } catch (e) {
      throw Exception('Ошибка при получении активных мастеров: $e');
    }
  }

  @override
  Future<MasterEntity?> getMasterById(String masterId) async {
    try {
      final master = await _remoteDataSource.getMasterById(masterId);
      return master;
    } catch (e) {
      throw Exception('Ошибка при получении мастера: $e');
    }
  }

  @override
  Future<List<MasterEntity>> getMastersByService(String serviceId) async {
    try {
      final masters = await _remoteDataSource.getMastersByService(serviceId);
      return masters;
    } catch (e) {
      throw Exception('Ошибка при получении мастеров для услуги: $e');
    }
  }

  @override
  Future<List<String>> getMasterServiceIds(String masterId) async {
    try {
      final serviceIds = await _remoteDataSource.getMasterServiceIds(masterId);
      return serviceIds;
    } catch (e) {
      throw Exception('Ошибка при получении услуг мастера: $e');
    }
  }
}
