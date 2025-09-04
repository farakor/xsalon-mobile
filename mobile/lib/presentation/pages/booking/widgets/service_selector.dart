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
    // Если есть выбранные услуги, устанавливаем первую категорию
    if (widget.selectedServices.isNotEmpty) {
      _selectedCategoryId = widget.selectedServices.first.categoryId;
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
        
        // Categories
        Text(
          'Выберите категорию услуг',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Выберите услугу',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: isSelected ? 4 : 1,
                        child: ListTile(
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
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                              : const Icon(Icons.chevron_right),
                          selected: isSelected,
                          selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                          onTap: () => _toggleService(service),
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
