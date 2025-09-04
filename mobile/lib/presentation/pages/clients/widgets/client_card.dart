import 'package:flutter/material.dart';

import '../../../../data/models/client.dart';
import '../../../theme/app_theme.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getAvatarColor(),
                    backgroundImage: client.avatarUrl != null 
                        ? NetworkImage(client.avatarUrl!)
                        : null,
                    child: client.avatarUrl == null
                        ? Text(
                            client.initials,
                            style: AppTheme.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Client Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                client.fullName,
                                style: AppTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.displayPhone,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (client.lastVisit != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Последний визит: ${_formatDate(client.lastVisit!)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Loyalty Level Badge
                  _buildLoyaltyBadge(),
                ],
              ),
              const SizedBox(height: 12),
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      Icons.event,
                      '${client.totalVisits}',
                      'визитов',
                      Colors.blue,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildStatItem(
                      Icons.attach_money,
                      _formatPrice(client.totalSpent),
                      'потрачено',
                      Colors.green,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildStatItem(
                      Icons.stars,
                      '${client.loyaltyPoints}',
                      'баллов',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Preferred Services
              if (client.preferredServices.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Предпочитаемые услуги:',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: client.preferredServices.take(3).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        service,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (client.preferredServices.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${client.preferredServices.length - 3} еще',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Позвонить'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text('Сообщение'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    switch (client.status) {
      case ClientStatus.active:
        color = Colors.green;
        break;
      case ClientStatus.inactive:
        color = Colors.orange;
        break;
      case ClientStatus.blocked:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        client.status.displayName,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoyaltyBadge() {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        client.loyaltyLevel,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor() {
    // Generate color based on client name
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Сегодня';
    } else if (difference == 1) {
      return 'Вчера';
    } else if (difference < 7) {
      return '$difference дн. назад';
    } else if (difference < 30) {
      return '${(difference / 7).floor()} нед. назад';
    } else {
      return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
  }

  String _formatPrice(double price) {
    return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
  }
}
