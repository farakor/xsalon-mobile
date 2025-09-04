import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/client.dart';
import '../../../data/models/appointment.dart';
import '../../theme/app_theme.dart';
import '../booking/add_booking_page.dart';

class ClientDetailPage extends ConsumerStatefulWidget {
  final Client client;

  const ClientDetailPage({
    super.key,
    required this.client,
  });

  @override
  ConsumerState<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends ConsumerState<ClientDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Тестовые данные истории посещений
  List<Appointment> get _mockHistory => [
    Appointment(
      id: '1',
      clientId: widget.client.id,
      clientName: widget.client.fullName,
      clientPhone: widget.client.displayPhone,
      serviceId: 'service1',
      serviceName: 'Женская стрижка',
      startTime: DateTime.now().subtract(const Duration(days: 7)),
      endTime: DateTime.now().subtract(const Duration(days: 7, hours: -1, minutes: -30)),
      status: AppointmentStatus.completed,
      price: 150000,
      notes: 'Клиент доволен результатом',
    ),
    Appointment(
      id: '2',
      clientId: widget.client.id,
      clientName: widget.client.fullName,
      clientPhone: widget.client.displayPhone,
      serviceId: 'service2',
      serviceName: 'Окрашивание волос',
      startTime: DateTime.now().subtract(const Duration(days: 21)),
      endTime: DateTime.now().subtract(const Duration(days: 21, hours: -2, minutes: -30)),
      status: AppointmentStatus.completed,
      price: 300000,
    ),
    Appointment(
      id: '3',
      clientId: widget.client.id,
      clientName: widget.client.fullName,
      clientPhone: widget.client.displayPhone,
      serviceId: 'service3',
      serviceName: 'Укладка',
      startTime: DateTime.now().subtract(const Duration(days: 35)),
      endTime: DateTime.now().subtract(const Duration(days: 35, hours: -1)),
      status: AppointmentStatus.completed,
      price: 80000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.fullName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editClient,
            tooltip: 'Редактировать',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'call':
                  _callClient();
                  break;
                case 'message':
                  _messageClient();
                  break;
                case 'block':
                  _blockClient();
                  break;
                case 'delete':
                  _deleteClient();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'call',
                child: Row(
                  children: [
                    Icon(Icons.phone),
                    SizedBox(width: 8),
                    Text('Позвонить'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'message',
                child: Row(
                  children: [
                    Icon(Icons.message),
                    SizedBox(width: 8),
                    Text('Сообщение'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Заблокировать'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Удалить'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Профиль', icon: Icon(Icons.person)),
            Tab(text: 'История', icon: Icon(Icons.history)),
            Tab(text: 'Заметки', icon: Icon(Icons.note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildHistoryTab(),
          _buildNotesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bookAppointment,
        child: const Icon(Icons.add),
        tooltip: 'Записать клиента',
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client Header
          _buildClientHeader(),
          const SizedBox(height: 24),
          // Stats Cards
          _buildStatsCards(),
          const SizedBox(height: 24),
          // Contact Information
          _buildContactInfo(),
          const SizedBox(height: 24),
          // Personal Information
          _buildPersonalInfo(),
          const SizedBox(height: 24),
          // Preferred Services
          _buildPreferredServices(),
        ],
      ),
    );
  }

  Widget _buildClientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: _getAvatarColor(),
            backgroundImage: widget.client.avatarUrl != null 
                ? NetworkImage(widget.client.avatarUrl!)
                : null,
            child: widget.client.avatarUrl == null
                ? Text(
                    widget.client.initials,
                    style: AppTheme.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.client.fullName,
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusBadge(),
                    const SizedBox(width: 8),
                    _buildLoyaltyBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Клиент с ${_formatDate(widget.client.createdAt)}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Визитов',
            '${widget.client.totalVisits}',
            Icons.event,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Потрачено',
            _formatPrice(widget.client.totalSpent),
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Баллов',
            '${widget.client.loyaltyPoints}',
            Icons.stars,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return _buildSection(
      'Контактная информация',
      Icons.contact_phone,
      [
        _buildInfoRow(Icons.phone, 'Телефон', widget.client.displayPhone),
        if (widget.client.email != null)
          _buildInfoRow(Icons.email, 'Email', widget.client.displayEmail),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return _buildSection(
      'Личная информация',
      Icons.person,
      [
        if (widget.client.dateOfBirth != null) ...[
          _buildInfoRow(
            Icons.cake,
            'Дата рождения',
            '${_formatDate(widget.client.dateOfBirth!)} (${widget.client.age} лет)',
          ),
        ],
        if (widget.client.gender != null)
          _buildInfoRow(Icons.wc, 'Пол', widget.client.gender!),
        if (widget.client.lastVisit != null)
          _buildInfoRow(
            Icons.schedule,
            'Последний визит',
            _formatDate(widget.client.lastVisit!),
          ),
      ],
    );
  }

  Widget _buildPreferredServices() {
    if (widget.client.preferredServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      'Предпочитаемые услуги',
      Icons.favorite,
      [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.client.preferredServices.map((service) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                service,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_mockHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'История пуста',
              style: AppTheme.titleLarge.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Записи клиента будут отображаться здесь',
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
      itemCount: _mockHistory.length,
      itemBuilder: (context, index) {
        final appointment = _mockHistory[index];
        return _buildHistoryItem(appointment);
      },
    );
  }

  Widget _buildHistoryItem(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.serviceName,
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(appointment.status).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    appointment.status.displayName,
                    style: AppTheme.bodySmall.copyWith(
                      color: _getStatusColor(appointment.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(appointment.startTime),
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatPrice(appointment.price),
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (appointment.notes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Заметки о клиенте',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editNotes,
                tooltip: 'Редактировать заметки',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              widget.client.notes ?? 'Заметки отсутствуют',
              style: AppTheme.bodyMedium.copyWith(
                color: widget.client.notes != null ? Colors.black87 : Colors.grey[500],
                fontStyle: widget.client.notes != null ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    switch (widget.client.status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        widget.client.status.displayName,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoyaltyBadge() {
    Color color;
    switch (widget.client.loyaltyLevel) {
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
        widget.client.loyaltyLevel,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getAvatarColor() {
    final hash = widget.client.fullName.hashCode;
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.inProgress:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.teal;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} в ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
  }

  void _editClient() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Редактирование клиента - в разработке')),
    );
  }

  void _callClient() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Звонок ${widget.client.displayPhone}')),
    );
  }

  void _messageClient() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Сообщение для ${widget.client.fullName}')),
    );
  }

  void _blockClient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заблокировать клиента'),
        content: Text('Вы уверены, что хотите заблокировать ${widget.client.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Клиент заблокирован')),
              );
            },
            child: const Text('Заблокировать'),
          ),
        ],
      ),
    );
  }

  void _deleteClient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить клиента'),
        content: Text('Вы уверены, что хотите удалить ${widget.client.fullName}? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Клиент удален')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _bookAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookingPage(
          preselectedClient: widget.client,
        ),
      ),
    ).then((result) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Запись для ${widget.client.fullName} создана!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _editNotes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Редактирование заметок - в разработке')),
    );
  }
}
