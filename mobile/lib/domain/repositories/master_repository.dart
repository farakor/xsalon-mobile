import '../entities/master.dart';

abstract class MasterRepository {
  Future<List<MasterEntity>> getMasters();
  Future<List<MasterEntity>> getActiveMasters();
  Future<MasterEntity?> getMasterById(String masterId);
  Future<List<MasterEntity>> getMastersByService(String serviceId);
  Future<List<String>> getMasterServiceIds(String masterId);
}
