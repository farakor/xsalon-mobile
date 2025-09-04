import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/client.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/clients_provider.dart';

class ClientSelector extends ConsumerStatefulWidget {
  final Client? selectedClient;
  final Function(Client) onClientSelected;

  const ClientSelector({
    super.key,
    this.selectedClient,
    required this.onClientSelected,
  });

  @override
  ConsumerState<ClientSelector> createState() => _ClientSelectorState();
}

class _ClientSelectorState extends ConsumerState<ClientSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Client> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterClients);
    // Загружаем клиентов при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientsProvider.notifier).loadClients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    final allClients = ref.read(clientsListProvider);
    setState(() {
      _filteredClients = allClients.where((client) {
        return client.fullName.toLowerCase().contains(query) ||
               (client.phone?.toLowerCase().contains(query) ?? false) ||
               (client.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientsState = ref.watch(clientsProvider);
    final isLoading = ref.watch(isClientsLoadingProvider);
    final error = ref.watch(clientsErrorProvider);
    final allClients = ref.watch(clientsListProvider);

    // Если данные еще не были загружены и фильтрованный список пуст, заполняем его
    if (_filteredClients.isEmpty && allClients.isNotEmpty) {
      _filteredClients = allClients;
    }

    return Column(
      children: [
        // Search Field
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Поиск клиента',
            hintText: 'Введите имя, телефон или email',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        
        // Selected Client (if any)
        if (widget.selectedClient != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Выбран: ${widget.selectedClient!.fullName}',
                        style: AppTheme.titleSmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.selectedClient!.displayPhone,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onClientSelected(widget.selectedClient!),
                  child: const Text('Изменить'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Loading state
        if (isLoading)
          Container(
            height: 300,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          )
        // Error state
        else if (error != null)
          Container(
            height: 300,
            child: _buildErrorState(error),
          )
        // Clients List
        else
          Container(
            height: 400,
            child: _filteredClients.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = _filteredClients[index];
                      final isSelected = widget.selectedClient?.id == client.id;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: isSelected ? 4 : 1,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getAvatarColor(client),
                            child: Text(
                              client.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            client.fullName,
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.primaryColor : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(client.displayPhone),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.event, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${client.totalVisits} визитов',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.star, size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    client.loyaltyLevel,
                                    style: AppTheme.bodySmall.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                              : const Icon(Icons.chevron_right),
                          selected: isSelected,
                          selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                          onTap: () => widget.onClientSelected(client),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
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
            'Попробуйте изменить поисковый запрос',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
          Text(
            error,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(clientsProvider.notifier).loadClients();
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(Client client) {
    final hash = client.fullName.hashCode;
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    ];
    return colors[hash.abs() % colors.length];
  }
}
