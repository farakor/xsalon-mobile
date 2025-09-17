import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/services_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/modern_app_header.dart';
import 'widgets/service_card.dart';
import 'widgets/service_category_filter.dart';
import 'add_service_page.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Загружаем услуги текущего мастера при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesProvider.notifier).loadServicesForCurrentMaster();
      ref.read(servicesProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);
    final services = ref.watch(servicesListProvider);
    final categories = ref.watch(serviceCategoriesProvider);
    final isLoading = ref.watch(isServicesLoadingProvider);

    // Фильтруем услуги
    var filteredServices = services;
    
    // В новой архитектуре услуги не привязаны к категориям
    // Фильтрация по категориям больше не поддерживается
    // if (_selectedCategoryId != null) {
    //   filteredServices = filteredServices
    //       .where((service) => service.categoryId == _selectedCategoryId)
    //       .toList();
    // }
    
    if (_searchQuery.isNotEmpty) {
      filteredServices = filteredServices
          .where((service) =>
              service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              service.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: ModernAppHeader(
        title: 'Услуги',
        subtitle: 'Управление услугами салона',
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск услуг...',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.textSecondaryColor,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                
                // Category Filter
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ServiceCategoryFilter(
                    categories: categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (categoryId) {
                      setState(() {
                        _selectedCategoryId = categoryId;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          
          // Services List
          Expanded(
            child: _buildServicesList(
              isLoading: isLoading,
              services: filteredServices,
              error: servicesState.errorMessage,
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddServicePage(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesList({
    required bool isLoading,
    required List services,
    String? error,
  }) {
    if (isLoading && services.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки услуг',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(servicesProvider.notifier).loadServicesForCurrentMaster();
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (services.isEmpty) {
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
                  Icons.design_services_outlined,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _searchQuery.isNotEmpty || _selectedCategoryId != null
                    ? 'Услуги не найдены'
                    : 'Нет услуг',
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty || _selectedCategoryId != null
                    ? 'Попробуйте изменить параметры поиска'
                    : 'Добавьте первую услугу',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (_searchQuery.isEmpty && _selectedCategoryId == null) ...[
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddServicePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Добавить услугу',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(servicesProvider.notifier).loadServicesForCurrentMaster();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ServiceCard(
            service: service,
            onTap: () {
              // Переход к деталям услуги
              _showServiceDetails(context, service);
            },
            onEdit: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddServicePage(service: service),
                ),
              );
            },
            onDelete: () {
              _showDeleteConfirmation(context, service);
            },
          );
        },
      ),
    );
  }

  void _showServiceDetails(BuildContext context, service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                service.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Услуга мастера', // В новой архитектуре нет категорий
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Цена',
                      service.formattedPrice,
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Длительность',
                      service.formattedDuration,
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Описание',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                service.description.isNotEmpty 
                    ? service.description 
                    : 'Описание не указано',
                style: TextStyle(
                  color: service.description.isNotEmpty 
                      ? null 
                      : AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddServicePage(service: service),
                          ),
                        );
                      },
                      child: const Text('Редактировать'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDeleteConfirmation(context, service);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Удалить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить услугу?'),
        content: Text('Вы уверены, что хотите удалить услугу "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(servicesProvider.notifier).deleteService(service.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Услуга удалена')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка удаления: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
