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

  /// Получить или создать организацию для пользователя
  Future<String> getOrCreateOrganizationId() async {
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
        throw Exception('В системе не найдено ни одной организации. Обратитесь к администратору для настройки.');
      }
    }
    
    if (organizationId == null) {
      throw Exception('Не удалось получить или создать организацию');
    }
    
    return organizationId;
  }

  @override
  Future<List<Service>> getServices() async {
    try {
      final organizationId = await getOrCreateOrganizationId();

      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner(
              id,
              name
            )
          ''')
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);

      return response.map<Service>((json) {
        // Добавляем данные категории в основной объект
        json['category_id'] = json['service_categories']['id'];
        json['category_name'] = json['service_categories']['name'];
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки услуг: $e');
    }
  }

  @override
  Future<List<Service>> getActiveServices() async {
    try {
      final organizationId = await getOrCreateOrganizationId();

      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner(
              id,
              name
            )
          ''')
          .eq('organization_id', organizationId)
          .eq('is_active', true)
          .order('name', ascending: true);

      return response.map<Service>((json) {
        json['category_id'] = json['categories']['id'];
        json['category_name'] = json['categories']['name'];
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки активных услуг: $e');
    }
  }

  @override
  Future<Service?> getServiceById(String serviceId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner(
              id,
              name
            )
          ''')
          .eq('id', serviceId)
          .maybeSingle();

      if (response == null) return null;

      response['category_id'] = response['service_categories']['id'];
      response['category_name'] = response['service_categories']['name'];
      return Service.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка получения услуги: $e');
    }
  }

  @override
  Future<Service> createService(Service service) async {
    try {
      final organizationId = await getOrCreateOrganizationId();

      final serviceData = service.toJson();
      serviceData['organization_id'] = organizationId;
      serviceData.remove('id'); // Удаляем ID, чтобы база сгенерировала новый
      serviceData.remove('category_name'); // Удаляем category_name, так как это поле из join

      final response = await _supabase
          .from('services')
          .insert(serviceData)
          .select('''
            *,
            service_categories!inner(
              id,
              name
            )
          ''')
          .single();

      response['category_id'] = response['service_categories']['id'];
      response['category_name'] = response['service_categories']['name'];
      return Service.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка создания услуги: $e');
    }
  }

  @override
  Future<Service> updateService(Service service) async {
    try {
      final serviceData = service.toJson();
      serviceData.remove('category_name'); // Удаляем category_name, так как это поле из join

      final response = await _supabase
          .from('services')
          .update(serviceData)
          .eq('id', service.id)
          .select('''
            *,
            service_categories!inner(
              id,
              name
            )
          ''')
          .single();

      response['category_id'] = response['service_categories']['id'];
      response['category_name'] = response['service_categories']['name'];
      return Service.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка обновления услуги: $e');
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    try {
      await _supabase
          .from('services')
          .delete()
          .eq('id', serviceId);
    } catch (e) {
      throw Exception('Ошибка удаления услуги: $e');
    }
  }

  @override
  Future<List<Service>> searchServices(String query) async {
    try {
      final organizationId = await getOrCreateOrganizationId();

      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner(
              id,
              name
            )
          ''')
          .eq('organization_id', organizationId)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('name', ascending: true);

      return response.map<Service>((json) {
        json['category_id'] = json['categories']['id'];
        json['category_name'] = json['categories']['name'];
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка поиска услуг: $e');
    }
  }

  @override
  Future<List<Service>> getServicesByCategory(String categoryId) async {
    try {
      final organizationId = await getOrCreateOrganizationId();

      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner(
              id,
              name
            )
          ''')
          .eq('organization_id', organizationId)
          .eq('category_id', categoryId)
          .order('name', ascending: true);

      return response.map<Service>((json) {
        json['category_id'] = json['categories']['id'];
        json['category_name'] = json['categories']['name'];
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка получения услуг по категории: $e');
    }
  }

  @override
  Future<List<Service>> getServicesByMaster(String masterId) async {
    try {
      final organizationId = await getOrCreateOrganizationId();

      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_categories!inner(
              id,
              name
            )
          ''')
          .eq('organization_id', organizationId)
          .contains('master_ids', [masterId])
          .order('name', ascending: true);

      return response.map<Service>((json) {
        json['category_id'] = json['categories']['id'];
        json['category_name'] = json['categories']['name'];
        return Service.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка получения услуг мастера: $e');
    }
  }

  @override
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      final organizationId = await getOrCreateOrganizationId();

      final response = await _supabase
          .from('service_categories')
          .select('*')
          .eq('organization_id', organizationId)
          .order('sort_order', ascending: true);

      return response.map<ServiceCategory>((json) => ServiceCategory.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки категорий услуг: $e');
    }
  }

  @override
  Future<ServiceCategory?> getCategoryById(String categoryId) async {
    try {
      final response = await _supabase
          .from('service_categories')
          .select('*')
          .eq('id', categoryId)
          .maybeSingle();

      if (response == null) return null;
      return ServiceCategory.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка получения категории: $e');
    }
  }

  @override
  Future<ServiceCategory> createCategory(ServiceCategory category) async {
    try {
      final organizationId = await getOrCreateOrganizationId();

      final categoryData = category.toJson();
      categoryData['organization_id'] = organizationId;
      categoryData.remove('id'); // Удаляем ID, чтобы база сгенерировала новый

      final response = await _supabase
          .from('service_categories')
          .insert(categoryData)
          .select()
          .single();

      return ServiceCategory.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка создания категории: $e');
    }
  }

  @override
  Future<ServiceCategory> updateCategory(ServiceCategory category) async {
    try {
      final response = await _supabase
          .from('service_categories')
          .update(category.toJson())
          .eq('id', category.id)
          .select()
          .single();

      return ServiceCategory.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка обновления категории: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _supabase
          .from('service_categories')
          .delete()
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('Ошибка удаления категории: $e');
    }
  }
}
