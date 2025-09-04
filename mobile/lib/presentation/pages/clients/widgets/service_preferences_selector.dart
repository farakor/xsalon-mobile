import 'package:flutter/material.dart';

import '../../../../data/models/service.dart';
import '../../../theme/app_theme.dart';

class ServicePreferencesSelector extends StatefulWidget {
  final List<String> selectedServices;
  final Function(List<String>) onServicesChanged;

  const ServicePreferencesSelector({
    super.key,
    required this.selectedServices,
    required this.onServicesChanged,
  });

  @override
  State<ServicePreferencesSelector> createState() => _ServicePreferencesSelectorState();
}

class _ServicePreferencesSelectorState extends State<ServicePreferencesSelector> {
  String? _selectedCategoryId;

  // Тестовые данные категорий и услуг (те же, что в ServiceSelector)
  final List<ServiceCategory> _mockCategories = [
    ServiceCategory(
      id: '1',
      name: 'Парикмахерские услуги',
      description: 'Стрижки, укладки, окрашивание',
      iconName: 'content_cut',
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ServiceCategory(
      id: '2',
      name: 'Ногтевой сервис',
      description: 'Маникюр, педикюр, наращивание',
      iconName: 'back_hand',
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ServiceCategory(
      id: '3',
      name: 'Косметология',
      description: 'Уход за лицом, массаж',
      iconName: 'face',
      sortOrder: 3,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ServiceCategory(
      id: '4',
      name: 'Брови и ресницы',
      description: 'Коррекция, окрашивание, наращивание',
      iconName: 'visibility',
      sortOrder: 4,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<Service> _mockServices = [
    // Парикмахерские услуги
    Service(
      id: '1',
      name: 'Женская стрижка',
      description: 'Стрижка любой сложности с укладкой',
      categoryId: '1',
      categoryName: 'Парикмахерские услуги',
      price: 150000,
      durationMinutes: 90,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '2',
      name: 'Окрашивание волос',
      description: 'Полное окрашивание в один тон',
      categoryId: '1',
      categoryName: 'Парикмахерские услуги',
      price: 300000,
      durationMinutes: 150,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '3',
      name: 'Укладка',
      description: 'Праздничная укладка',
      categoryId: '1',
      categoryName: 'Парикмахерские услуги',
      price: 80000,
      durationMinutes: 60,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '4',
      name: 'Мелирование',
      description: 'Мелирование с тонированием',
      categoryId: '1',
      categoryName: 'Парикмахерские услуги',
      price: 400000,
      durationMinutes: 180,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    
    // Ногтевой сервис
    Service(
      id: '5',
      name: 'Маникюр',
      description: 'Классический маникюр с покрытием',
      categoryId: '2',
      categoryName: 'Ногтевой сервис',
      price: 120000,
      durationMinutes: 90,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '6',
      name: 'Педикюр',
      description: 'Классический педикюр с покрытием',
      categoryId: '2',
      categoryName: 'Ногтевой сервис',
      price: 100000,
      durationMinutes: 75,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '7',
      name: 'Наращивание ногтей',
      description: 'Наращивание гелем с дизайном',
      categoryId: '2',
      categoryName: 'Ногтевой сервис',
      price: 200000,
      durationMinutes: 120,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    
    // Косметология
    Service(
      id: '8',
      name: 'Чистка лица',
      description: 'Комплексная чистка лица',
      categoryId: '3',
      categoryName: 'Косметология',
      price: 180000,
      durationMinutes: 90,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '9',
      name: 'Массаж лица',
      description: 'Расслабляющий массаж лица',
      categoryId: '3',
      categoryName: 'Косметология',
      price: 100000,
      durationMinutes: 45,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    
    // Брови и ресницы
    Service(
      id: '10',
      name: 'Коррекция бровей',
      description: 'Коррекция формы бровей',
      categoryId: '4',
      categoryName: 'Брови и ресницы',
      price: 50000,
      durationMinutes: 30,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '11',
      name: 'Окрашивание бровей',
      description: 'Окрашивание бровей краской',
      categoryId: '4',
      categoryName: 'Брови и ресницы',
      price: 40000,
      durationMinutes: 20,
      isActive: true,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  List<Service> get _filteredServices {
    if (_selectedCategoryId == null) return [];
    return _mockServices.where((service) => 
        service.categoryId == _selectedCategoryId && service.isActive).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Services Summary
        if (widget.selectedServices.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Выбрано услуг: ${widget.selectedServices.length}',
                      style: AppTheme.titleSmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.selectedServices.map((serviceName) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            serviceName,
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeService(serviceName),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Categories
        Text(
          'Выберите категории услуг',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mockCategories.length,
            itemBuilder: (context, index) {
              final category = _mockCategories[index];
              final isSelected = _selectedCategoryId == category.id;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryId = isSelected ? null : category.id;
                  });
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCategoryIcon(category.iconName),
                        color: isSelected ? Colors.white : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: AppTheme.bodySmall.copyWith(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Services
        if (_selectedCategoryId != null) ...[
          Text(
            'Выберите услуги',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 300,
            child: _filteredServices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      final isSelected = widget.selectedServices.contains(service.name);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: isSelected ? 4 : 1,
                        child: CheckboxListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            service.name,
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.primaryColor : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                service.description,
                                style: AppTheme.bodyMedium,
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
                                        const Icon(Icons.schedule, size: 14, color: Colors.blue),
                                        const SizedBox(width: 4),
                                        Text(
                                          service.formattedDuration,
                                          style: AppTheme.bodySmall.copyWith(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.attach_money, size: 14, color: Colors.green),
                                        const SizedBox(width: 4),
                                        Text(
                                          service.formattedPrice,
                                          style: AppTheme.bodySmall.copyWith(
                                            color: Colors.green,
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
                          value: isSelected,
                          onChanged: (bool? value) {
                            if (value == true) {
                              _addService(service.name);
                            } else {
                              _removeService(service.name);
                            }
                          },
                          activeColor: AppTheme.primaryColor,
                          selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                          selected: isSelected,
                        ),
                      );
                    },
                  ),
            ),
        ] else ...[
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.design_services,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Выберите категорию',
                    style: AppTheme.titleLarge.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сначала выберите категорию услуг',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.design_services_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Услуги не найдены',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'В этой категории пока нет доступных услуг',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _addService(String serviceName) {
    final updatedServices = List<String>.from(widget.selectedServices);
    if (!updatedServices.contains(serviceName)) {
      updatedServices.add(serviceName);
      widget.onServicesChanged(updatedServices);
    }
  }

  void _removeService(String serviceName) {
    final updatedServices = List<String>.from(widget.selectedServices);
    updatedServices.remove(serviceName);
    widget.onServicesChanged(updatedServices);
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'content_cut':
        return Icons.content_cut;
      case 'back_hand':
        return Icons.back_hand;
      case 'face':
        return Icons.face;
      case 'visibility':
        return Icons.visibility;
      default:
        return Icons.design_services;
    }
  }
}
