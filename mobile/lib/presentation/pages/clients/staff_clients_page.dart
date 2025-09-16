import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/client.dart';
import '../../theme/app_theme.dart';
import '../../providers/clients_provider.dart';
import '../../widgets/modern_app_header.dart';
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
      appBar: ModernAppHeader(
        title: 'Клиенты',
        subtitle: 'База данных клиентов салона',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.search,
                  color: AppTheme.textSecondaryColor,
                  size: 18,
                ),
              ),
              onPressed: _showSearch,
              tooltip: 'Поиск клиентов',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.more_vert,
                  color: AppTheme.textSecondaryColor,
                  size: 18,
                ),
              ),
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
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Поиск клиентов...',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.textSecondaryColor,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onTap: _showSearch,
                    readOnly: true,
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                Row(
                  children: [
                    Expanded(child: _buildFilterChips()),
                    const SizedBox(width: 12),
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
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
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _addClient,
            borderRadius: BorderRadius.circular(16),
            child: const Icon(
              Icons.person_add,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
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
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filterType = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  _getFilterLabel(filter),
                  style: AppTheme.bodyMedium.copyWith(
                    color: isSelected 
                        ? Colors.white 
                        : AppTheme.textSecondaryColor,
                    fontWeight: isSelected 
                        ? FontWeight.w500 
                        : FontWeight.normal,
                  ),
                ),
              ),
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
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.tune,
          size: 20,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.people_outline,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Клиенты не найдены',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить фильтры или добавить нового клиента',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: _addClient,
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: Text(
                  'Добавить клиента',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
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
