import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/timezone_utils.dart';
import '../../../data/models/client.dart';
import '../../../data/models/service.dart';
import '../../theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/schedule_provider.dart';
import 'widgets/client_selector.dart';
import 'widgets/service_selector.dart';
import 'widgets/time_selector.dart';

class AddBookingPage extends ConsumerStatefulWidget {
  final Client? preselectedClient;
  final DateTime? preselectedDate;

  const AddBookingPage({
    super.key,
    this.preselectedClient,
    this.preselectedDate,
  });

  @override
  ConsumerState<AddBookingPage> createState() => _AddBookingPageState();
}

class _AddBookingPageState extends ConsumerState<AddBookingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form data
  Client? _selectedClient;
  List<Service> _selectedServices = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientPhoneController = TextEditingController();

  bool _isNewClient = false;
  bool _isLoading = false;

  final List<String> _stepTitles = [
    'Выбор клиента',
    'Выбор услуги',
    'Выбор времени',
    'Подтверждение',
  ];

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.preselectedClient;
    _selectedDate = widget.preselectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая запись'),
        elevation: 0,
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('Назад'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildClientStep(),
                _buildServiceStep(),
                _buildTimeStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          // Bottom Actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
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
          Row(
            children: List.generate(_stepTitles.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? AppTheme.primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < _stepTitles.length - 1)
                      const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_stepTitles.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              
              return Expanded(
                child: Text(
                  _stepTitles[index],
                  style: AppTheme.bodySmall.copyWith(
                    color: isCompleted || isCurrent
                        ? AppTheme.primaryColor
                        : Colors.grey[600],
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildClientStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Шаг 1: Выберите клиента',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Найдите существующего клиента или добавьте нового',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Toggle between existing and new client
          Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  'Существующий клиент',
                  !_isNewClient,
                  () => setState(() => _isNewClient = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToggleButton(
                  'Новый клиент',
                  _isNewClient,
                  () => setState(() => _isNewClient = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (_isNewClient)
            _buildNewClientForm()
          else
            ClientSelector(
              selectedClient: _selectedClient,
              onClientSelected: (client) {
                setState(() {
                  _selectedClient = client;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildServiceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Шаг 2: Выберите услугу',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите услугу из доступных категорий',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          ServiceSelector(
            selectedServices: _selectedServices,
            onServicesChanged: (services) {
              setState(() {
                _selectedServices = services;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Шаг 3: Выберите время',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите удобную дату и время для записи',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          TimeSelector(
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            serviceDuration: _getTotalDuration(),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onTimeSelected: (time) {
              setState(() {
                _selectedTime = time;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Шаг 4: Подтверждение',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Проверьте данные записи перед созданием',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildBookingSummary(),
          
          const SizedBox(height: 24),
          
          // Notes field
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Заметки (необязательно)',
              hintText: 'Дополнительная информация о записи...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewClientForm() {
    return Column(
      children: [
        TextField(
          controller: _clientNameController,
          decoration: const InputDecoration(
            labelText: 'Имя клиента *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _clientPhoneController,
          decoration: const InputDecoration(
            labelText: 'Телефон *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: AppTheme.bodyMedium.copyWith(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final clientName = _isNewClient 
        ? _clientNameController.text
        : _selectedClient?.fullName ?? 'Не выбран';
    
    final clientPhone = _isNewClient 
        ? _clientPhoneController.text
        : _selectedClient?.phone ?? '';

    final startTime = _selectedDate != null && _selectedTime != null
        ? DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          )
        : null;

    final totalDuration = _getTotalDuration();
    final endTime = startTime != null && totalDuration != null
        ? startTime.add(totalDuration)
        : null;

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
              const Icon(Icons.event, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Детали записи',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSummaryRow(Icons.person, 'Клиент', clientName),
          if (clientPhone.isNotEmpty)
            _buildSummaryRow(Icons.phone, 'Телефон', clientPhone),
          _buildSummaryRow(
            Icons.design_services, 
            'Услуги', 
            _selectedServices.isEmpty 
                ? 'Не выбраны' 
                : _selectedServices.length == 1 
                    ? _selectedServices.first.name
                    : '${_selectedServices.length} услуг'
          ),
          if (_selectedServices.isNotEmpty) ...[
            // Показываем все услуги, если их больше одной
            if (_selectedServices.length > 1) ...[
              ..._selectedServices.map((service) => _buildSummaryRow(
                Icons.arrow_right, 
                '', 
                service.name
              )).toList(),
            ],
            _buildSummaryRow(
              Icons.schedule, 
              'Общая длительность', 
              _formatTotalDuration()
            ),
            _buildSummaryRow(
              Icons.attach_money, 
              'Общая стоимость', 
              _formatTotalPrice()
            ),
          ],
          if (startTime != null)
            _buildSummaryRow(
              Icons.calendar_today, 
              'Дата и время', 
              '${_formatDate(startTime)} в ${_formatTime(TimeOfDay.fromDateTime(startTime))}'
            ),
          if (endTime != null)
            _buildSummaryRow(
              Icons.schedule, 
              'Окончание', 
              _formatTime(TimeOfDay.fromDateTime(endTime))
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
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

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Назад'),
              ),
            ),
          if (_currentStep > 0)
            const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_currentStep == 3 ? 'Создать запись' : 'Далее'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _isNewClient 
            ? _clientNameController.text.isNotEmpty && _clientPhoneController.text.isNotEmpty
            : _selectedClient != null;
      case 1:
        return _selectedServices.isNotEmpty;
      case 2:
        return _selectedDate != null && _selectedTime != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createBooking();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Проверяем что все данные заполнены
      if (_selectedClient == null) {
        throw Exception('Клиент не выбран');
      }
      if (_selectedServices.isEmpty) {
        throw Exception('Услуги не выбраны');
      }
      if (_selectedDate == null || _selectedTime == null) {
        throw Exception('Дата и время не выбраны');
      }

      // Создаем DateTime для начала записи в самаркандском времени
      final startDateTime = TimezoneUtils.createSamarkandDateTime(_selectedDate!, _selectedTime!);

      // Рассчитываем время окончания
      final totalDuration = _getTotalDuration();
      if (totalDuration == null) {
        throw Exception('Не удалось рассчитать длительность услуг');
      }
      final endDateTime = startDateTime.add(totalDuration);

      // Рассчитываем общую стоимость
      final totalPrice = _getTotalPrice();

      // Получаем ID услуг
      final serviceIds = _selectedServices.map((service) => service.id).toList();

      print('AddBookingPage: Creating booking with data:');
      print('  Client: ${_selectedClient!.fullName} (${_selectedClient!.id})');
      print('  Services: ${_selectedServices.map((s) => s.name).join(', ')}');
      print('  Start: $startDateTime');
      print('  End: $endDateTime');
      print('  Total price: $totalPrice');

      // Создаем запись через провайдер
      final success = await ref.read(bookingProvider.notifier).createBooking(
        clientId: _selectedClient!.id,
        serviceIds: serviceIds,
        startTime: startDateTime,
        endTime: endDateTime,
        totalPrice: totalPrice,
        clientNotes: null, // TODO: Добавить поле для заметок клиента
      );

      if (success && mounted) {
        // Обновляем слоты после создания записи
        if (_selectedDate != null) {
          ref.read(scheduleProvider.notifier).loadAvailableSlots(
            _selectedDate!,
            serviceDuration: _getTotalDuration(),
          );
        }
        
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Запись успешно создана!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        final error = ref.read(bookingErrorProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания записи: ${error ?? 'Неизвестная ошибка'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('AddBookingPage: Error creating booking: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания записи: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Duration? _getTotalDuration() {
    if (_selectedServices.isEmpty) return null;
    
    int totalMinutes = 0;
    for (final service in _selectedServices) {
      totalMinutes += service.durationMinutes;
    }
    
    return Duration(minutes: totalMinutes);
  }

  double _getTotalPrice() {
    double totalPrice = 0;
    for (final service in _selectedServices) {
      totalPrice += service.price;
    }
    return totalPrice;
  }

  String _formatTotalDuration() {
    final totalDuration = _getTotalDuration();
    if (totalDuration == null) return '0мин';
    
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}ч ${minutes}мин';
    } else if (hours > 0) {
      return '${hours}ч';
    } else {
      return '${minutes}мин';
    }
  }

  String _formatTotalPrice() {
    final totalPrice = _getTotalPrice();
    return '${(totalPrice / 1000).toStringAsFixed(0)} тыс. сум';
  }

  String _formatDate(DateTime date) {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
