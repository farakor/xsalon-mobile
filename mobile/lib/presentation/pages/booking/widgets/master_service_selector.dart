import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/service.dart';
import '../../../../data/services/booking_service.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/simple_services_provider.dart';

class MasterServiceSelector extends ConsumerStatefulWidget {
  final List<Service> selectedServices;
  final Function(List<Service>) onServicesChanged;

  const MasterServiceSelector({
    super.key,
    this.selectedServices = const [],
    required this.onServicesChanged,
  });

  @override
  ConsumerState<MasterServiceSelector> createState() => _MasterServiceSelectorState();
}

class _MasterServiceSelectorState extends ConsumerState<MasterServiceSelector> {
  List<Service> _masterServices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMasterServices();
  }

  Future<void> _loadMasterServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Получаем ID текущего мастера
      final bookingService = BookingService();
      final masterId = await bookingService.getCurrentMasterId();
      
      // Загружаем услуги мастера
      await ref.read(simpleServicesProvider.notifier).loadServicesByMaster(masterId);
      final services = ref.read(simpleServicesProvider).services;
      
      setState(() {
        _masterServices = services;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        LucideIcons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Выбрано услуг: ${widget.selectedServices.length}',
                      style: AppTheme.titleSmall.copyWith(
                        color: const Color(0xFF000000),
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
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeService(service),
                          child: const Icon(
                            LucideIcons.x,
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
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Services header
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
                LucideIcons.sparkles,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Ваши услуги',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Services content
        SizedBox(
          height: 400,
          child: _buildServicesContent(),
        ),
      ],
    );
  }

  Widget _buildServicesContent() {
    if (_isLoading) {
      return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    if (_masterServices.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: _masterServices.length,
      itemBuilder: (context, index) {
        final service = _masterServices[index];
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
                          isSelected ? LucideIcons.check : LucideIcons.plus,
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
                            const Icon(LucideIcons.calendarCheck, size: 14, color: Colors.blue),
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
                            const Icon(LucideIcons.dollarSign, size: 14, color: Colors.green),
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
    );
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.scissors,
              color: Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'У вас нет услуг',
            style: AppTheme.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Добавьте услуги в разделе "Услуги"',
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
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
            onPressed: _loadMasterServices,
            child: const Text('Повторить'),
          ),
        ],
      ),
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
}
