import '../../domain/entities/service.dart';

/// Мок-сервис для тестирования без подключения к Supabase
class MockServiceService {
  static List<ServiceEntity> getMockServices() {
    return [
      ServiceEntity(
        id: '1',
        masterId: 'master1',
        name: 'Женская стрижка',
        description: 'Стильная стрижка для женщин',
        price: 50000,
        durationMinutes: 60,
        preparationTimeMinutes: 5,
        cleanupTimeMinutes: 5,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceEntity(
        id: '2',
        masterId: 'master1',
        name: 'Мужская стрижка',
        description: 'Классическая мужская стрижка',
        price: 30000,
        durationMinutes: 30,
        preparationTimeMinutes: 5,
        cleanupTimeMinutes: 5,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceEntity(
        id: '3',
        masterId: 'master2',
        name: 'Окрашивание волос',
        description: 'Профессиональное окрашивание',
        price: 80000,
        durationMinutes: 120,
        preparationTimeMinutes: 10,
        cleanupTimeMinutes: 10,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceEntity(
        id: '4',
        masterId: 'master2',
        name: 'Укладка волос',
        description: 'Красивая укладка на любой случай',
        price: 25000,
        durationMinutes: 45,
        preparationTimeMinutes: 5,
        cleanupTimeMinutes: 5,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceEntity(
        id: '5',
        masterId: 'master3',
        name: 'Маникюр',
        description: 'Классический маникюр',
        price: 35000,
        durationMinutes: 60,
        preparationTimeMinutes: 5,
        cleanupTimeMinutes: 10,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<ServiceCategoryEntity> getMockCategories() {
    return [
      ServiceCategoryEntity(
        id: 'cat1',
        name: 'Стрижки',
        description: 'Мужские и женские стрижки',
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceCategoryEntity(
        id: 'cat2',
        name: 'Окрашивание',
        description: 'Окрашивание и колорирование',
        sortOrder: 2,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceCategoryEntity(
        id: 'cat3',
        name: 'Укладки',
        description: 'Укладки и прически',
        sortOrder: 3,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceCategoryEntity(
        id: 'cat4',
        name: 'Маникюр',
        description: 'Маникюр и педикюр',
        sortOrder: 4,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
