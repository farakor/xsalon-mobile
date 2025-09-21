import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/utils/timezone_utils.dart';
import '../../../data/models/client.dart';
import '../../../data/models/service.dart';
import '../../theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/schedule_provider.dart';
import 'widgets/client_selector.dart';
import 'widgets/master_service_selector.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Новая запись'),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.02),
        surfaceTintColor: Colors.white,
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: Text(
                'Назад',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 0.5,
          ),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_stepTitles.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              
              return Expanded(
                child: Text(
                  _stepTitles[index],
                  style: AppTheme.bodySmall.copyWith(
                    color: isCurrent ? AppTheme.primaryColor : const Color(0xFF000000),
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции с иконкой
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.user,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Выберите клиента',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Найдите существующего клиента или добавьте нового',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Client Selector
          Container(
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
            child: ClientSelector(
              selectedClient: _selectedClient,
              onClientSelected: (client) {
                setState(() {
                  _selectedClient = client;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции с иконкой
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.scissors,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Выберите услугу',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите услугу из ваших доступных услуг',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
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
            child: MasterServiceSelector(
              selectedServices: _selectedServices,
              onServicesChanged: (services) {
                setState(() {
                  _selectedServices = services;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции с иконкой
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.clock,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Выберите время',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите удобную дату и время для записи',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
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
            child: TimeSelector(
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
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции с иконкой
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.checkCircle,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Подтверждение',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Проверьте данные записи перед созданием',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildBookingSummary(),
          
          const SizedBox(height: 16),
          
          // Notes field в карточке
          Container(
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
                      child: const Icon(
                        LucideIcons.edit,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Заметки',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Дополнительная информация о записи...',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildBookingSummary() {
    final clientName = _selectedClient?.fullName ?? 'Не выбран';
    final clientPhone = _selectedClient?.phone ?? '';

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
                child: const Icon(
                  LucideIcons.calendar,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Детали записи',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSummaryRow(LucideIcons.userCheck, 'Клиент', clientName),
          if (clientPhone.isNotEmpty)
            _buildSummaryRow(LucideIcons.phone, 'Телефон', clientPhone),
          _buildSummaryRow(
            LucideIcons.scissors, 
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
                LucideIcons.arrowRight, 
                '', 
                service.name
              )).toList(),
            ],
            _buildSummaryRow(
              LucideIcons.clock, 
              'Общая длительность', 
              _formatTotalDuration()
            ),
            _buildSummaryRow(
              LucideIcons.dollarSign, 
              'Общая стоимость', 
              _formatTotalPrice()
            ),
          ],
          if (startTime != null)
            _buildSummaryRow(
              LucideIcons.calendar, 
              'Дата и время', 
              '${_formatDate(startTime)} в ${_formatTime(TimeOfDay.fromDateTime(startTime))}'
            ),
          if (endTime != null)
            _buildSummaryRow(
              LucideIcons.clock, 
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
                color: const Color(0xFF000000),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF000000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
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
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: AppTheme.borderColor,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'Назад',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0)
            const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceed() ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.3),
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        _currentStep == 3 ? 'Создать запись' : 'Далее',
                        style: AppTheme.bodyMedium.copyWith(
                          color: _canProceed() ? Colors.black : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedClient != null;
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
