import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/booking_service.dart';

enum BookingStatus {
  initial,
  loading,
  success,
  error,
}

class BookingState {
  final BookingStatus status;
  final String? bookingId;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.initial,
    this.bookingId,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status,
    String? bookingId,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier(this._bookingService) : super(const BookingState());

  final BookingService _bookingService;

  /// Создать новую запись
  Future<bool> createBooking({
    required String clientId,
    required List<String> serviceIds, // Поддержка множественных услуг
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    String? clientNotes,
    String? masterId, // Опциональный ID мастера (для клиентов)
  }) async {
    state = state.copyWith(status: BookingStatus.loading);

    try {
      print('BookingProvider: Creating booking...');
      
      // Получаем ID мастера
      final finalMasterId = masterId ?? await _bookingService.getCurrentMasterId();
      
      print('BookingProvider: Master ID: $finalMasterId');

      // Проверяем доступность времени
      print('BookingProvider: Checking time slot availability...');
      final isAvailable = await _bookingService.isTimeSlotAvailable(
        masterId: finalMasterId,
        startTime: startTime,
        endTime: endTime,
      );

      print('BookingProvider: Time slot available: $isAvailable');

      if (!isAvailable) {
        print('BookingProvider: Time slot is occupied, blocking booking creation');
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: 'Выбранное время уже занято. Пожалуйста, выберите другое время.',
        );
        return false;
      }

      // Пока создаем запись с первой услугой
      // TODO: В будущем нужно будет создать связанную таблицу booking_services для множественных услуг
      final serviceId = serviceIds.isNotEmpty ? serviceIds.first : '';
      
      final bookingId = await _bookingService.createBooking(
        clientId: clientId,
        masterId: finalMasterId,
        serviceId: serviceId,
        startTime: startTime,
        endTime: endTime,
        totalPrice: totalPrice,
        finalPrice: totalPrice, // Пока без скидок
        clientNotes: clientNotes,
      );

      state = state.copyWith(
        status: BookingStatus.success,
        bookingId: bookingId,
        errorMessage: null,
      );

      print('BookingProvider: Booking created successfully: $bookingId');
      return true;
    } catch (error) {
      print('BookingProvider: Error creating booking: $error');
      state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  /// Сбросить состояние
  void reset() {
    state = const BookingState();
  }
}

// Провайдеры
final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  return BookingNotifier(bookingService);
});

// Вспомогательные провайдеры
final isBookingLoadingProvider = Provider<bool>((ref) {
  final bookingState = ref.watch(bookingProvider);
  return bookingState.status == BookingStatus.loading;
});

final bookingErrorProvider = Provider<String?>((ref) {
  final bookingState = ref.watch(bookingProvider);
  return bookingState.errorMessage;
});
