import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/service.dart';
import '../../../data/services/booking_service.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_theme.dart';

class AddServicePage extends ConsumerStatefulWidget {
  final ServiceEntity? service;

  const AddServicePage({
    super.key,
    this.service,
  });

  @override
  ConsumerState<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends ConsumerState<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  String? _selectedCategoryId;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Загружаем категории
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesProvider.notifier).loadCategories();
    });

    // Если редактируем существующую услугу, заполняем поля
    if (widget.service != null) {
      final service = widget.service!;
      _nameController.text = service.name;
      _descriptionController.text = service.description;
      _priceController.text = service.price.toStringAsFixed(0);
      _durationController.text = service.durationMinutes.toString();
      // В новой архитектуре услуги не привязаны к категориям
      // _selectedCategoryId = service.categoryId;
      _isActive = service.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(serviceCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service != null ? 'Редактировать услугу' : 'Новая услуга'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveService,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Сохранить'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Название услуги
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название услуги *',
                hintText: 'Введите название услуги',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название услуги';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Описание
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                hintText: 'Введите описание услуги',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Категория
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Категория *',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Выберите категорию';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Цена и длительность в одном ряду
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Цена (сум) *',
                      hintText: '50000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите цену';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Введите корректную цену';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Длительность (мин) *',
                      hintText: '60',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите длительность';
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration <= 0) {
                        return 'Введите корректную длительность';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Статус активности
            Card(
              child: SwitchListTile(
                title: const Text('Активная услуга'),
                subtitle: Text(
                  _isActive 
                      ? 'Услуга доступна для записи' 
                      : 'Услуга скрыта от клиентов',
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // Кнопки действий
            if (widget.service != null) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveService,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _saveService,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Создать услугу'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите категорию')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Получаем ID текущего мастера
      final bookingService = BookingService();
      final masterId = await bookingService.getCurrentMasterId();

      final service = ServiceEntity(
        id: widget.service?.id ?? const Uuid().v4(),
        masterId: masterId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        durationMinutes: int.parse(_durationController.text),
        preparationTimeMinutes: 5,
        cleanupTimeMinutes: 5,
        isActive: _isActive,
        createdAt: widget.service?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.service != null) {
        await ref.read(servicesProvider.notifier).updateService(service);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Услуга обновлена')),
          );
        }
      } else {
        await ref.read(servicesProvider.notifier).addService(service);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Услуга создана')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
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
}
