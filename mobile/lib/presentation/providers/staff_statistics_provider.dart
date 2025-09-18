import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/staff_statistics.dart';
import '../../data/models/appointment.dart';
import 'appointments_provider.dart';

// Провайдер для получения статистики мастера
final staffStatisticsProvider = FutureProvider<StaffStatistics>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  
  try {
    final masterId = await bookingService.getCurrentMasterId();
    
    // Получаем данные за последние 30 дней для быстрой статистики
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, now.day);
    final endDate = now;
    
    // Получаем записи за период
    final bookingsData = await bookingService.getMasterBookingsForDateRange(
      masterId: masterId,
      startDate: startDate,
      endDate: endDate,
    );
    
    // Преобразуем в модель Appointment для удобства работы
    final appointments = bookingsData.map((booking) {
      final client = booking['clients'] as Map<String, dynamic>?;
      final service = booking['services'] as Map<String, dynamic>?;
      
      return Appointment(
        id: booking['id'],
        clientId: booking['client_id'] ?? '',
        clientName: client?['full_name'] ?? 'Неизвестный клиент',
        clientPhone: client?['phone'] ?? '',
        serviceId: booking['service_id'] ?? '',
        serviceName: service?['name'] ?? 'Услуга',
        startTime: DateTime.parse(booking['start_time']),
        endTime: DateTime.parse(booking['end_time']),
        status: AppointmentStatus.values.firstWhere(
          (e) => e.name == booking['status'],
          orElse: () => AppointmentStatus.pending,
        ),
        price: (booking['total_price'] as num?)?.toDouble() ?? 0.0,
        notes: booking['client_notes'],
        masterNotes: booking['master_notes'],
      );
    }).toList();
    
    // Вычисляем статистику
    final totalAppointments = appointments.length;
    final completedAppointments = appointments
        .where((a) => a.status == AppointmentStatus.confirmed)
        .length;
    final cancelledAppointments = appointments
        .where((a) => a.status == AppointmentStatus.cancelled)
        .length;
    
    final totalRevenue = appointments
        .where((a) => a.status == AppointmentStatus.confirmed)
        .fold<double>(0, (sum, appointment) => sum + appointment.price);
    
    // Уникальные клиенты
    final uniqueClients = appointments
        .map((a) => a.clientId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;
    
    // Статистика по услугам
    final serviceStats = <String, int>{};
    for (final appointment in appointments) {
      if (appointment.status == AppointmentStatus.confirmed) {
        serviceStats[appointment.serviceName] = 
            (serviceStats[appointment.serviceName] ?? 0) + 1;
      }
    }
    
    // Доход по месяцам (последние 6 месяцев)
    final monthlyRevenue = <String, double>{};
    final monthNames = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthName = monthNames[monthDate.month - 1];
      
      final monthRevenue = appointments
          .where((a) => 
              a.status == AppointmentStatus.confirmed &&
              a.startTime.year == monthDate.year &&
              a.startTime.month == monthDate.month)
          .fold<double>(0, (sum, appointment) => sum + appointment.price);
      
      monthlyRevenue[monthName] = monthRevenue;
    }
    
    return StaffStatistics(
      totalAppointments: totalAppointments,
      completedAppointments: completedAppointments,
      cancelledAppointments: cancelledAppointments,
      totalRevenue: totalRevenue,
      averageRating: 4.8, // TODO: Получать реальный рейтинг из базы
      totalClients: uniqueClients,
      repeatClients: (uniqueClients * 0.75).round(), // TODO: Вычислять реальных повторных клиентов
      serviceStats: serviceStats,
      monthlyRevenue: monthlyRevenue,
      periodStart: startDate,
      periodEnd: endDate,
    );
  } catch (e) {
    // Возвращаем пустую статистику в случае ошибки
    return StaffStatistics(
      totalAppointments: 0,
      completedAppointments: 0,
      cancelledAppointments: 0,
      totalRevenue: 0.0,
      averageRating: 0.0,
      totalClients: 0,
      repeatClients: 0,
      serviceStats: {},
      monthlyRevenue: {},
      periodStart: DateTime.now().subtract(const Duration(days: 30)),
      periodEnd: DateTime.now(),
    );
  }
});

// Провайдер для статистики на сегодня
final todayStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  
  try {
    final masterId = await bookingService.getCurrentMasterId();
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    // Получаем записи на сегодня
    final todayBookings = await bookingService.getMasterBookingsForDateRange(
      masterId: masterId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
    
    final totalToday = todayBookings.length;
    final completedToday = todayBookings
        .where((b) => b['status'] == 'completed')
        .length;
    final revenueToday = todayBookings
        .where((b) => b['status'] == 'completed')
        .fold<double>(0, (sum, booking) => 
            sum + ((booking['total_price'] as num?)?.toDouble() ?? 0.0));
    
    return {
      'totalToday': totalToday,
      'completedToday': completedToday,
      'revenueToday': revenueToday,
    };
  } catch (e) {
    return {
      'totalToday': 0,
      'completedToday': 0,
      'revenueToday': 0.0,
    };
  }
});
