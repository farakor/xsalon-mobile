import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/client.dart';
import '../../data/models/appointment.dart';
import '../../data/models/user_profile.dart';
import 'auth_provider.dart';

// Состояние профиля клиента
enum ClientProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

// Модель состояния профиля клиента
class ClientProfileState {
  final ClientProfileStatus status;
  final Client? client;
  final List<Appointment> appointments;
  final String? errorMessage;

  const ClientProfileState({
    this.status = ClientProfileStatus.initial,
    this.client,
    this.appointments = const [],
    this.errorMessage,
  });

  ClientProfileState copyWith({
    ClientProfileStatus? status,
    Client? client,
    List<Appointment>? appointments,
    String? errorMessage,
  }) {
    return ClientProfileState(
      status: status ?? this.status,
      client: client ?? this.client,
      appointments: appointments ?? this.appointments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Провайдер для управления профилем клиента
class ClientProfileNotifier extends StateNotifier<ClientProfileState> {
  ClientProfileNotifier(this._supabase) : super(const ClientProfileState());

  final SupabaseClient _supabase;

  // Загрузка профиля клиента по user_profile_id
  Future<void> loadClientProfile(String userProfileId) async {
    state = state.copyWith(status: ClientProfileStatus.loading);

    try {
      // Получаем данные клиента
      final clientResponse = await _supabase
          .from('clients')
          .select('*')
          .eq('user_profile_id', userProfileId)
          .maybeSingle();

      if (clientResponse == null) {
        // Создаем профиль клиента, если его нет
        await _createClientProfile(userProfileId);
        return;
      }

      final client = Client.fromJson(clientResponse);

      // Получаем историю записей клиента
      final appointmentsResponse = await _supabase
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
            master_services_new!inner(name)
          ''')
          .eq('client_id', client.id)
          .order('start_time', ascending: false);

      final appointments = appointmentsResponse
          .map<Appointment>((json) => _convertBookingToAppointment(json))
          .toList();

      state = state.copyWith(
        status: ClientProfileStatus.loaded,
        client: client,
        appointments: appointments,
        errorMessage: null,
      );
    } catch (error) {
      print('Ошибка загрузки профиля клиента: $error');
      state = state.copyWith(
        status: ClientProfileStatus.error,
        errorMessage: 'Ошибка загрузки профиля: $error',
      );
    }
  }

  // Создание профиля клиента
  Future<void> _createClientProfile(String userProfileId) async {
    try {
      // Получаем данные пользователя
      final userResponse = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', userProfileId)
          .single();

      final userProfile = UserProfile.fromJson(userResponse);

      // Создаем профиль клиента
      final clientData = {
        'user_profile_id': userProfileId,
        'full_name': userProfile.fullName ?? 'Клиент',
        'phone': userProfile.phone,
        'email': userProfile.email,
        'status': 'active',
        'total_visits': 0,
        'total_spent': 0.0,
        'loyalty_points': 0,
        'loyalty_level': 'Новичок',
        'preferred_services': <String>[],
      };

      final response = await _supabase
          .from('clients')
          .insert(clientData)
          .select()
          .single();

      final client = Client.fromJson(response);

      state = state.copyWith(
        status: ClientProfileStatus.loaded,
        client: client,
        appointments: [],
        errorMessage: null,
      );
    } catch (error) {
      print('Ошибка создания профиля клиента: $error');
      state = state.copyWith(
        status: ClientProfileStatus.error,
        errorMessage: 'Ошибка создания профиля: $error',
      );
    }
  }

  // Обновление профиля клиента
  Future<void> updateClientProfile(Client updatedClient) async {
    try {
      final response = await _supabase
          .from('clients')
          .update(updatedClient.toJson())
          .eq('id', updatedClient.id)
          .select()
          .single();

      final client = Client.fromJson(response);

      state = state.copyWith(
        client: client,
        errorMessage: null,
      );
    } catch (error) {
      print('Ошибка обновления профиля клиента: $error');
      state = state.copyWith(
        status: ClientProfileStatus.error,
        errorMessage: 'Ошибка обновления профиля: $error',
      );
      rethrow;
    }
  }

  // Обновление профиля пользователя
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      await _supabase
          .from('user_profiles')
          .update(updatedProfile.toJson())
          .eq('id', updatedProfile.id);

      // Обновляем также данные в таблице clients, если они связаны
      if (state.client != null) {
        final updatedClient = state.client!.copyWith(
          fullName: updatedProfile.fullName ?? state.client!.fullName,
          phone: updatedProfile.phone ?? state.client!.phone,
          email: updatedProfile.email ?? state.client!.email,
        );

        await updateClientProfile(updatedClient);
      }
    } catch (error) {
      print('Ошибка обновления профиля пользователя: $error');
      state = state.copyWith(
        status: ClientProfileStatus.error,
        errorMessage: 'Ошибка обновления профиля: $error',
      );
      rethrow;
    }
  }

  // Получение статистики клиента
  Map<String, dynamic> getClientStats() {
    if (state.client == null) return {};

    final client = state.client!;
    final confirmedAppointments = state.appointments
        .where((appointment) => appointment.status == AppointmentStatus.confirmed)
        .toList();

    final totalSpent = confirmedAppointments
        .fold<double>(0, (sum, appointment) => sum + appointment.price);

    final lastVisit = confirmedAppointments.isNotEmpty
        ? confirmedAppointments.first.startTime
        : null;

    return {
      'totalVisits': client.totalVisits,
      'totalSpent': totalSpent,
      'loyaltyPoints': client.loyaltyPoints,
      'loyaltyLevel': client.loyaltyLevel,
      'lastVisit': lastVisit,
      'upcomingAppointments': state.appointments
          .where((appointment) => 
              appointment.startTime.isAfter(DateTime.now()) &&
              appointment.status != AppointmentStatus.cancelled)
          .length,
    };
  }

  // Преобразование данных из bookings в Appointment
  Appointment _convertBookingToAppointment(Map<String, dynamic> booking) {
    final clientData = booking['clients'] as Map<String, dynamic>;
    final serviceData = booking['master_services_new'] as Map<String, dynamic>;
    
    return Appointment(
      id: booking['id'] as String,
      clientId: booking['client_id'] as String,
      clientName: clientData['full_name'] as String,
      clientPhone: clientData['phone'] as String,
      serviceId: booking['service_id'] as String,
      serviceName: serviceData['name'] as String,
      startTime: DateTime.parse(booking['start_time'] as String),
      endTime: DateTime.parse(booking['end_time'] as String),
      status: _convertBookingStatus(booking['status'] as String),
      price: (booking['final_price'] ?? booking['total_price'] ?? 0).toDouble(),
      notes: booking['client_notes'] as String?,
      masterNotes: booking['master_notes'] as String?,
    );
  }

  // Преобразование статуса из bookings в AppointmentStatus
  AppointmentStatus _convertBookingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  // Очистка ошибок
  void clearError() {
    state = state.copyWith(
      status: ClientProfileStatus.loaded,
      errorMessage: null,
    );
  }
}

// Провайдер состояния профиля клиента
final clientProfileProvider = StateNotifierProvider<ClientProfileNotifier, ClientProfileState>((ref) {
  final supabase = Supabase.instance.client;
  return ClientProfileNotifier(supabase);
});

// Провайдер для автоматической загрузки профиля текущего пользователя
final currentClientProfileProvider = Provider<ClientProfileState>((ref) {
  final authState = ref.watch(authProvider);
  final clientProfileState = ref.watch(clientProfileProvider);

  // Автоматически загружаем профиль при изменении пользователя
  if (authState.user != null && 
      authState.profile != null && 
      authState.profile!.isClient &&
      clientProfileState.status == ClientProfileStatus.initial) {
    
    // Загружаем профиль клиента
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientProfileProvider.notifier).loadClientProfile(authState.user!.id);
    });
  }

  return clientProfileState;
});

// Провайдер для получения текущего клиента
final currentClientProvider = Provider<Client?>((ref) {
  final clientProfileState = ref.watch(currentClientProfileProvider);
  return clientProfileState.client;
});

// Провайдер для получения статистики клиента
final clientStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final clientProfileNotifier = ref.watch(clientProfileProvider.notifier);
  return clientProfileNotifier.getClientStats();
});
