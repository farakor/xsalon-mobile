import '../../domain/entities/master.dart';
import '../../domain/usecases/get_masters.dart';

class MasterService {
  final GetMasters _getMasters;
  final GetActiveMasters _getActiveMasters;
  final GetMasterById _getMasterById;
  final GetMastersByService _getMastersByService;
  final GetMasterServiceIds _getMasterServiceIds;

  MasterService({
    required GetMasters getMasters,
    required GetActiveMasters getActiveMasters,
    required GetMasterById getMasterById,
    required GetMastersByService getMastersByService,
    required GetMasterServiceIds getMasterServiceIds,
  })  : _getMasters = getMasters,
        _getActiveMasters = getActiveMasters,
        _getMasterById = getMasterById,
        _getMastersByService = getMastersByService,
        _getMasterServiceIds = getMasterServiceIds;

  Future<List<MasterEntity>> getMasters() async {
    return await _getMasters();
  }

  Future<List<MasterEntity>> getActiveMasters() async {
    return await _getActiveMasters();
  }

  Future<MasterEntity?> getMasterById(String masterId) async {
    return await _getMasterById(masterId);
  }

  Future<List<MasterEntity>> getMastersByService(String serviceId) async {
    return await _getMastersByService(serviceId);
  }

  Future<List<String>> getMasterServiceIds(String masterId) async {
    return await _getMasterServiceIds(masterId);
  }
}
