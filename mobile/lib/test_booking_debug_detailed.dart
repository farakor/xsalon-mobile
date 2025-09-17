import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/services/booking_service.dart';
import 'data/services/client_service.dart';
import 'data/models/client.dart';

/// Детальный тест создания записи с пошаговыми логами
/// Добавьте этот код в ваше приложение для отладки
class DetailedBookingTest {
  static Future<void> runDetailedTest() async {
    print('🔍 === ДЕТАЛЬНЫЙ ТЕСТ СОЗДАНИЯ ЗАПИСИ ===');
    
    try {
      final supabase = Supabase.instance.client;
      final bookingService = BookingService();
      final clientService = ClientService();
      
      // 1. Проверяем авторизацию
      print('🔍 1. Проверяем авторизацию...');
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        print('❌ ПРОБЛЕМА: Пользователь не авторизован');
        return;
      }
      print('✅ Пользователь авторизован: ${currentUser.id}');
      print('   Email: ${currentUser.email ?? 'не указан'}');
      print('   Phone: ${currentUser.phone ?? 'не указан'}');
      
      // 2. Проверяем профиль пользователя
      print('🔍 2. Проверяем профиль пользователя...');
      try {
        final userProfile = await supabase
            .from('user_profiles')
            .select('id, full_name, role, phone')
            .eq('id', currentUser.id)
            .single();
        print('✅ Профиль найден:');
        print('   Имя: ${userProfile['full_name'] ?? 'не указано'}');
        print('   Роль: ${userProfile['role'] ?? 'не указана'}');
        print('   Телефон: ${userProfile['phone'] ?? 'не указан'}');
      } catch (e) {
        print('❌ ПРОБЛЕМА: Профиль пользователя не найден: $e');
        return;
      }
      
      // 3. Получаем ID мастера
      print('🔍 3. Получаем ID мастера...');
      String masterId;
      try {
        masterId = await bookingService.getCurrentMasterId();
        print('✅ Мастер найден: $masterId');
      } catch (e) {
        print('❌ ПРОБЛЕМА: Не удалось получить ID мастера: $e');
        return;
      }
      
      // 4. Получаем список клиентов
      print('🔍 4. Получаем список клиентов...');
      List<Client> clients;
      try {
        clients = await clientService.getClients();
        print('✅ Найдено клиентов: ${clients.length}');
        if (clients.isNotEmpty) {
          print('   Первый клиент: ${clients.first.fullName} (${clients.first.id})');
          print('   Телефон: ${clients.first.phone}');
          print('   Статус: ${clients.first.status}');
        }
      } catch (e) {
        print('❌ ПРОБЛЕМА: Не удалось получить клиентов: $e');
        return;
      }
      
      if (clients.isEmpty) {
        print('❌ ПРОБЛЕМА: Нет клиентов в системе');
        return;
      }
      
      // 5. Получаем список услуг
      print('🔍 5. Получаем список услуг...');
      List<Map<String, dynamic>> services;
      try {
        final response = await supabase
            .from('services')
            .select('id, name, price, duration_minutes')
            .eq('is_active', true)
            .limit(5);
        services = List<Map<String, dynamic>>.from(response);
        print('✅ Найдено услуг: ${services.length}');
        if (services.isNotEmpty) {
          print('   Первая услуга: ${services.first['name']} (${services.first['id']})');
          print('   Цена: ${services.first['price']}');
          print('   Длительность: ${services.first['duration_minutes']} мин');
        }
      } catch (e) {
        print('❌ ПРОБЛЕМА: Не удалось получить услуги: $e');
        return;
      }
      
      if (services.isEmpty) {
        print('❌ ПРОБЛЕМА: Нет услуг в системе');
        return;
      }
      
      // 6. Проверяем доступность времени
      print('🔍 6. Проверяем доступность времени...');
      final startTime = DateTime.now().add(const Duration(hours: 2));
      final endTime = startTime.add(Duration(minutes: services.first['duration_minutes'] ?? 60));
      
      try {
        final isAvailable = await bookingService.isTimeSlotAvailable(
          masterId: masterId,
          startTime: startTime,
          endTime: endTime,
        );
        print('✅ Проверка времени завершена: ${isAvailable ? 'доступно' : 'занято'}');
      } catch (e) {
        print('❌ ПРОБЛЕМА: Ошибка проверки времени: $e');
        return;
      }
      
      // 7. Создаем запись
      print('🔍 7. Создаем запись...');
      final testClient = clients.first;
      final testService = services.first;
      final price = (testService['price'] ?? 100.0).toDouble();
      
      print('   Данные для записи:');
      print('     Клиент: ${testClient.fullName} (${testClient.id})');
      print('     Мастер: $masterId');
      print('     Услуга: ${testService['name']} (${testService['id']})');
      print('     Время: $startTime - $endTime');
      print('     Цена: $price');
      
      try {
        final bookingId = await bookingService.createBooking(
          clientId: testClient.id,
          masterId: masterId,
          serviceId: testService['id'],
          startTime: startTime,
          endTime: endTime,
          totalPrice: price,
          finalPrice: price,
          clientNotes: 'Тестовая запись из приложения',
        );
        
        print('🎉 УСПЕХ! Запись создана с ID: $bookingId');
        
        // Проверяем, что запись действительно создалась
        final createdBooking = await supabase
            .from('bookings')
            .select('id, status, client_id, master_id, service_id')
            .eq('id', bookingId)
            .single();
            
        print('✅ Подтверждение: запись найдена в БД');
        print('   ID: ${createdBooking['id']}');
        print('   Статус: ${createdBooking['status']}');
        print('   Клиент ID: ${createdBooking['client_id']}');
        print('   Мастер ID: ${createdBooking['master_id']}');
        print('   Услуга ID: ${createdBooking['service_id']}');
        
      } catch (e) {
        print('❌ ОШИБКА создания записи: $e');
        if (e is PostgrestException) {
          print('   Код ошибки: ${e.code}');
          print('   Сообщение: ${e.message}');
          print('   Детали: ${e.details}');
          print('   Подсказка: ${e.hint}');
        }
        
        // Дополнительная диагностика
        print('🔍 Дополнительная диагностика:');
        
        // Проверяем, существует ли клиент
        try {
          final clientCheck = await supabase
              .from('clients')
              .select('id, full_name')
              .eq('id', testClient.id)
              .single();
          print('✅ Клиент существует: ${clientCheck['full_name']}');
        } catch (clientError) {
          print('❌ Клиент не найден: $clientError');
        }
        
        // Проверяем, существует ли мастер
        try {
          final masterCheck = await supabase
              .from('masters')
              .select('id, specialization')
              .eq('id', masterId)
              .single();
          print('✅ Мастер существует: ${masterCheck['specialization']}');
        } catch (masterError) {
          print('❌ Мастер не найден: $masterError');
        }
        
        // Проверяем, существует ли услуга
        try {
          final serviceCheck = await supabase
              .from('services')
              .select('id, name')
              .eq('id', testService['id'])
              .single();
          print('✅ Услуга существует: ${serviceCheck['name']}');
        } catch (serviceError) {
          print('❌ Услуга не найдена: $serviceError');
        }
      }
      
    } catch (e) {
      print('❌ ОБЩАЯ ОШИБКА: $e');
    }
    
    print('🔍 === КОНЕЦ ДЕТАЛЬНОГО ТЕСТА ===');
  }
}
