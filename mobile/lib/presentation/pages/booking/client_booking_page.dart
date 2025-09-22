import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../providers/masters_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../../domain/entities/service.dart';
import '../../../domain/entities/master.dart';
import '../../../core/constants/app_constants.dart';
import 'widgets/client_time_selector.dart';

class ClientBookingPage extends ConsumerStatefulWidget {
  const ClientBookingPage({super.key});

  @override
  ConsumerState<ClientBookingPage> createState() => _ClientBookingPageState();
}

class _ClientBookingPageState extends ConsumerState<ClientBookingPage> {
  ServiceEntity? selectedService;
  MasterEntity? selectedMaster;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Загружаем данные при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      print('ClientBookingPage: Начинаем загрузку данных...');
      
      print('ClientBookingPage: Загружаем активные услуги...');
      await ref.read(servicesProvider.notifier).loadActiveServices();
      
      print('ClientBookingPage: Загружаем активных мастеров...');
      await ref.read(mastersProvider.notifier).loadActiveMasters();
      
      // Проверяем результат загрузки
      final mastersState = ref.read(mastersProvider);
      print('ClientBookingPage: Состояние мастеров: ${mastersState.status}');
      print('ClientBookingPage: Количество мастеров: ${mastersState.masters.length}');
      if (mastersState.errorMessage != null) {
        print('ClientBookingPage: Ошибка мастеров: ${mastersState.errorMessage}');
      }
      
      print('ClientBookingPage: Загрузка данных завершена');
    } catch (e) {
      print('ClientBookingPage: Ошибка загрузки данных: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  void _handleBackPress() {
    // Если мы не на первом шаге, возвращаемся к предыдущему шагу
    if (_currentStep > 0) {
      _previousStep();
    } else {
      // Если на первом шаге, показываем диалог подтверждения выхода
      _showExitConfirmationDialog();
    }
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выйти из записи?'),
          content: const Text(
            'Вы уверены, что хотите выйти? Все введенные данные будут потеряны.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
                context.pop(); // Возвращаемся на предыдущую страницу
              },
              child: const Text(
                'Выйти',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return selectedMaster != null;
      case 1:
        return selectedService != null;
      case 2:
        return selectedDate != null && selectedTime != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись на услугу'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: _handleBackPress,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildStepIndicator(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMasterSelection(),
                _buildServiceSelection(),
                _buildDateTimeSelection(),
                _buildBookingConfirmation(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isActive 
                        ? AppTheme.primaryColor 
                        : Colors.grey.shade300,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: index < _currentStep 
                          ? AppTheme.primaryColor 
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите услугу',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedMaster != null 
                ? 'Услуги мастера "${selectedMaster!.fullName}"'
                : 'Сначала выберите мастера',
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildServicesContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesContent() {
    if (selectedMaster == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Сначала выберите мастера',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final services = ref.watch(servicesByMasterProvider(selectedMaster!.id));
    
    if (services.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'У мастера нет услуг',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Выберите другого мастера',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = selectedService?.id == service.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedService = service;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.scissors,
                      color: AppTheme.primaryColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.formattedDuration,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              LucideIcons.dollarSign,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.formattedPrice,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      LucideIcons.checkCircle,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMasterSelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите мастера',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Кто будет выполнять услугу?',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildMastersContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMastersContent() {
    final mastersState = ref.watch(mastersProvider);
    
    if (mastersState.status == MastersStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (mastersState.status == MastersStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки мастеров',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              mastersState.errorMessage ?? 'Неизвестная ошибка',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(mastersProvider.notifier).loadActiveMasters(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    // Безопасная проверка на null и фильтрация
    final allMasters = mastersState.masters;
    final masters = allMasters.where((m) => m.isActive).toList();
    
    if (masters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.userX, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Мастера не найдены',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Возможно, мастера еще не добавлены в систему',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('ClientBookingPage: Повторная загрузка мастеров...');
                ref.read(mastersProvider.notifier).loadActiveMasters();
              },
              child: const Text('Обновить'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: masters.length,
      itemBuilder: (context, index) {
        final master = masters[index];
        final isSelected = selectedMaster?.id == master.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedMaster = master;
                selectedService = null; // Сбрасываем выбор услуги
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: master.avatarUrl != null 
                        ? NetworkImage(master.avatarUrl!) 
                        : null,
                    child: master.avatarUrl == null
                        ? Text(
                            master.initials,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 18,
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
                          master.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (master.description != null)
                          Text(
                            master.description!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              size: 16,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              master.formattedRating,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              LucideIcons.briefcase,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              master.formattedExperience,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      LucideIcons.checkCircle,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateTimeSelection() {
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
                'Выберите дату и время',
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
            child: ClientTimeSelector(
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              selectedMaster: selectedMaster,
              selectedService: selectedService,
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                  selectedTime = null; // Сбрасываем время при смене даты
                });
              },
              onTimeSelected: (time) {
                setState(() {
                  selectedTime = time;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingConfirmation() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Подтверждение записи',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Проверьте детали вашей записи',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Услуга
                  if (selectedService != null)
                    _buildConfirmationCard(
                      icon: LucideIcons.scissors,
                      title: 'Услуга',
                      content: selectedService!.name,
                      subtitle: '${selectedService!.formattedDuration} • ${selectedService!.formattedPrice}',
                    ),
                  const SizedBox(height: 16),
                  // Мастер
                  if (selectedMaster != null)
                    _buildConfirmationCard(
                      icon: LucideIcons.userCheck,
                      title: 'Мастер',
                      content: selectedMaster!.fullName,
                      subtitle: '${selectedMaster!.formattedRating} ⭐ • ${selectedMaster!.formattedExperience}',
                    ),
                  const SizedBox(height: 16),
                  // Дата и время
                  if (selectedDate != null && selectedTime != null)
                    _buildConfirmationCard(
                      icon: LucideIcons.calendarCheck,
                      title: 'Дата и время',
                      content: '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}',
                      subtitle: '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  const SizedBox(height: 24),
                  // Итоговая стоимость
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Итого к оплате:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          selectedService?.formattedPrice ?? '0 сум',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
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
                ),
                child: const Text('Назад'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: _currentStep == 3 ? 'Записаться' : 'Далее',
              onPressed: _canProceed ? (_currentStep == 3 ? _confirmBooking : _nextStep) : null,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _confirmBooking() async {
    // Проверяем, что все данные заполнены
    if (selectedMaster == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите мастера'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите услугу'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите дату и время'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Получаем ID текущего клиента
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Ищем клиента по user_profile_id
      final clientResponse = await Supabase.instance.client
          .from('clients')
          .select('id')
          .eq('user_profile_id', currentUser.id)
          .single();

      final clientId = clientResponse['id'] as String;

      // Создаем DateTime для записи
      final startDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final endDateTime = startDateTime.add(
        Duration(minutes: selectedService!.durationMinutes),
      );

      // Создаем запись через провайдер
      final success = await ref.read(bookingProvider.notifier).createBooking(
        clientId: clientId,
        serviceIds: [selectedService!.id],
        startTime: startDateTime,
        endTime: endDateTime,
        totalPrice: selectedService!.price,
        masterId: selectedMaster!.id, // Передаем ID выбранного мастера
      );

      // Закрываем индикатор загрузки
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Запись успешно создана!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Переходим на главную
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            context.go(AppConstants.homeRoute);
          }
        });
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
      // Закрываем индикатор загрузки
      if (mounted) {
        Navigator.of(context).pop();
      }

      print('ClientBookingPage: Error creating booking: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания записи: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
