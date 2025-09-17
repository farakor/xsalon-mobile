import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/timezone_utils.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Создать новую запись
  Future<String> createBooking({
    required String clientId,
    required String masterId,
    required String serviceId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    required double finalPrice,
    String? clientNotes,
  }) async {
    try {
      print('BookingService: Creating booking...');
      print('  Client ID: $clientId');
      print('  Master ID: $masterId');
      print('  Service ID: $serviceId');
      print('  Start time: $startTime');
      print('  End time: $endTime');
      print('  Total price: $totalPrice');

      // Проверяем что клиент существует
      print('BookingService: Checking if client exists...');
      final clientResponse = await _supabase
          .from('clients')
          .select('id, full_name')
          .eq('id', clientId)
          .maybeSingle();

      if (clientResponse == null) {
        print('BookingService: Client not found with ID: $clientId');
        throw ServerFailure('Клиент не найден с ID: $clientId');
      }

      print('  Client found: ${clientResponse['full_name']}');

      // Проверяем что мастер существует
      print('BookingService: Checking if master exists...');
      final masterResponse = await _supabase
          .from('masters')
          .select('id, specialization, description')
          .eq('id', masterId)
          .maybeSingle();

      if (masterResponse == null) {
        print('BookingService: Master not found with ID: $masterId');
        throw ServerFailure('Мастер не найден с ID: $masterId');
      }

      final masterSpec = masterResponse['specialization'] is List 
          ? (masterResponse['specialization'] as List).join(', ')
          : masterResponse['specialization']?.toString() ?? 'Мастер';
      print('  Master found: $masterSpec');

      // Проверяем что услуга существует
      print('BookingService: Checking if service exists...');
      final serviceResponse = await _supabase
          .from('services')
          .select('id, name')
          .eq('id', serviceId)
          .maybeSingle();

      if (serviceResponse == null) {
        print('BookingService: Service not found with ID: $serviceId');
        throw ServerFailure('Услуга не найдена с ID: $serviceId');
      }

      print('  Service found: ${serviceResponse['name']}');

      // Создаем запись
      final response = await _supabase
          .from('bookings')
          .insert({
            'client_id': clientId, // Используем clients.id напрямую
            'master_id': masterId,
            'service_id': serviceId,
            'start_time': TimezoneUtils.samarkandToUtc(startTime).toIso8601String(),
            'end_time': TimezoneUtils.samarkandToUtc(endTime).toIso8601String(),
            'status': 'pending',
            'total_price': totalPrice,
            'final_price': finalPrice,
            'client_notes': clientNotes,
            'payment_status': 'unpaid',
          })
          .select('id')
          .single();

      final bookingId = response['id'] as String;
      print('BookingService: Booking created successfully with ID: $bookingId');
      
      return bookingId;
    } catch (e) {
      print('BookingService: Error creating booking: $e');
      throw ServerFailure('Ошибка создания записи: $e');
    }
  }

  /// Получить ID текущего мастера
  Future<String> getCurrentMasterId() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerFailure('Пользователь не авторизован');
      }

      // Проверяем существующую запись мастера
      final masterResponse = await _supabase
          .from('masters')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (masterResponse == null) {
        throw ServerFailure('Мастер не найден. Обратитесь к администратору.');
      }

      return masterResponse['id'];
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Ошибка получения ID мастера: $e');
    }
  }

  // Метод больше не нужен - убрана логика мультиорганизационности

  /// Проверить доступность времени для записи
  Future<bool> isTimeSlotAvailable({
    required String masterId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      print('BookingService: Checking time slot availability...');
      print('  Master ID: $masterId');
      print('  Start time: $startTime');
      print('  End time: $endTime');

      // Сначала получаем все записи мастера (без фильтров по времени)
      final allBookings = await _supabase
          .from('bookings')
          .select('id, start_time, end_time, status')
          .eq('master_id', masterId);
          
      print('  Total bookings for master: ${allBookings.length}');
      
      // Фильтруем только активные записи
      final response = allBookings.where((booking) => 
          booking['status'] != 'cancelled'
      ).toList();
      
      print('  Active bookings for master: ${response.length}');

      print('  Found ${response.length} existing bookings for this master');

      // Проверяем пересечение времени вручную для более точного контроля
      for (final booking in response) {
        final existingStart = TimezoneUtils.toSamarkandTime(DateTime.parse(booking['start_time']));
        final existingEnd = TimezoneUtils.toSamarkandTime(DateTime.parse(booking['end_time']));
        final newStart = startTime; // Уже в самаркандском времени
        final newEnd = endTime; // Уже в самаркандском времени
        
        print('  Checking overlap with booking: ${existingStart} - ${existingEnd}');
        print('    New booking: ${newStart} - ${newEnd}');
        
        // Проверяем пересечение: новое время пересекается с существующим если:
        // (новое_начало < существующий_конец) И (новый_конец > существующее_начало)
        final condition1 = newStart.isBefore(existingEnd);
        final condition2 = newEnd.isAfter(existingStart);
        final hasOverlap = condition1 && condition2;
        
        print('    newStart.isBefore(existingEnd): $condition1 (${newStart} < ${existingEnd})');
        print('    newEnd.isAfter(existingStart): $condition2 (${newEnd} > ${existingStart})');
        print('    hasOverlap: $hasOverlap');
        
        if (hasOverlap) {
          print('  Time slot is NOT available - overlaps with existing booking');
          return false;
        } else {
          print('  No overlap with this booking');
        }
      }

      print('  Time slot is available');
      return true;
    } catch (e) {
      print('BookingService: Error checking time slot availability: $e');
      return false; // В случае ошибки считаем слот недоступным для безопасности
    }
  }

  /// Получить записи мастера на дату
  Future<List<Map<String, dynamic>>> getMasterBookingsForDate({
    required String masterId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('bookings')
          .select('''
            id,
            client_id,
            service_id,
            start_time,
            end_time,
            status,
            total_price,
            final_price,
            client_notes,
            master_notes,
            clients!inner(full_name, phone),
            services!inner(name, duration_minutes)
          ''')
          .eq('master_id', masterId)
          .gte('start_time', TimezoneUtils.samarkandToUtc(startOfDay).toIso8601String())
          .lt('start_time', TimezoneUtils.samarkandToUtc(endOfDay).toIso8601String())
          .neq('status', 'cancelled')
          .order('start_time');

      // Конвертируем время обратно в самаркандское
      final convertedResponse = response.map((booking) {
        return {
          ...booking,
          'start_time': TimezoneUtils.toSamarkandTime(DateTime.parse(booking['start_time'])).toIso8601String(),
          'end_time': TimezoneUtils.toSamarkandTime(DateTime.parse(booking['end_time'])).toIso8601String(),
        };
      }).toList();

      return List<Map<String, dynamic>>.from(convertedResponse);
    } catch (e) {
      print('BookingService: Error getting master bookings: $e');
      return [];
    }
  }

  /// Получить все записи мастера на диапазон дат
  Future<List<Map<String, dynamic>>> getMasterBookingsForDateRange({
    required String masterId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            id,
            client_id,
            service_id,
            start_time,
            end_time,
            status,
            total_price,
            final_price,
            client_notes,
            master_notes,
            clients!inner(full_name, phone),
            services!inner(name, duration_minutes)
          ''')
          .eq('master_id', masterId)
          .gte('start_time', TimezoneUtils.samarkandToUtc(startDate).toIso8601String())
          .lte('start_time', TimezoneUtils.samarkandToUtc(endDate).toIso8601String())
          .neq('status', 'cancelled')
          .order('start_time');

      // Конвертируем время обратно в самаркандское
      final convertedResponse = response.map((booking) {
        return {
          ...booking,
          'start_time': TimezoneUtils.toSamarkandTime(DateTime.parse(booking['start_time'])).toIso8601String(),
          'end_time': TimezoneUtils.toSamarkandTime(DateTime.parse(booking['end_time'])).toIso8601String(),
        };
      }).toList();

      return List<Map<String, dynamic>>.from(convertedResponse);
    } catch (e) {
      print('BookingService: Error getting master bookings for date range: $e');
      return [];
    }
  }

  /// Обновить статус записи
  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  }) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', bookingId);
    } catch (e) {
      throw ServerFailure('Ошибка обновления статуса записи: $e');
    }
  }

  /// Обновить заметки мастера для записи
  Future<void> updateBookingNotes({
    required String bookingId,
    required String notes,
  }) async {
    try {
      await _supabase
          .from('bookings')
          .update({'master_notes': notes})
          .eq('id', bookingId);
    } catch (e) {
      throw ServerFailure('Ошибка обновления заметок: $e');
    }
  }
}
