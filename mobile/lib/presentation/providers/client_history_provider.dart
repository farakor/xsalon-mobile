import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/appointment.dart';
import '../../data/services/booking_service.dart';
import 'auth_provider.dart';

// Состояние истории записей клиента
class ClientHistoryState {
  final List<Appointment> appointments;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final AppointmentStatus? filterStatus;

  const ClientHistoryState({
    this.appointments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterStartDate,
    this.filterEndDate,
    this.filterStatus,
  });

  ClientHistoryState copyWith({
    List<Appointment>? appointments,
    bool? isLoading,
    String? errorMessage,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    AppointmentStatus? filterStatus,
  }) {
    return ClientHistoryState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  // Получить отфильтрованные записи
  List<Appointment> get filteredAppointments {
    var filtered = appointments;

    // Фильтр по статусу
    if (filterStatus != null) {
      filtered = filtered.where((appointment) => appointment.status == filterStatus).toList();
    }

    return filtered;
  }

  // Группировка записей по месяцам
  Map<String, List<Appointment>> get appointmentsByMonth {
    final Map<String, List<Appointment>> grouped = {};
    
    for (final appointment in filteredAppointments) {
      final monthKey = '${appointment.startTime.year}-${appointment.startTime.month.toString().padLeft(2, '0')}';
      final monthName = _getMonthName(appointment.startTime.month, appointment.startTime.year);
      
      if (!grouped.containsKey(monthName)) {
        grouped[monthName] = [];
      }
      grouped[monthName]!.add(appointment);
    }
    
    return grouped;
  }

  String _getMonthName(int month, int year) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return '${months[month - 1]} $year';
  }
}

// Провайдер для управления историей записей клиента
class ClientHistoryNotifier extends StateNotifier<ClientHistoryState> {
  ClientHistoryNotifier(this._bookingService) : super(const ClientHistoryState());

  final BookingService _bookingService;

  /// Загрузить историю записей клиента
  Future<void> loadClientHistory(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Получаем ID клиента по ID пользователя
      final clientId = await _bookingService.getClientIdByUserId(userId);
      
      if (clientId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Клиент не найден',
          appointments: [],
        );
        return;
      }

      // Получаем историю записей
      final bookingsData = await _bookingService.getClientBookingHistory(
        clientId: clientId,
        startDate: state.filterStartDate,
        endDate: state.filterEndDate,
      );

      // Преобразуем данные в модель Appointment
      final appointments = bookingsData.map((booking) {
        final client = booking['clients'] != null 
            ? Map<String, dynamic>.from(booking['clients'] as Map) 
            : null;
        final service = booking['master_services_new'] != null 
            ? Map<String, dynamic>.from(booking['master_services_new'] as Map) 
            : null;
        final master = booking['masters'] != null 
            ? Map<String, dynamic>.from(booking['masters'] as Map) 
            : null;
        final masterProfile = master?['user_profiles'] != null 
            ? Map<String, dynamic>.from(master!['user_profiles'] as Map) 
            : null;

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
          price: (booking['final_price'] as num?)?.toDouble() ?? 
                 (booking['total_price'] as num?)?.toDouble() ?? 0.0,
          notes: booking['client_notes'],
          masterNotes: booking['master_notes'],
          masterName: masterProfile?['full_name'] ?? 'Мастер',
        );
      }).toList();

      state = state.copyWith(
        appointments: appointments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка загрузки истории: $e',
      );
    }
  }

  /// Установить фильтр по датам
  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      filterStartDate: startDate,
      filterEndDate: endDate,
    );
  }

  /// Установить фильтр по статусу
  void setStatusFilter(AppointmentStatus? status) {
    state = state.copyWith(filterStatus: status);
  }

  /// Очистить все фильтры
  void clearFilters() {
    state = state.copyWith(
      filterStartDate: null,
      filterEndDate: null,
      filterStatus: null,
    );
  }

  /// Обновить историю записей
  Future<void> refresh(String userId) async {
    await loadClientHistory(userId);
  }
}

// Провайдер истории записей клиента
final clientHistoryProvider = StateNotifierProvider<ClientHistoryNotifier, ClientHistoryState>((ref) {
  final bookingService = BookingService();
  return ClientHistoryNotifier(bookingService);
});

// Провайдер для автоматической загрузки истории при изменении пользователя
final autoLoadClientHistoryProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  final historyNotifier = ref.read(clientHistoryProvider.notifier);
  
  if (user != null) {
    // Загружаем историю при изменении пользователя
    WidgetsBinding.instance.addPostFrameCallback((_) {
      historyNotifier.loadClientHistory(user.id);
    });
  }
});
