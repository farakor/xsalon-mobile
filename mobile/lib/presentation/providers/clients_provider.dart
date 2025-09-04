import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/client.dart';
import '../../data/services/client_service.dart';

// Состояние загрузки клиентов
enum ClientsStatus {
  initial,
  loading,
  loaded,
  error,
}

// Модель состояния клиентов
class ClientsState {
  final ClientsStatus status;
  final List<Client> clients;
  final String? errorMessage;

  const ClientsState({
    this.status = ClientsStatus.initial,
    this.clients = const [],
    this.errorMessage,
  });

  ClientsState copyWith({
    ClientsStatus? status,
    List<Client>? clients,
    String? errorMessage,
  }) {
    return ClientsState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Провайдер для управления клиентами
class ClientsNotifier extends StateNotifier<ClientsState> {
  ClientsNotifier(this._clientService) : super(const ClientsState());

  final ClientService _clientService;

  // Загрузка всех клиентов
  Future<void> loadClients() async {
    state = state.copyWith(status: ClientsStatus.loading);

    try {
      final clients = await _clientService.getClients();
      state = state.copyWith(
        status: ClientsStatus.loaded,
        clients: clients,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: ClientsStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Добавление нового клиента
  Future<void> addClient(Client client) async {
    try {
      final newClient = await _clientService.createClient(client);
      final updatedClients = [...state.clients, newClient];
      state = state.copyWith(clients: updatedClients);
    } catch (error) {
      state = state.copyWith(
        status: ClientsStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // Обновление клиента
  Future<void> updateClient(Client client) async {
    try {
      final updatedClient = await _clientService.updateClient(client);
      final updatedClients = state.clients.map((c) {
        return c.id == client.id ? updatedClient : c;
      }).toList();
      state = state.copyWith(clients: updatedClients);
    } catch (error) {
      state = state.copyWith(
        status: ClientsStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // Удаление клиента
  Future<void> deleteClient(String clientId) async {
    try {
      await _clientService.deleteClient(clientId);
      final updatedClients = state.clients.where((c) => c.id != clientId).toList();
      state = state.copyWith(clients: updatedClients);
    } catch (error) {
      state = state.copyWith(
        status: ClientsStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // Поиск клиентов
  Future<List<Client>> searchClients(String query) async {
    try {
      return await _clientService.searchClients(query);
    } catch (error) {
      state = state.copyWith(
        status: ClientsStatus.error,
        errorMessage: error.toString(),
      );
      return [];
    }
  }

  // Получение топ клиентов
  Future<List<Client>> getTopClients({int limit = 10}) async {
    try {
      return await _clientService.getTopClientsBySpending(limit: limit);
    } catch (error) {
      state = state.copyWith(
        status: ClientsStatus.error,
        errorMessage: error.toString(),
      );
      return [];
    }
  }

  // Обновление статистики клиента
  Future<void> updateClientStats(String clientId, double spentAmount) async {
    try {
      await _clientService.updateClientStats(clientId, spentAmount);
      // Перезагружаем клиентов для обновления статистики
      await loadClients();
    } catch (error) {
      state = state.copyWith(
        status: ClientsStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  // Очистка ошибок
  void clearError() {
    state = state.copyWith(
      status: ClientsStatus.loaded,
      errorMessage: null,
    );
  }
}

// Провайдер сервиса клиентов
final clientServiceProvider = Provider<ClientService>((ref) {
  return ClientService();
});

// Провайдер состояния клиентов
final clientsProvider = StateNotifierProvider<ClientsNotifier, ClientsState>((ref) {
  final clientService = ref.watch(clientServiceProvider);
  return ClientsNotifier(clientService);
});

// Провайдер для получения списка клиентов
final clientsListProvider = Provider<List<Client>>((ref) {
  final clientsState = ref.watch(clientsProvider);
  return clientsState.clients;
});

// Провайдер для проверки загрузки
final isClientsLoadingProvider = Provider<bool>((ref) {
  final clientsState = ref.watch(clientsProvider);
  return clientsState.status == ClientsStatus.loading;
});

// Провайдер для получения ошибки
final clientsErrorProvider = Provider<String?>((ref) {
  final clientsState = ref.watch(clientsProvider);
  return clientsState.errorMessage;
});

// Провайдер для получения клиента по ID
final clientByIdProvider = Provider.family<Client?, String>((ref, clientId) {
  final clients = ref.watch(clientsListProvider);
  try {
    return clients.firstWhere((client) => client.id == clientId);
  } catch (e) {
    return null;
  }
});

// Провайдер для фильтрации клиентов по статусу
final clientsByStatusProvider = Provider.family<List<Client>, ClientStatus>((ref, status) {
  final clients = ref.watch(clientsListProvider);
  return clients.where((client) => client.status == status).toList();
});

// Провайдер для получения активных клиентов
final activeClientsProvider = Provider<List<Client>>((ref) {
  final clients = ref.watch(clientsListProvider);
  return clients.where((client) => client.status == ClientStatus.active).toList();
});

// Провайдер для получения VIP клиентов
final vipClientsProvider = Provider<List<Client>>((ref) {
  final clients = ref.watch(clientsListProvider);
  return clients.where((client) => client.loyaltyLevel == 'VIP').toList();
});

// Провайдер для статистики клиентов
final clientsStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final clients = ref.watch(clientsListProvider);
  
  final totalClients = clients.length;
  final activeClients = clients.where((c) => c.status == ClientStatus.active).length;
  final totalRevenue = clients.fold<double>(0, (sum, client) => sum + client.totalSpent);
  final avgSpent = clients.isNotEmpty ? totalRevenue / clients.length : 0.0;
  final totalVisits = clients.fold<int>(0, (sum, client) => sum + client.totalVisits);
  
  return {
    'totalClients': totalClients,
    'activeClients': activeClients,
    'totalRevenue': totalRevenue,
    'avgSpent': avgSpent,
    'totalVisits': totalVisits,
  };
});
