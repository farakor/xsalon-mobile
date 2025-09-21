import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../data/models/client.dart';
import '../../../theme/app_theme.dart';
import '../client_detail_page.dart';

class ClientSearchDelegate extends SearchDelegate<Client?> {
  final List<Client> clients;

  ClientSearchDelegate(this.clients);

  @override
  String get searchFieldLabel => 'Поиск клиентов...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(LucideIcons.arrowLeft),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _getSearchResults();
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.searchX,
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
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final client = results[index];
        return _buildClientSearchResult(context, client);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Поиск клиентов',
              style: AppTheme.titleLarge.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Введите имя, телефон или email клиента',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final suggestions = _getSearchResults().take(5).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final client = suggestions[index];
        return _buildClientSuggestion(context, client);
      },
    );
  }

  Widget _buildClientSearchResult(BuildContext context, Client client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAvatarColor(client),
          backgroundImage: client.avatarUrl != null 
              ? NetworkImage(client.avatarUrl!)
              : null,
          child: client.avatarUrl == null
              ? Text(
                  client.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          client.fullName,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.displayPhone),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(LucideIcons.calendar, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${client.totalVisits} визитов',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(LucideIcons.dollarSign, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatPrice(client.totalSpent),
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildLoyaltyBadge(client),
        onTap: () {
          close(context, client);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientDetailPage(client: client),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientSuggestion(BuildContext context, Client client) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: _getAvatarColor(client),
        backgroundImage: client.avatarUrl != null 
            ? NetworkImage(client.avatarUrl!)
            : null,
        child: client.avatarUrl == null
            ? Text(
                client.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )
            : null,
      ),
      title: RichText(
        text: TextSpan(
          style: AppTheme.titleMedium,
          children: _highlightMatches(client.fullName, query),
        ),
      ),
      subtitle: Text(
        client.displayPhone,
        style: AppTheme.bodySmall.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Text(
        client.loyaltyLevel,
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        query = client.fullName;
        showResults(context);
      },
    );
  }

  Widget _buildLoyaltyBadge(Client client) {
    Color color;
    switch (client.loyaltyLevel) {
      case 'VIP':
        color = Colors.purple;
        break;
      case 'Золотой':
        color = Colors.amber;
        break;
      case 'Серебряный':
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        client.loyaltyLevel,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  List<Client> _getSearchResults() {
    if (query.isEmpty) return [];

    final searchQuery = query.toLowerCase();
    return clients.where((client) {
      return client.fullName.toLowerCase().contains(searchQuery) ||
             (client.phone?.toLowerCase().contains(searchQuery) ?? false) ||
             (client.email?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  List<TextSpan> _highlightMatches(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    
    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));
      
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    
    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    
    return spans;
  }

  Color _getAvatarColor(Client client) {
    final hash = client.fullName.hashCode;
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];
    return colors[hash.abs() % colors.length];
  }

  String _formatPrice(double price) {
    return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
  }
}
