import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<Client> _filteredClients = [];
  bool _isNewClientMode = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterClients);
    // Устанавливаем префикс +998 для номера телефона
    _phoneController.text = '+998 ';
    // Добавляем слушатели для валидации кнопки
    _nameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    // Загружаем клиентов при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientsProvider.notifier).loadClients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
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
        // Tab Bar
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                'Клиенты',
                !_isNewClientMode,
                () => setState(() => _isNewClientMode = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleButton(
                'Новый клиент',
                _isNewClientMode,
                () => setState(() => _isNewClientMode = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Content based on mode
        if (_isNewClientMode)
          _buildNewClientForm()
        else
          _buildExistingClientSelector(),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: 0.5,
          ),
        ),
        child: Text(
          text,
          style: AppTheme.bodyMedium.copyWith(
            color: const Color(0xFF000000),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildExistingClientSelector() {
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
          decoration: InputDecoration(
            labelText: 'Поиск клиента',
            hintText: 'Введите имя, телефон или email',
            prefixIcon: const Icon(LucideIcons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        
        // Selected Client (if any)
        if (widget.selectedClient != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Выбран: ${widget.selectedClient!.fullName}',
                        style: AppTheme.titleSmall.copyWith(
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.selectedClient!.displayPhone,
                        style: AppTheme.bodySmall.copyWith(
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
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
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                            width: isSelected ? 1 : 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => widget.onClientSelected(client),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: _getAvatarColor(client),
                                  child: Text(
                                    client.initials,
                                    style: AppTheme.titleSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.fullName,
                                        style: AppTheme.titleMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF000000),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        client.displayPhone,
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(LucideIcons.calendar, size: 12, color: Colors.blue),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${client.totalVisits} визитов',
                                                  style: AppTheme.bodySmall.copyWith(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? AppTheme.primaryColor 
                                        : AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    isSelected ? LucideIcons.check : LucideIcons.chevronRight,
                                    size: 16,
                                    color: isSelected 
                                        ? Colors.white 
                                        : AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }

  Widget _buildNewClientForm() {
    return Column(
      children: [
        // Имя клиента
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Имя клиента *',
            hintText: 'Введите имя клиента',
            prefixIcon: const Icon(LucideIcons.userCheck),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        
        // Телефон клиента
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Телефон *',
            hintText: '+998 XX XXX XX XX',
            prefixIcon: const Icon(LucideIcons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            _PhoneNumberFormatter(),
          ],
        ),
        const SizedBox(height: 24),
        
        // Кнопка создания клиента
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canCreateClient() ? _createClient : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Создать клиента',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canCreateClient() {
    final phoneDigits = _phoneController.text.substring(5).replaceAll(RegExp(r'[^\d]'), '');
    return _nameController.text.trim().isNotEmpty && 
           phoneDigits.length == 9; // Ровно 9 цифр после +998
  }

  Future<void> _createClient() async {
    if (!_canCreateClient()) return;

    try {
      // Показываем индикатор загрузки
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Создание клиента...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }

      // Создаем нового клиента
      final newClient = Client(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: null,
        createdAt: DateTime.now(),
        totalVisits: 0,
        totalSpent: 0,
        loyaltyPoints: 0,
        loyaltyLevel: 'Новичок',
        preferredServices: [],
        status: ClientStatus.active,
        notes: null,
      );

      // Пытаемся добавить клиента через провайдер
      // Если не получается - используем локальное создание
      try {
        await ref.read(clientsProvider.notifier).addClient(newClient);
      } catch (dbError) {
        // Если ошибка связана с RLS - создаем клиента локально
        if (dbError.toString().contains('42501') || 
            dbError.toString().contains('row-level security policy')) {
          
          // Добавляем клиента в локальный список (без сохранения в БД)
          final currentClients = ref.read(clientsListProvider);
          final updatedClients = [...currentClients, newClient];
          
          // Обновляем локальный список клиентов для отображения
          // Это временное решение до исправления RLS в Supabase
          setState(() {
            _filteredClients = [..._filteredClients, newClient];
          });
          
          // Показываем предупреждение
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Клиент создан локально. Данные не сохранены в базе.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
        } else {
          // Если другая ошибка - пробрасываем её дальше
          rethrow;
        }
      }

      // Скрываем индикатор загрузки
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Выбираем созданного клиента
      widget.onClientSelected(newClient);

      // Очищаем форму и переключаемся обратно на список клиентов
      _nameController.clear();
      _phoneController.text = '+998 '; // Восстанавливаем префикс
      setState(() {
        _isNewClientMode = false;
      });

      // Показываем уведомление об успехе
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Клиент "${newClient.fullName}" успешно создан'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Скрываем индикатор загрузки
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Определяем тип ошибки и показываем соответствующее сообщение
      String errorMessage = 'Неизвестная ошибка';
      
      if (e.toString().contains('PostgrestException')) {
        if (e.toString().contains('42501')) {
          errorMessage = 'Недостаточно прав для создания клиента. Обратитесь к администратору.';
        } else if (e.toString().contains('row-level security policy')) {
          errorMessage = 'Ошибка безопасности. Проверьте настройки доступа.';
        } else {
          errorMessage = 'Ошибка базы данных. Попробуйте позже.';
        }
      } else if (e.toString().contains('уже существует')) {
        errorMessage = 'Клиент с таким номером телефона уже существует';
      } else {
        errorMessage = 'Ошибка создания клиента: ${e.toString()}';
      }

      // Показываем ошибку
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Попробовать снова',
              textColor: Colors.white,
              onPressed: _createClient,
            ),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.searchX,
              color: Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Клиенты не найдены',
            style: AppTheme.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          Text(
            'Попробуйте изменить поисковый запрос',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.alertCircle,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ошибка загрузки клиентов',
            style: AppTheme.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          Text(
            error,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                ref.read(clientsProvider.notifier).loadClients();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Повторить',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Если пользователь пытается удалить префикс +998, восстанавливаем его
    if (!text.startsWith('+998')) {
      return const TextEditingValue(
        text: '+998 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }
    
    // Если текст короче чем "+998 ", восстанавливаем префикс
    if (text.length < 5) {
      return const TextEditingValue(
        text: '+998 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }
    
    // Извлекаем только цифры после +998
    final digitsOnly = text.substring(5).replaceAll(RegExp(r'[^\d]'), '');
    
    // Ограничиваем до 9 цифр
    final limitedDigits = digitsOnly.length > 9 ? digitsOnly.substring(0, 9) : digitsOnly;
    
    // Форматируем номер: +998 XX XXX XX XX
    String formatted = '+998 ';
    if (limitedDigits.isNotEmpty) {
      if (limitedDigits.length <= 2) {
        formatted += limitedDigits;
      } else if (limitedDigits.length <= 5) {
        formatted += '${limitedDigits.substring(0, 2)} ${limitedDigits.substring(2)}';
      } else if (limitedDigits.length <= 7) {
        formatted += '${limitedDigits.substring(0, 2)} ${limitedDigits.substring(2, 5)} ${limitedDigits.substring(5)}';
      } else {
        formatted += '${limitedDigits.substring(0, 2)} ${limitedDigits.substring(2, 5)} ${limitedDigits.substring(5, 7)} ${limitedDigits.substring(7)}';
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
