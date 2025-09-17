import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/service.dart';

/// Простой сервис для работы с услугами мастеров
/// Используется в виджетах для быстрого доступа к данным
class SimpleServiceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Получить все активные категории услуг (больше не используется в новой системе)
  @deprecated
  Future<List<ServiceCategory>> getServiceCategories() async {
    // В новой системе категории не используются
    return [];
  }

  /// Получить все активные услуги
  Future<List<Service>> getServices() async {
    try {
      // Получаем все активные услуги из новой системы
      final response = await _supabase
          .from('master_services_new')
          .select('*')
          .eq('is_active', true)
          .order('name', ascending: true);

      return response.map<Service>((json) {
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки услуг: $e');
    }
  }

  /// Получить услуги по категории (больше не используется в новой системе)
  @deprecated
  Future<List<Service>> getServicesByCategory(String categoryId) async {
    // В новой системе категории не используются
    return [];
  }

  /// Получить услугу по ID
  Future<Service?> getServiceById(String serviceId) async {
    try {
      final response = await _supabase
          .from('master_services_new')
          .select('*')
          .eq('id', serviceId)
          .maybeSingle();

      if (response == null) return null;
      
      return Service.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка получения услуги: $e');
    }
  }

  /// Поиск услуг по названию
  Future<List<Service>> searchServices(String query) async {
    try {
      // Поиск по названию и описанию в новой системе
      final response = await _supabase
          .from('master_services_new')
          .select('*')
          .eq('is_active', true)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('name', ascending: true);

      return response.map<Service>((json) {
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка поиска услуг: $e');
    }
  }

  /// Получить услуги конкретного мастера
  Future<List<Service>> getServicesByMaster(String masterId) async {
    try {
      final response = await _supabase
          .from('master_services_new')
          .select('*')
          .eq('master_id', masterId)
          .eq('is_active', true)
          .order('name', ascending: true);

      return response.map<Service>((json) {
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка получения услуг мастера: $e');
    }
  }
}
