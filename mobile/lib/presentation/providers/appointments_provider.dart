import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/appointment.dart';
import '../../data/services/booking_service.dart';
import '../../core/errors/failures.dart';

// Состояние для записей
class AppointmentsState {
  final List<Appointment> appointments;
  final bool isLoading;
  final String? errorMessage;
  final DateTime selectedDate;

  const AppointmentsState({
    this.appointments = const [],
    this.isLoading = false,
    this.errorMessage,
    required this.selectedDate,
  });

  AppointmentsState copyWith({
    List<Appointment>? appointments,
    bool? isLoading,
    String? errorMessage,
    DateTime? selectedDate,
  }) {
    return AppointmentsState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

// Провайдер для BookingService
final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

// Провайдер для управления записями
final appointmentsProvider = StateNotifierProvider<AppointmentsNotifier, AppointmentsState>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  return AppointmentsNotifier(bookingService);
});

class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  AppointmentsNotifier(this._bookingService) : super(AppointmentsState(selectedDate: DateTime.now()));

  final BookingService _bookingService;

  /// Загрузить записи мастера на выбранную дату
  Future<void> loadAppointmentsForDate(DateTime date) async {
    state = state.copyWith(isLoading: true, errorMessage: null, selectedDate: date);

    try {
      final masterId = await _bookingService.getCurrentMasterId();
      final bookingsData = await _bookingService.getMasterBookingsForDate(
        masterId: masterId,
        date: date,
      );

      // Преобразуем данные из базы в модель Appointment
      final appointments = bookingsData.map((booking) {
        final client = booking['clients'] as Map<String, dynamic>?;
        final service = booking['master_services_new'] as Map<String, dynamic>?;
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

      state = state.copyWith(
        appointments: appointments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ServerFailure ? e.message : 'Ошибка загрузки записей: $e',
      );
    }
  }

  /// Загрузить записи мастера на диапазон дат (для недельного и месячного вида)
  Future<void> loadAppointmentsForDateRange(DateTime startDate, DateTime endDate) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final masterId = await _bookingService.getCurrentMasterId();
      final allAppointments = <Appointment>[];

      // Используем новый метод для загрузки записей за диапазон дат
      final bookingsData = await _bookingService.getMasterBookingsForDateRange(
        masterId: masterId,
        startDate: startDate,
        endDate: endDate,
      );

      final appointments = bookingsData.map((booking) {
        final client = booking['clients'] as Map<String, dynamic>?;
        final service = booking['master_services_new'] as Map<String, dynamic>?;
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

      allAppointments.addAll(appointments);

      state = state.copyWith(
        appointments: allAppointments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ServerFailure ? e.message : 'Ошибка загрузки записей: $e',
      );
    }
  }

  /// Обновить статус записи
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus newStatus) async {
    try {
      // Обновляем статус в базе данных
      await _bookingService.updateBookingStatus(
        bookingId: appointmentId,
        newStatus: newStatus.name,
      );

      // Обновляем локальное состояние
      final updatedAppointments = state.appointments.map((appointment) {
        if (appointment.id == appointmentId) {
          return appointment.copyWith(status: newStatus);
        }
        return appointment;
      }).toList();

      state = state.copyWith(appointments: updatedAppointments);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ServerFailure ? e.message : 'Ошибка обновления статуса записи: $e',
      );
    }
  }

  /// Получить записи для конкретной даты
  List<Appointment> getAppointmentsForDate(DateTime date) {
    return state.appointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.startTime.year,
        appointment.startTime.month,
        appointment.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return appointmentDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Обновить заметки мастера для записи
  Future<void> updateAppointmentNotes(String appointmentId, String notes) async {
    try {
      // Обновляем заметки в базе данных
      await _bookingService.updateBookingNotes(
        bookingId: appointmentId,
        notes: notes,
      );

      // Обновляем локальное состояние
      final updatedAppointments = state.appointments.map((appointment) {
        if (appointment.id == appointmentId) {
          return appointment.copyWith(masterNotes: notes);
        }
        return appointment;
      }).toList();

      state = state.copyWith(appointments: updatedAppointments);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ServerFailure ? e.message : 'Ошибка обновления заметок: $e',
      );
    }
  }

  /// Очистить ошибку
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
