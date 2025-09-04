import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/client.dart';
import '../../theme/app_theme.dart';
import '../../providers/clients_provider.dart';
import 'widgets/client_card.dart';
import 'widgets/client_search_delegate.dart';
import 'client_detail_page.dart';
import 'add_client_page.dart';

enum ClientSortType { name, lastVisit, totalSpent, totalVisits }
enum ClientFilterType { all, active, inactive, vip }

class StaffClientsPage extends ConsumerStatefulWidget {
  const StaffClientsPage({super.key});

  @override
  ConsumerState<StaffClientsPage> createState() => _StaffClientsPageState();
}

class _StaffClientsPageState extends ConsumerState<StaffClientsPage> {
  ClientSortType _sortType = ClientSortType.name;
  ClientFilterType _filterType = ClientFilterType.all;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    // Загружаем клиентов при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientsProvider.notifier).loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientsState = ref.watch(clientsProvider);
    final isLoading = ref.watch(isClientsLoadingProvider);
    final error = ref.watch(clientsErrorProvider);
    
    // Если есть ошибка, показываем её
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Клиенты')),
        body: _buildErrorState(error),
      );
    }
    
    // Если загружается, показываем индикатор
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Клиенты')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final filteredClients = _getFilteredAndSortedClients(clientsState.clients);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Клиенты'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
            tooltip: 'Поиск клиентов',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_client') {
                _addClient();
              } else if (value == 'export') {
                _exportClients();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_client',
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Добавить клиента'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Экспорт списка'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats and Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Stats
                _buildStatsRow(filteredClients),
                const SizedBox(height: 16),
                // Filters and Sort
                Row(
                  children: [
                    Expanded(child: _buildFilterChips()),
                    const SizedBox(width: 16),
                    _buildSortButton(),
                  ],
                ),
              ],
            ),
          ),
          // Clients List
          Expanded(
            child: filteredClients.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = filteredClients[index];
                      return ClientCard(
                        client: client,
                        onTap: () => _openClientDetail(client),
                        onCall: () => _callClient(client),
                        onMessage: () => _messageClient(client),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClient,
        child: const Icon(Icons.person_add),
        tooltip: 'Добавить клиента',
      ),
    );
  }

  Widget _buildStatsRow(List<Client> clients) {
    final activeClients = clients.where((c) => c.status == ClientStatus.active).length;
    final totalRevenue = clients.fold<double>(0, (sum, client) => sum + client.totalSpent);
    final avgSpent = clients.isNotEmpty ? totalRevenue / clients.length : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Всего клиентов',
            '${clients.length}',
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Активных',
            '$activeClients',
            Icons.person,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Средний чек',
            _formatPrice(avgSpent),
            Icons.attach_money,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ClientFilterType.values.map((filter) {
          final isSelected = _filterType == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterType = filter;
                });
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<ClientSortType>(
      onSelected: (sortType) {
        setState(() {
          if (_sortType == sortType) {
            _sortAscending = !_sortAscending;
          } else {
            _sortType = sortType;
            _sortAscending = true;
          }
        });
      },
      itemBuilder: (context) => ClientSortType.values.map((sortType) {
        return PopupMenuItem(
          value: sortType,
          child: Row(
            children: [
              Text(_getSortLabel(sortType)),
              const Spacer(),
              if (_sortType == sortType)
                Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 18),
            const SizedBox(width: 4),
            Text(
              _getSortLabel(_sortType),
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Клиенты не найдены',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить фильтры или добавить нового клиента',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addClient,
            icon: const Icon(Icons.person_add),
            label: const Text('Добавить клиента'),
          ),
        ],
      ),
    );
  }

  List<Client> _getFilteredAndSortedClients(List<Client> allClients) {
    var clients = List<Client>.from(allClients);

    // Apply filter
    switch (_filterType) {
      case ClientFilterType.active:
        clients = clients.where((c) => c.status == ClientStatus.active).toList();
        break;
      case ClientFilterType.inactive:
        clients = clients.where((c) => c.status == ClientStatus.inactive).toList();
        break;
      case ClientFilterType.vip:
        clients = clients.where((c) => c.loyaltyLevel == 'VIP').toList();
        break;
      case ClientFilterType.all:
        break;
    }

    // Apply sort
    clients.sort((a, b) {
      int comparison;
      switch (_sortType) {
        case ClientSortType.name:
          comparison = a.fullName.compareTo(b.fullName);
          break;
        case ClientSortType.lastVisit:
          final aDate = a.lastVisit ?? DateTime(1900);
          final bDate = b.lastVisit ?? DateTime(1900);
          comparison = aDate.compareTo(bDate);
          break;
        case ClientSortType.totalSpent:
          comparison = a.totalSpent.compareTo(b.totalSpent);
          break;
        case ClientSortType.totalVisits:
          comparison = a.totalVisits.compareTo(b.totalVisits);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return clients;
  }

  String _getFilterLabel(ClientFilterType filter) {
    switch (filter) {
      case ClientFilterType.all:
        return 'Все';
      case ClientFilterType.active:
        return 'Активные';
      case ClientFilterType.inactive:
        return 'Неактивные';
      case ClientFilterType.vip:
        return 'VIP';
    }
  }

  String _getSortLabel(ClientSortType sort) {
    switch (sort) {
      case ClientSortType.name:
        return 'По имени';
      case ClientSortType.lastVisit:
        return 'По дате визита';
      case ClientSortType.totalSpent:
        return 'По сумме';
      case ClientSortType.totalVisits:
        return 'По визитам';
    }
  }

  void _showSearch() {
    final clients = ref.read(clientsListProvider);
    showSearch(
      context: context,
      delegate: ClientSearchDelegate(clients),
    );
  }

  void _openClientDetail(Client client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailPage(client: client),
      ),
    );
  }

  void _callClient(Client client) {
    // TODO: Implement phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Звонок ${client.displayPhone}')),
    );
  }

  void _messageClient(Client client) {
    // TODO: Implement messaging
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Сообщение для ${client.fullName}')),
    );
  }

  void _addClient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddClientPage(),
      ),
    ).then((result) {
      if (result != null && result is Client) {
        // Добавляем нового клиента через провайдер
        ref.read(clientsProvider.notifier).addClient(result).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Клиент ${result.fullName} успешно добавлен!'),
              backgroundColor: Colors.green,
            ),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка добавления клиента: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    });
  }

  void _exportClients() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Экспорт списка - в разработке')),
    );
  }

  String _formatPrice(double price) {
    return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки клиентов',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(clientsProvider.notifier).clearError();
              ref.read(clientsProvider.notifier).loadClients();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
