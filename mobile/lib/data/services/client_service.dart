import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/client.dart';

class ClientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Метод больше не нужен - убрана логика мультиорганизационности

  /// Получить всех клиентов
  Future<List<Client>> getClients() async {
    try {
      // Получаем всех клиентов (без фильтрации по организации)
      final response = await _supabase
          .from('clients')
          .select('*')
          .order('created_at', ascending: false);

      return response.map<Client>((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки клиентов: $e');
    }
  }

  /// Создать нового клиента
  Future<Client> createClient(Client client) async {
    try {
      // Проверяем уникальность телефона
      if (client.phone != null) {
        final existingClient = await _supabase
            .from('clients')
            .select('id')
            .eq('phone', client.phone!)
            .maybeSingle();

        if (existingClient != null) {
          throw Exception('Клиент с таким номером телефона уже существует');
        }
      }

      // Создаем клиента
      final clientData = client.toJson();
      clientData.remove('id'); // Удаляем ID, чтобы база сгенерировала новый

      final response = await _supabase
          .from('clients')
          .insert(clientData)
          .select()
          .single();

      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка создания клиента: $e');
    }
  }

  /// Обновить клиента
  Future<Client> updateClient(Client client) async {
    try {
      final response = await _supabase
          .from('clients')
          .update(client.toJson())
          .eq('id', client.id)
          .select()
          .single();

      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка обновления клиента: $e');
    }
  }

  /// Удалить клиента
  Future<void> deleteClient(String clientId) async {
    try {
      await _supabase
          .from('clients')
          .delete()
          .eq('id', clientId);
    } catch (e) {
      throw Exception('Ошибка удаления клиента: $e');
    }
  }

  /// Получить клиента по ID
  Future<Client?> getClientById(String clientId) async {
    try {
      final response = await _supabase
          .from('clients')
          .select('*')
          .eq('id', clientId)
          .maybeSingle();

      if (response == null) return null;
      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка получения клиента: $e');
    }
  }

  /// Поиск клиентов по запросу
  Future<List<Client>> searchClients(String query) async {
    try {
      // Поиск клиентов

      // Поиск по имени, телефону или email
      final response = await _supabase
          .from('clients')
          .select('*')
          .or('full_name.ilike.%$query%,phone.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map<Client>((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка поиска клиентов: $e');
    }
  }

  /// Обновить статистику клиента после визита
  Future<void> updateClientStats(String clientId, double spentAmount) async {
    try {
      // Получаем текущие данные клиента
      final client = await getClientById(clientId);
      if (client == null) throw Exception('Клиент не найден');

      // Обновляем статистику
      await _supabase
          .from('clients')
          .update({
            'total_visits': client.totalVisits + 1,
            'total_spent': client.totalSpent + spentAmount,
            'last_visit': DateTime.now().toIso8601String(),
          })
          .eq('id', clientId);
    } catch (e) {
      throw Exception('Ошибка обновления статистики клиента: $e');
    }
  }

  /// Получить топ клиентов по тратам
  Future<List<Client>> getTopClientsBySpending({int limit = 10}) async {
    try {
      // Поиск клиентов

      final response = await _supabase
          .from('clients')
          .select('*')
          .order('total_spent', ascending: false)
          .limit(limit);

      return response.map<Client>((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка получения топ клиентов: $e');
    }
  }

  /// Получить клиентов по уровню лояльности
  Future<List<Client>> getClientsByLoyaltyLevel(String loyaltyLevel) async {
    try {
      // Поиск клиентов

      final response = await _supabase
          .from('clients')
          .select('*')
          .eq('loyalty_level', loyaltyLevel)
          .order('total_spent', ascending: false);

      return response.map<Client>((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка получения клиентов по уровню лояльности: $e');
    }
  }
}
