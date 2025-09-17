import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/services/booking_service.dart';
import 'data/services/client_service.dart';
import 'data/models/client.dart';

/// Тестовый скрипт для отладки создания записей
/// Запустите этот файл для проверки создания записи с детальными логами
class BookingCreationTest {
  static Future<void> testBookingCreation() async {
    print('=== ТЕСТ СОЗДАНИЯ ЗАПИСИ ===');
    
    try {
      final supabase = Supabase.instance.client;
      final bookingService = BookingService();
      final clientService = ClientService();
      
      // 1. Проверяем авторизацию
      final currentUser = supabase.auth.currentUser;
      print('1. Текущий пользователь: ${currentUser?.id ?? 'НЕ АВТОРИЗОВАН'}');
      
      if (currentUser == null) {
        print('ОШИБКА: Пользователь не авторизован');
        return;
      }
      
      // 2. Получаем ID мастера
      print('2. Получаем ID мастера...');
      String masterId;
      try {
        masterId = await bookingService.getCurrentMasterId();
        print('   Мастер ID: $masterId');
      } catch (e) {
        print('   ОШИБКА получения мастера: $e');
        return;
      }
      
      // 3. Получаем список клиентов
      print('3. Получаем список клиентов...');
      List<Client> clients;
      try {
        clients = await clientService.getClients();
        print('   Найдено клиентов: ${clients.length}');
        if (clients.isNotEmpty) {
          print('   Первый клиент: ${clients.first.fullName} (${clients.first.id})');
        }
      } catch (e) {
        print('   ОШИБКА получения клиентов: $e');
        return;
      }
      
      if (clients.isEmpty) {
        print('ОШИБКА: Нет клиентов для тестирования');
        return;
      }
      
      // 4. Получаем список услуг
      print('4. Получаем список услуг...');
      List<Map<String, dynamic>> services;
      try {
        final response = await supabase
            .from('services')
            .select('id, name, price, duration_minutes')
            .eq('is_active', true)
            .limit(5);
        services = List<Map<String, dynamic>>.from(response);
        print('   Найдено услуг: ${services.length}');
        if (services.isNotEmpty) {
          print('   Первая услуга: ${services.first['name']} (${services.first['id']})');
        }
      } catch (e) {
        print('   ОШИБКА получения услуг: $e');
        return;
      }
      
      if (services.isEmpty) {
        print('ОШИБКА: Нет услуг для тестирования');
        return;
      }
      
      // 5. Создаем тестовую запись
      print('5. Создаем тестовую запись...');
      final testClient = clients.first;
      final testService = services.first;
      final startTime = DateTime.now().add(const Duration(days: 1));
      final endTime = startTime.add(Duration(minutes: testService['duration_minutes'] ?? 60));
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
          clientNotes: 'Тестовая запись',
        );
        
        print('УСПЕХ! Запись создана с ID: $bookingId');
        
        // Проверяем, что запись действительно создалась
        final createdBooking = await supabase
            .from('bookings')
            .select('*')
            .eq('id', bookingId)
            .single();
            
        print('Подтверждение: запись найдена в БД');
        print('  ID: ${createdBooking['id']}');
        print('  Статус: ${createdBooking['status']}');
        print('  Клиент ID: ${createdBooking['client_id']}');
        print('  Мастер ID: ${createdBooking['master_id']}');
        
      } catch (e) {
        print('ОШИБКА создания записи: $e');
        if (e is PostgrestException) {
          print('Детали PostgrestException:');
          print('  Код: ${e.code}');
          print('  Сообщение: ${e.message}');
          print('  Детали: ${e.details}');
          print('  Подсказка: ${e.hint}');
        }
      }
      
    } catch (e) {
      print('ОБЩАЯ ОШИБКА: $e');
    }
    
    print('=== КОНЕЦ ТЕСТА ===');
  }
}
