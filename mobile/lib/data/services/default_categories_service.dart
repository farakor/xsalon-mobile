import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service.dart';

class DefaultCategoriesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Создает категории по умолчанию, если их нет
  Future<void> createDefaultCategoriesIfNeeded() async {
    try {
      // Проверяем, есть ли уже категории
      final existingCategories = await _supabase
          .from('service_categories')
          .select('id')
          .eq('is_active', true)
          .limit(1);

      // Если категории уже есть, ничего не делаем
      if (existingCategories.isNotEmpty) {
        return;
      }

      // Создаем категории по умолчанию
      final defaultCategories = _getDefaultCategories();
      
      await _supabase
          .from('service_categories')
          .insert(defaultCategories.map((cat) => cat.toJson()).toList());

    } catch (e) {
      throw Exception('Ошибка создания категорий по умолчанию: $e');
    }
  }

  /// Возвращает список категорий по умолчанию
  List<ServiceCategory> _getDefaultCategories() {
    final now = DateTime.now();
    
    return [
      ServiceCategory(
        id: '',
        name: 'Парикмахерские услуги',
        description: 'Стрижки, укладки, окрашивание волос',
        iconName: 'content_cut',
        sortOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Маникюр и педикюр',
        description: 'Уход за ногтями рук и ног',
        iconName: 'back_hand',
        sortOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Косметология',
        description: 'Уход за лицом и кожей',
        iconName: 'face',
        sortOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Массаж и SPA',
        description: 'Релаксация и уход за телом',
        iconName: 'spa',
        sortOrder: 4,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Брови и ресницы',
        description: 'Оформление бровей, наращивание ресниц',
        iconName: 'visibility',
        sortOrder: 5,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Депиляция и эпиляция',
        description: 'Удаление нежелательных волос',
        iconName: 'content_cut',
        sortOrder: 6,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Татуаж и перманентный макияж',
        description: 'Перманентный макияж губ, бровей, глаз',
        iconName: 'brush',
        sortOrder: 7,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Визаж и макияж',
        description: 'Профессиональный макияж',
        iconName: 'palette',
        sortOrder: 8,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Уход за телом',
        description: 'Обертывания, скрабы, пилинги для тела',
        iconName: 'self_care',
        sortOrder: 9,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Аппаратная косметология',
        description: 'Процедуры на косметологических аппаратах',
        iconName: 'medical_services',
        sortOrder: 10,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Инъекционная косметология',
        description: 'Ботокс, филлеры, мезотерапия',
        iconName: 'healing',
        sortOrder: 11,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Мужские услуги',
        description: 'Специализированные услуги для мужчин',
        iconName: 'man',
        sortOrder: 12,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Свадебные услуги',
        description: 'Комплексная подготовка к свадьбе',
        iconName: 'favorite',
        sortOrder: 13,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceCategory(
        id: '',
        name: 'Детские услуги',
        description: 'Услуги для детей и подростков',
        iconName: 'child_care',
        sortOrder: 14,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Возвращает список популярных услуг по категориям
  Map<String, List<Map<String, dynamic>>> getPopularServicesByCategory() {
    return {
      'Парикмахерские услуги': [
        {'name': 'Женская стрижка', 'duration': 60, 'price': 150000},
        {'name': 'Мужская стрижка', 'duration': 30, 'price': 80000},
        {'name': 'Окрашивание волос', 'duration': 120, 'price': 300000},
        {'name': 'Укладка волос', 'duration': 45, 'price': 100000},
        {'name': 'Мелирование', 'duration': 180, 'price': 400000},
      ],
      'Маникюр и педикюр': [
        {'name': 'Классический маникюр', 'duration': 90, 'price': 120000},
        {'name': 'Гель-лак маникюр', 'duration': 120, 'price': 180000},
        {'name': 'Педикюр классический', 'duration': 90, 'price': 150000},
        {'name': 'Наращивание ногтей', 'duration': 150, 'price': 250000},
      ],
      'Брови и ресницы': [
        {'name': 'Коррекция бровей', 'duration': 30, 'price': 50000},
        {'name': 'Окрашивание бровей', 'duration': 20, 'price': 40000},
        {'name': 'Наращивание ресниц классика', 'duration': 120, 'price': 200000},
        {'name': 'Наращивание ресниц 2D-3D', 'duration': 150, 'price': 300000},
        {'name': 'Ламинирование ресниц', 'duration': 90, 'price': 150000},
      ],
      'Косметология': [
        {'name': 'Базовый уход за лицом', 'duration': 60, 'price': 200000},
        {'name': 'Глубокая чистка лица', 'duration': 90, 'price': 350000},
        {'name': 'Химический пилинг', 'duration': 45, 'price': 250000},
      ],
      'Депиляция и эпиляция': [
        {'name': 'Депиляция ног полностью', 'duration': 60, 'price': 120000},
        {'name': 'Депиляция подмышек', 'duration': 15, 'price': 30000},
        {'name': 'Депиляция бикини классика', 'duration': 30, 'price': 80000},
        {'name': 'Шугаринг ног', 'duration': 90, 'price': 150000},
      ],
      'Визаж и макияж': [
        {'name': 'Дневной макияж', 'duration': 45, 'price': 100000},
        {'name': 'Вечерний макияж', 'duration': 60, 'price': 150000},
        {'name': 'Свадебный макияж', 'duration': 90, 'price': 250000},
      ],
      'Мужские услуги': [
        {'name': 'Мужская стрижка + борода', 'duration': 45, 'price': 100000},
        {'name': 'Королевское бритье', 'duration': 60, 'price': 120000},
        {'name': 'Мужской маникюр', 'duration': 60, 'price': 80000},
      ],
    };
  }
}
