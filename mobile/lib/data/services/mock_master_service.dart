import '../../domain/entities/master.dart';

/// Мок-сервис для тестирования мастеров без подключения к Supabase
class MockMasterService {
  static List<MasterEntity> getMockMasters() {
    return [
      MasterEntity(
        id: 'master1',
        userId: 'user1',
        fullName: 'Анна Иванова',
        phone: '+998901234567',
        email: 'anna@example.com',
        specialization: ['Стрижки', 'Укладки'],
        description: 'Опытный мастер-парикмахер с 5-летним стажем',
        experienceYears: 5,
        rating: 4.8,
        reviewsCount: 127,
        workingHours: {
          'monday': {'start': '09:00', 'end': '18:00'},
          'tuesday': {'start': '09:00', 'end': '18:00'},
          'wednesday': {'start': '09:00', 'end': '18:00'},
          'thursday': {'start': '09:00', 'end': '18:00'},
          'friday': {'start': '09:00', 'end': '18:00'},
          'saturday': {'start': '10:00', 'end': '16:00'},
        },
        breakDurationMinutes: 15,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MasterEntity(
        id: 'master2',
        userId: 'user2',
        fullName: 'Мария Петрова',
        phone: '+998901234568',
        email: 'maria@example.com',
        specialization: ['Окрашивание', 'Стрижки'],
        description: 'Специалист по окрашиванию и современным техникам',
        experienceYears: 3,
        rating: 4.5,
        reviewsCount: 89,
        workingHours: {
          'monday': {'start': '10:00', 'end': '19:00'},
          'tuesday': {'start': '10:00', 'end': '19:00'},
          'wednesday': {'start': '10:00', 'end': '19:00'},
          'thursday': {'start': '10:00', 'end': '19:00'},
          'friday': {'start': '10:00', 'end': '19:00'},
          'saturday': {'start': '09:00', 'end': '17:00'},
        },
        breakDurationMinutes: 20,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MasterEntity(
        id: 'master3',
        userId: 'user3',
        fullName: 'Елена Сидорова',
        phone: '+998901234569',
        email: 'elena@example.com',
        specialization: ['Маникюр', 'Педикюр'],
        description: 'Мастер маникюра и педикюра высшей категории',
        experienceYears: 7,
        rating: 4.9,
        reviewsCount: 203,
        workingHours: {
          'monday': {'start': '09:00', 'end': '17:00'},
          'tuesday': {'start': '09:00', 'end': '17:00'},
          'wednesday': {'start': '09:00', 'end': '17:00'},
          'thursday': {'start': '09:00', 'end': '17:00'},
          'friday': {'start': '09:00', 'end': '17:00'},
          'saturday': {'start': '10:00', 'end': '15:00'},
        },
        breakDurationMinutes: 10,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Получить мастеров для конкретной услуги
  static List<MasterEntity> getMastersForService(String serviceId) {
    final allMasters = getMockMasters();
    
    // Простая логика: разные мастера для разных услуг
    switch (serviceId) {
      case '1': // Женская стрижка
      case '2': // Мужская стрижка
        return [allMasters[0], allMasters[1]]; // Анна и Мария
      case '3': // Окрашивание
        return [allMasters[1]]; // Только Мария
      case '4': // Укладка
        return [allMasters[0]]; // Только Анна
      case '5': // Маникюр
        return [allMasters[2]]; // Только Елена
      default:
        return allMasters;
    }
  }
}
