import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
      status: AppointmentStatus.confirmed,
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
      status: AppointmentStatus.confirmed,
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
      status: AppointmentStatus.confirmed,
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 0.5,
            ),
          ),
          child: IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: AppTheme.textPrimaryColor,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'call':
                    _callClient();
                    break;
                  case 'edit':
                    _editClient();
                    break;
                  case 'block':
                    _blockClient();
                    break;
                  case 'delete':
                    _deleteClient();
                    break;
                }
              },
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  LucideIcons.moreVertical,
                  color: AppTheme.textSecondaryColor,
                  size: 18,
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'call',
                  child: Row(
                    children: [
                      Icon(LucideIcons.phone, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Позвонить'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.edit),
                      SizedBox(width: 8),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(LucideIcons.ban, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Заблокировать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash2, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Удалить'),
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
          // Client Header
          _buildClientHeader(),
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              labelStyle: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: AppTheme.bodyMedium,
              tabs: const [
                Tab(text: 'Профиль'),
                Tab(text: 'История'),
                Tab(text: 'Заметки'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildHistoryTab(),
                _buildNotesTab(),
              ],
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
            onTap: _bookAppointment,
            borderRadius: BorderRadius.circular(16),
            child: const Icon(
              LucideIcons.plus,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information
          _buildContactInfo(),
          const SizedBox(height: 16),
          // Personal Information
          _buildPersonalInfo(),
          const SizedBox(height: 16),
          // Preferred Services
          if (widget.client.preferredServices.isNotEmpty)
            _buildPreferredServices(),
        ],
      ),
    );
  }

  Widget _buildClientHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _getAvatarColor().withValues(alpha: 0.1),
                  border: Border.all(
                    color: _getAvatarColor().withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: widget.client.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Image.network(
                          widget.client.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          widget.client.initials,
                          style: AppTheme.headlineSmall.copyWith(
                            color: _getAvatarColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 20),
              // Client Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.client.fullName,
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.client.displayPhone,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (widget.client.loyaltyLevel == 'VIP')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'VIP',
                              style: AppTheme.labelSmall.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (widget.client.loyaltyLevel == 'VIP')
                          const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getClientStatusColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.client.status.displayName,
                            style: AppTheme.labelSmall.copyWith(
                              color: _getClientStatusColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  LucideIcons.calendar,
                  '${widget.client.totalVisits}',
                  'визитов',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildQuickStat(
                  LucideIcons.clock,
                  widget.client.lastVisit != null 
                      ? _formatDateShort(widget.client.lastVisit!)
                      : 'Никогда',
                  'последний визит',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return _buildSection(
      'Контактная информация',
      LucideIcons.phone,
      [
        _buildInfoRow(LucideIcons.phone, 'Телефон', widget.client.displayPhone),
        if (widget.client.email != null)
          _buildInfoRow(LucideIcons.mail, 'Email', widget.client.displayEmail),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return _buildSection(
      'Личная информация',
      LucideIcons.userCheck,
      [
        if (widget.client.dateOfBirth != null) ...[
          _buildInfoRow(
            LucideIcons.cake,
            'Дата рождения',
            '${_formatDate(widget.client.dateOfBirth!)} (${widget.client.age} лет)',
          ),
        ],
        if (widget.client.gender != null)
          _buildInfoRow(LucideIcons.user, 'Пол', widget.client.gender!),
        if (widget.client.lastVisit != null)
          _buildInfoRow(
            LucideIcons.calendarCheck,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_mockHistory.isEmpty) {
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
                  LucideIcons.clock,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'История пуста',
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Записи клиента будут отображаться здесь',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: _mockHistory.length,
      itemBuilder: (context, index) {
        final appointment = _mockHistory[index];
        return _buildHistoryItem(appointment);
      },
    );
  }

  Widget _buildHistoryItem(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Expanded(
                child: Text(
                  appointment.serviceName,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment.status.displayName,
                  style: AppTheme.labelSmall.copyWith(
                    color: _getStatusColor(appointment.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDateTime(appointment.startTime),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const Spacer(),
              Text(
                _formatPrice(appointment.price),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (appointment.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.fileText,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.notes!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
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
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.fileText,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Заметки о клиенте',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              Container(
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
                child: IconButton(
                  icon: Icon(
                    LucideIcons.edit,
                    size: 18,
                    color: AppTheme.textSecondaryColor,
                  ),
                  onPressed: _editNotes,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.client.notes != null && widget.client.notes!.isNotEmpty
                ? Text(
                    widget.client.notes!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimaryColor,
                      height: 1.5,
                    ),
                  )
                : Column(
                    children: [
                      Icon(
                        LucideIcons.edit,
                        size: 48,
                        color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Заметки отсутствуют',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Нажмите на кнопку редактирования, чтобы добавить заметки',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Color _getClientStatusColor() {
    switch (widget.client.status) {
      case ClientStatus.active:
        return Colors.green;
      case ClientStatus.inactive:
        return Colors.orange;
      case ClientStatus.blocked:
        return Colors.red;
    }
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
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateShort(DateTime date) {
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
      return '${date.day}.${date.month.toString().padLeft(2, '0')}';
    }
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
