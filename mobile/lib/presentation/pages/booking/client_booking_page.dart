import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../providers/masters_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../../domain/entities/service.dart';
import '../../../domain/entities/master.dart';

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
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
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
            Icon(Icons.person_search, size: 64, color: Colors.grey),
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
            Icon(Icons.search_off, size: 64, color: Colors.grey),
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
                      Icons.content_cut,
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
                              Icons.access_time,
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
                              Icons.attach_money,
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
                      Icons.check_circle,
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
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
                              Icons.star,
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
                              Icons.work_outline,
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
                      Icons.check_circle,
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите дату и время',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Когда вам удобно прийти?',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              children: [
                // Выбор даты
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Дата'),
                    subtitle: Text(
                      selectedDate != null
                          ? '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}'
                          : 'Выберите дату',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(height: 16),
                // Выбор времени
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Время'),
                    subtitle: Text(
                      selectedTime != null
                          ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                          : 'Выберите время',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: selectedDate != null ? _selectTime : null,
                  ),
                ),
                const SizedBox(height: 24),
                if (selectedDate != null && selectedTime != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Запись на ${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year} в ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
                      icon: Icons.content_cut,
                      title: 'Услуга',
                      content: selectedService!.name,
                      subtitle: '${selectedService!.formattedDuration} • ${selectedService!.formattedPrice}',
                    ),
                  const SizedBox(height: 16),
                  // Мастер
                  if (selectedMaster != null)
                    _buildConfirmationCard(
                      icon: Icons.person,
                      title: 'Мастер',
                      content: selectedMaster!.fullName,
                      subtitle: '${selectedMaster!.formattedRating} ⭐ • ${selectedMaster!.formattedExperience}',
                    ),
                  const SizedBox(height: 16),
                  // Дата и время
                  if (selectedDate != null && selectedTime != null)
                    _buildConfirmationCard(
                      icon: Icons.schedule,
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

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 90));

    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ru'),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        selectedTime = null; // Сбрасываем время при смене даты
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void _confirmBooking() {
    // TODO: Реализовать создание записи
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Запись успешно создана!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop();
  }
}
