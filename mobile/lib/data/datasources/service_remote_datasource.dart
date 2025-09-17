import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service.dart';

abstract class ServiceRemoteDataSource {
  Future<List<Service>> getServices();
  Future<Service?> getServiceById(String serviceId);
  Future<Service> createService(Service service);
  Future<Service> updateService(Service service);
  Future<void> deleteService(String serviceId);
  Future<List<Service>> searchServices(String query);
  Future<List<Service>> getServicesByCategory(String categoryId);
  Future<List<Service>> getServicesByMaster(String masterId);
  Future<List<Service>> getActiveServices();
  Future<List<ServiceCategory>> getServiceCategories();
  Future<ServiceCategory?> getCategoryById(String categoryId);
  Future<ServiceCategory> createCategory(ServiceCategory category);
  Future<ServiceCategory> updateCategory(ServiceCategory category);
  Future<void> deleteCategory(String categoryId);
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Получить первую доступную организацию (для анонимного доступа)
  Future<String> _getFirstAvailableOrganization() async {
    try {
      final response = await _supabase
          .from('organizations')
          .select('id')
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();
          
      if (response != null) {
        final orgId = response['id'] as String;
        print('ServiceRemoteDataSource: Найдена организация: $orgId');
        return orgId;
      }
      
      // Если организаций нет, создаем тестовую
      print('ServiceRemoteDataSource: Организации не найдены, создаем тестовую...');
      final newOrgResponse = await _supabase
          .from('organizations')
          .insert({
            'name': 'XSalon Test',
            'description': 'Тестовая организация',
            'is_active': true,
          })
          .select('id')
          .single();
          
      final newOrgId = newOrgResponse['id'] as String;
      print('ServiceRemoteDataSource: Создана новая организация: $newOrgId');
      return newOrgId;
    } catch (e) {
      print('ServiceRemoteDataSource: Ошибка получения организации: $e');
      throw Exception('Не удалось получить организацию: $e');
    }
  }

  // Метод больше не нужен - убрана логика мультиорганизационности

  @override
  Future<List<Service>> getServices() async {
    try {
      print('ServiceRemoteDataSource: Загружаем все услуги из master_services_new...');

      final response = await _supabase
          .from('master_services_new')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      print('ServiceRemoteDataSource: Получено услуг: ${response.length}');
      
      return response.map<Service>((json) {
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      print('ServiceRemoteDataSource: Ошибка загрузки услуг: $e');
      throw Exception('Ошибка загрузки услуг: $e');
    }
  }

  @override
  Future<List<Service>> getActiveServices() async {
    try {
      print('ServiceRemoteDataSource: Начинаем загрузку активных услуг из master_services_new...');

      final response = await _supabase
          .from('master_services_new')
          .select('*')
          .eq('is_active', true)
          .order('name', ascending: true);

      print('ServiceRemoteDataSource: Получен ответ: ${response.length} записей');
      print('ServiceRemoteDataSource: Первая запись: ${response.isNotEmpty ? response.first : 'нет данных'}');

      return response.map<Service>((json) {
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      print('ServiceRemoteDataSource: Ошибка загрузки активных услуг: $e');
      throw Exception('Ошибка загрузки активных услуг: $e');
    }
  }

  @override
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

  @override
  Future<Service> createService(Service service) async {
    try {
      final serviceData = service.toJson();
      serviceData.remove('id'); // Удаляем ID, чтобы база сгенерировала новый

      final response = await _supabase
          .from('master_services_new')
          .insert(serviceData)
          .select('*')
          .single();

      return Service.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка создания услуги: $e');
    }
  }

  @override
  Future<Service> updateService(Service service) async {
    try {
      final serviceData = service.toJson();

      final response = await _supabase
          .from('master_services_new')
          .update(serviceData)
          .eq('id', service.id)
          .select('*')
          .single();

      return Service.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка обновления услуги: $e');
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    try {
      await _supabase
          .from('master_services_new')
          .update({'is_active': false})
          .eq('id', serviceId);
    } catch (e) {
      throw Exception('Ошибка удаления услуги: $e');
    }
  }

  @override
  Future<List<Service>> searchServices(String query) async {
    try {
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

  @override
  Future<List<Service>> getServicesByCategory(String categoryId) async {
    // В новой архитектуре услуги не привязаны к категориям, 
    // они привязаны к мастерам. Возвращаем пустой список.
    print('ServiceRemoteDataSource: getServicesByCategory больше не поддерживается в новой архитектуре');
    return [];
  }

  @override
  Future<List<Service>> getServicesByMaster(String masterId) async {
    try {
      print('ServiceRemoteDataSource: Загружаем услуги мастера: $masterId');

      final response = await _supabase
          .from('master_services_new')
          .select('*')
          .eq('master_id', masterId)
          .eq('is_active', true)
          .order('name', ascending: true);

      print('ServiceRemoteDataSource: Найдено услуг мастера: ${response.length}');

      return response.map<Service>((json) {
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      print('ServiceRemoteDataSource: Ошибка получения услуг мастера: $e');
      throw Exception('Ошибка получения услуг мастера: $e');
    }
  }

  @override
  Future<List<ServiceCategory>> getServiceCategories() async {
    // В новой системе категории не используются
    return [];
  }

  @override
  Future<ServiceCategory?> getCategoryById(String categoryId) async {
    // В новой системе категории не используются
    return null;
  }

  @override
  Future<ServiceCategory> createCategory(ServiceCategory category) async {
    // В новой системе категории не используются
    throw Exception('Создание категорий больше не поддерживается');
  }

  @override
  Future<ServiceCategory> updateCategory(ServiceCategory category) async {
    // В новой системе категории не используются
    throw Exception('Обновление категорий больше не поддерживается');
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    // В новой системе категории не используются
    throw Exception('Удаление категорий больше не поддерживается');
  }
}
