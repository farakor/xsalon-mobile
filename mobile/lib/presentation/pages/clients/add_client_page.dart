import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/client.dart';
import '../../../data/models/service.dart';
import '../../../data/services/client_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/service_preferences_selector.dart';

class AddClientPage extends ConsumerStatefulWidget {
  const AddClientPage({super.key});

  @override
  ConsumerState<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends ConsumerState<AddClientPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form data
  DateTime? _birthDate;
  String _selectedGender = 'female';
  List<Service> _selectedServices = [];
  bool _isLoading = false;

  final List<String> _stepTitles = [
    'Основная информация',
    'Дополнительные данные',
    'Предпочтения',
    'Подтверждение',
  ];

  @override
  void initState() {
    super.initState();
    
    // Добавляем слушатели для обновления состояния кнопки
    _firstNameController.addListener(_updateButtonState);
    _lastNameController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      // Просто обновляем состояние для перерисовки кнопки
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый клиент'),
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
                _buildBasicInfoStep(),
                _buildAdditionalInfoStep(),
                _buildPreferencesStep(),
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

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Шаг 1: Основная информация',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Введите основные данные клиента',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Avatar placeholder
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      LucideIcons.userCheck,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(LucideIcons.camera, color: Colors.white, size: 20),
                        onPressed: _pickAvatar,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // First Name
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Имя *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(LucideIcons.user),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите имя клиента';
                }
                if (value.trim().length < 2) {
                  return 'Имя должно содержать минимум 2 символа';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Фамилия *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(LucideIcons.user),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите фамилию клиента';
                }
                if (value.trim().length < 2) {
                  return 'Фамилия должна содержать минимум 2 символа';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Телефон *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(LucideIcons.phone),
                hintText: '+998 90 123 45 67',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _PhoneInputFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите номер телефона';
                }
                final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                if (cleanPhone.length != 12 || !cleanPhone.startsWith('998')) {
                  return 'Введите корректный номер телефона';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (необязательно)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(LucideIcons.mail),
                hintText: 'example@mail.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Введите корректный email';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Шаг 2: Дополнительные данные',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Дополнительная информация о клиенте',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Gender Selection
          Text(
            'Пол',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGenderButton('female', 'Женский', LucideIcons.user),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderButton('male', 'Мужской', LucideIcons.user),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Birth Date
          Text(
            'Дата рождения (необязательно)',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectBirthDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendarDays, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _birthDate != null
                          ? _formatDate(_birthDate!)
                          : 'Выберите дату рождения',
                      style: AppTheme.bodyMedium.copyWith(
                        color: _birthDate != null ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (_birthDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _birthDate = null),
                      child: const Icon(LucideIcons.x, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Заметки (необязательно)',
              hintText: 'Дополнительная информация о клиенте...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(LucideIcons.fileText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Шаг 3: Предпочтения',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите предпочитаемые услуги клиента',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          ServicePreferencesSelector(
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
            'Проверьте данные клиента перед созданием',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          _buildClientSummary(),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSummary() {
    final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
    
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
              const Icon(LucideIcons.userCheck, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Данные клиента',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSummaryRow(LucideIcons.userCheck, 'Имя', fullName),
          _buildSummaryRow(LucideIcons.phone, 'Телефон', _phoneController.text),
          if (_emailController.text.isNotEmpty)
            _buildSummaryRow(LucideIcons.mail, 'Email', _emailController.text),
          _buildSummaryRow(
            _selectedGender == 'female' ? LucideIcons.user : LucideIcons.user,
            'Пол',
            _selectedGender == 'female' ? 'Женский' : 'Мужской',
          ),
          if (_birthDate != null)
            _buildSummaryRow(LucideIcons.cake, 'Дата рождения', _formatDate(_birthDate!)),
          if (_selectedServices.isNotEmpty)
            _buildSummaryRow(
              LucideIcons.sparkles,
              'Предпочитаемые услуги',
              _selectedServices.map((s) => s.name).join(', '),
            ),
          if (_notesController.text.isNotEmpty)
            _buildSummaryRow(LucideIcons.fileText, 'Заметки', _notesController.text),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  : Text(_currentStep == 3 ? 'Создать клиента' : 'Далее'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        // Проверяем обязательные поля напрямую
        final firstName = _firstNameController.text.trim();
        final lastName = _lastNameController.text.trim();
        final phone = _phoneController.text.trim();
        
        if (firstName.isEmpty || firstName.length < 2) return false;
        if (lastName.isEmpty || lastName.length < 2) return false;
        if (phone.isEmpty) return false;
        
        // Проверяем формат телефона
        final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
        if (cleanPhone.length != 12 || !cleanPhone.startsWith('998')) return false;
        
        // Проверяем email если он заполнен
        final email = _emailController.text.trim();
        if (email.isNotEmpty) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(email)) return false;
        }
        
        return true;
      case 1:
      case 2:
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createClient();
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

  Future<void> _createClient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clientService = ClientService();

      // Создаем объект клиента
      final newClient = Client(
        id: '', // ID будет сгенерирован в базе данных
        fullName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        phone: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        dateOfBirth: _birthDate,
        gender: _selectedGender == 'female' ? 'Женский' : 'Мужской',
        createdAt: DateTime.now(),
        totalVisits: 0,
        totalSpent: 0,
        loyaltyPoints: 0,
        loyaltyLevel: 'Новичок',
        preferredServices: _selectedServices.map((s) => s.name).toList(),
        status: ClientStatus.active,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Создаем клиента через сервис
      final createdClient = await clientService.createClient(newClient);

      if (mounted) {
        Navigator.pop(context, createdClient);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Клиент ${createdClient.fullName} успешно добавлен!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания клиента: $error'),
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



  void _pickAvatar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выбор аватара - в разработке')),
    );
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
    );
    
    if (date != null) {
      setState(() {
        _birthDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return const TextEditingValue();
    }

    String formatted = '';
    
    if (text.length >= 1) {
      if (!text.startsWith('998')) {
        formatted = '+998 ';
        if (text.length > 3) {
          formatted += text.substring(3);
        }
      } else {
        formatted = '+$text';
      }
    }

    // Format: +998 90 123 45 67
    if (formatted.length > 4) {
      final digits = formatted.substring(4);
      String result = '+998';
      
      if (digits.isNotEmpty) {
        result += ' ${digits.substring(0, digits.length > 2 ? 2 : digits.length)}';
        if (digits.length > 2) {
          result += ' ${digits.substring(2, digits.length > 5 ? 5 : digits.length)}';
          if (digits.length > 5) {
            result += ' ${digits.substring(5, digits.length > 7 ? 7 : digits.length)}';
            if (digits.length > 7) {
              result += ' ${digits.substring(7, digits.length > 9 ? 9 : digits.length)}';
            }
          }
        }
      }
      
      formatted = result;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
