import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/master.dart';

abstract class MasterRemoteDataSource {
  Future<List<MasterModel>> getMasters();
  Future<List<MasterModel>> getActiveMasters();
  Future<MasterModel?> getMasterById(String masterId);
  Future<List<MasterModel>> getMastersByService(String serviceId);
  Future<List<String>> getMasterServiceIds(String masterId);
}

class MasterRemoteDataSourceImpl implements MasterRemoteDataSource {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<List<MasterModel>> getMasters() async {
    try {
      final response = await _supabaseClient
          .from('masters')
          .select('''
            *,
            user_profiles!inner(
              full_name,
              phone,
              email,
              avatar_url
            )
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MasterModel.fromJoinedJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке мастеров: $e');
    }
  }

  @override
  Future<List<MasterModel>> getActiveMasters() async {
    try {
      print('MasterRemoteDataSource: Начинаем загрузку активных мастеров...');
      
      // Сначала проверим, сколько всего активных мастеров
      final countResponse = await _supabaseClient
          .from('masters')
          .select('id')
          .eq('is_active', true);
      print('MasterRemoteDataSource: Всего активных мастеров: ${countResponse.length}');
      
      // Теперь основной запрос с INNER JOIN
      final response = await _supabaseClient
          .from('masters')
          .select('''
            *,
            user_profiles!inner(
              full_name,
              phone,
              email,
              avatar_url
            )
          ''')
          .eq('is_active', true)
          .order('rating', ascending: false);

      print('MasterRemoteDataSource: Мастеров с профилями: ${response.length}');
      
      if (response.isEmpty && countResponse.isNotEmpty) {
        print('MasterRemoteDataSource: ❌ ПРОБЛЕМА: Есть активные мастера, но нет связанных профилей!');
        print('MasterRemoteDataSource: Проверьте связи в таблице user_profiles');
      }

      final masters = (response as List)
          .map((json) => MasterModel.fromJoinedJson(json as Map<String, dynamic>))
          .toList();
          
      print('MasterRemoteDataSource: Успешно загружено мастеров: ${masters.length}');
      return masters;
    } catch (e) {
      print('MasterRemoteDataSource: Ошибка при загрузке активных мастеров: $e');
      throw Exception('Ошибка при загрузке активных мастеров: $e');
    }
  }

  @override
  Future<MasterModel?> getMasterById(String masterId) async {
    try {
      final response = await _supabaseClient
          .from('masters')
          .select('''
            *,
            user_profiles!inner(
              full_name,
              phone,
              email,
              avatar_url
            )
          ''')
          .eq('id', masterId)
          .maybeSingle();

      if (response == null) return null;

      return MasterModel.fromJoinedJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Ошибка при загрузке мастера: $e');
    }
  }

  @override
  Future<List<MasterModel>> getMastersByService(String serviceId) async {
    try {
      final response = await _supabaseClient
          .from('masters')
          .select('''
            *,
            user_profiles!inner(
              full_name,
              phone,
              email,
              avatar_url
            ),
            master_services_new!inner(
              id
            )
          ''')
          .eq('is_active', true)
          .eq('master_services_new.id', serviceId)
          .order('rating', ascending: false);

      return (response as List)
          .map((json) => MasterModel.fromJoinedJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке мастеров для услуги: $e');
    }
  }

  @override
  Future<List<String>> getMasterServiceIds(String masterId) async {
    try {
      final response = await _supabaseClient
          .from('master_services_new')
          .select('id')
          .eq('master_id', masterId)
          .eq('is_active', true);

      return (response as List<dynamic>)
          .map((json) => json['id'] as String)
          .toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке услуг мастера: $e');
    }
  }

  // Метод больше не нужен - убрана логика мультиорганизационности
}
