import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/service.dart';

/// Простой сервис для работы с услугами и категориями
/// Используется в виджетах для быстрого доступа к данным
class SimpleServiceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Метод больше не нужен - убрана логика мультиорганизационности

  /// Получить все активные категории услуг
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      // Получаем категории услуг
      final response = await _supabase
          .from('service_categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return response.map<ServiceCategory>((json) => ServiceCategory.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки категорий услуг: $e');
    }
  }

  /// Получить все активные услуги
  Future<List<Service>> getServices() async {
    try {
      // Получаем все активные услуги

      // Получаем услуги организации с информацией о категориях
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner (
              name
            )
          ''')
          .eq('is_active', true)
          .order('name', ascending: true);

      return response.map<Service>((json) {
        // Добавляем название категории из join
        final categoryName = json['service_categories']['name'] as String;
        json['category_name'] = categoryName;
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки услуг: $e');
    }
  }

  /// Получить услуги по категории
  Future<List<Service>> getServicesByCategory(String categoryId) async {
    try {
      // Получаем все активные услуги

      // Получаем услуги конкретной категории
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner (
              name
            )
          ''')
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('name', ascending: true);

      return response.map<Service>((json) {
        // Добавляем название категории из join
        final categoryName = json['service_categories']['name'] as String;
        json['category_name'] = categoryName;
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки услуг категории: $e');
    }
  }

  /// Получить услугу по ID
  Future<Service?> getServiceById(String serviceId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner (
              name
            )
          ''')
          .eq('id', serviceId)
          .maybeSingle();

      if (response == null) return null;
      
      // Добавляем название категории из join
      final categoryName = response['service_categories']['name'] as String;
      response['category_name'] = categoryName;
      return Service.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка получения услуги: $e');
    }
  }

  /// Поиск услуг по названию
  Future<List<Service>> searchServices(String query) async {
    try {
      // Получаем все активные услуги

      // Поиск по названию и описанию
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner (
              name
            )
          ''')
          .eq('is_active', true)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('name', ascending: true);

      return response.map<Service>((json) {
        // Добавляем название категории из join
        final categoryName = json['service_categories']['name'] as String;
        json['category_name'] = categoryName;
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка поиска услуг: $e');
    }
  }
}
