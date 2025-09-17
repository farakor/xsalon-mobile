import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/service.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/simple_services_provider.dart';

class ServiceSelector extends ConsumerStatefulWidget {
  final List<Service> selectedServices;
  final Function(List<Service>) onServicesChanged;

  const ServiceSelector({
    super.key,
    this.selectedServices = const [],
    required this.onServicesChanged,
  });

  @override
  ConsumerState<ServiceSelector> createState() => _ServiceSelectorState();
}

class _ServiceSelectorState extends ConsumerState<ServiceSelector> {
  String? _selectedCategoryId;
  List<Service> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    // Если есть выбранные услуги, устанавливаем их как отфильтрованные
    if (widget.selectedServices.isNotEmpty) {
      // В новой архитектуре услуги не привязаны к категориям
      // Используем первую категорию по умолчанию или null
      _selectedCategoryId = null;
      _filteredServices = List.from(widget.selectedServices);
    }
    
    // Загружаем категории при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(simpleServicesProvider.notifier).loadCategories();
    });
  }

  Future<void> _loadServicesByCategory(String categoryId) async {
    final services = await ref.read(simpleServicesProvider.notifier).getServicesByCategory(categoryId);
    setState(() {
      _filteredServices = services;
    });
  }


  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(simpleCategoriesProvider);
    final isLoading = ref.watch(isSimpleServicesLoadingProvider);
    final error = ref.watch(simpleServicesErrorProvider);

    return Column(
      children: [
        // Selected Services (if any)
        if (widget.selectedServices.isNotEmpty) ...[
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Выбрано услуг: ${widget.selectedServices.length}',
                      style: AppTheme.titleSmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.selectedServices.map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            service.name,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeService(service),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Общая длительность: ${_formatTotalDuration()} • Общая стоимость: ${_formatTotalPrice()}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Categories с иконкой
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
                Icons.category,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Выберите категорию услуг',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Loading state for categories
        if (isLoading && categories.isEmpty)
          Container(
            height: 100,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          )
        // Error state
        else if (error != null)
          Container(
            height: 100,
            child: _buildErrorState(error),
          )
        // Categories list
        else
          SizedBox(
            height: 100,
            child: categories.isEmpty
                ? _buildEmptyCategoriesState()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _selectedCategoryId == category.id;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                          _loadServicesByCategory(category.id);
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.primaryColor 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? AppTheme.primaryColor 
                                  : AppTheme.borderColor,
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
                                  color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
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
                  Icons.design_services,
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
          const SizedBox(height: 12),
          
          Container(
            height: 400,
            child: _filteredServices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      final isSelected = widget.selectedServices.any((s) => s.id == service.id);
                      
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
                          onTap: () => _toggleService(service),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        service.name,
                                        style: AppTheme.titleMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                                        ),
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
                                        isSelected ? Icons.check : Icons.add,
                                        size: 16,
                                        color: isSelected 
                                            ? Colors.white 
                                            : AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  service.description,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
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
                      ),
                        ),
                      );
                    },
                  ),
          ),
        ] else ...[
          Container(
            height: 400,
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

  void _toggleService(Service service) {
    final updatedServices = List<Service>.from(widget.selectedServices);
    
    if (updatedServices.any((s) => s.id == service.id)) {
      // Убираем услугу, если она уже выбрана
      updatedServices.removeWhere((s) => s.id == service.id);
    } else {
      // Добавляем услугу, если она не выбрана
      updatedServices.add(service);
    }
    
    widget.onServicesChanged(updatedServices);
  }

  void _removeService(Service service) {
    final updatedServices = List<Service>.from(widget.selectedServices);
    updatedServices.removeWhere((s) => s.id == service.id);
    widget.onServicesChanged(updatedServices);
  }

  String _formatTotalDuration() {
    if (widget.selectedServices.isEmpty) return '0мин';
    
    int totalMinutes = 0;
    for (final service in widget.selectedServices) {
      totalMinutes += service.durationMinutes;
    }
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}ч ${minutes}мин';
    } else if (hours > 0) {
      return '${hours}ч';
    } else {
      return '${minutes}мин';
    }
  }

  String _formatTotalPrice() {
    if (widget.selectedServices.isEmpty) return '0 сум';
    
    double totalPrice = 0;
    for (final service in widget.selectedServices) {
      totalPrice += service.price;
    }
    
    return '${(totalPrice / 1000).toStringAsFixed(0)} тыс. сум';
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
              Icons.design_services_outlined,
              color: Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Услуги не найдены',
            style: AppTheme.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          Text(
            'В этой категории пока нет доступных услуг',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoriesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Категории не найдены',
            style: AppTheme.titleMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Добавьте категории в разделе "Услуги"',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Ошибка загрузки',
            style: AppTheme.titleMedium.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ref.read(simpleServicesProvider.notifier).loadCategories();
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
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
