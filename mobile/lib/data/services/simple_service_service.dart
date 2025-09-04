import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/service.dart';

/// Простой сервис для работы с услугами и категориями
/// Используется в виджетах для быстрого доступа к данным
class SimpleServiceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Получить или создать организацию для пользователя
  Future<String> _getOrCreateOrganizationId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    // Получаем профиль пользователя
    final profileResponse = await _supabase
        .from('user_profiles')
        .select('organization_id')
        .eq('id', user.id)
        .single();

    String? organizationId = profileResponse['organization_id'];
    
    // Если пользователь не привязан к организации, используем временное решение
    if (organizationId == null) {
      // Пытаемся найти любую существующую организацию
      final existingOrgResponse = await _supabase
          .from('organizations')
          .select('id')
          .limit(1)
          .maybeSingle();
          
      if (existingOrgResponse != null) {
        organizationId = existingOrgResponse['id'];
        
        // Обновляем профиль пользователя
        await _supabase
            .from('user_profiles')
            .update({'organization_id': organizationId})
            .eq('id', user.id);
      } else {
        // Если нет ни одной организации, создаем временный ID
        throw Exception('В системе не найдено ни одной организации. Обратитесь к администратору для настройки.');
      }
    }
    
    // Гарантируем, что organizationId не null
    if (organizationId == null) {
      throw Exception('Не удалось получить или создать организацию');
    }
    
    return organizationId;
  }

  /// Получить все активные категории услуг
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      // Получаем или создаем организацию
      final organizationId = await _getOrCreateOrganizationId();

      // Получаем категории услуг организации
      final response = await _supabase
          .from('service_categories')
          .select('*')
          .eq('organization_id', organizationId)
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
      // Получаем или создаем организацию
      final organizationId = await _getOrCreateOrganizationId();

      // Получаем услуги организации с информацией о категориях
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner (
              name
            )
          ''')
          .eq('organization_id', organizationId)
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
      // Получаем или создаем организацию
      final organizationId = await _getOrCreateOrganizationId();

      // Получаем услуги конкретной категории
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner (
              name
            )
          ''')
          .eq('organization_id', organizationId)
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
      // Получаем или создаем организацию
      final organizationId = await _getOrCreateOrganizationId();

      // Поиск по названию и описанию
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner (
              name
            )
          ''')
          .eq('organization_id', organizationId)
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
