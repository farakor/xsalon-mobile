import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/providers/services_provider.dart';
import 'presentation/providers/masters_provider.dart';

/// Тестовый виджет для проверки работы системы записи
class TestBookingFlow extends ConsumerStatefulWidget {
  const TestBookingFlow({super.key});

  @override
  ConsumerState<TestBookingFlow> createState() => _TestBookingFlowState();
}

class _TestBookingFlowState extends ConsumerState<TestBookingFlow> {
  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест системы записи'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Тестирование подключения к базе данных',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Тестировать подключение'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testServices,
              child: const Text('Загрузить услуги'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testMasters,
              child: const Text('Загрузить мастеров'),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Результаты тестов:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'Нажмите кнопки выше для тестирования...' : _testResults,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Тестирование подключения к Supabase...\n';
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Проверяем подключение, делая простой запрос
      final response = await supabase
          .from('organizations')
          .select('id, name')
          .limit(1);
      
      setState(() {
        _testResults += '✅ Подключение к Supabase успешно!\n';
        _testResults += 'Найдено организаций: ${response.length}\n';
        if (response.isNotEmpty) {
          _testResults += 'Первая организация: ${response[0]['name']}\n';
        }
        _testResults += '\n';
      });
    } catch (e) {
      setState(() {
        _testResults += '❌ Ошибка подключения к Supabase: $e\n\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testServices() async {
    setState(() {
      _isLoading = true;
      _testResults += 'Загрузка услуг...\n';
    });

    try {
      await ref.read(servicesProvider.notifier).loadActiveServices();
      
      final servicesState = ref.read(servicesProvider);
      
      if (servicesState.status == ServicesStatus.loaded) {
        setState(() {
          _testResults += '✅ Услуги загружены успешно!\n';
          _testResults += 'Количество активных услуг: ${servicesState.services.length}\n';
          
          if (servicesState.services.isNotEmpty) {
            _testResults += 'Примеры услуг:\n';
            for (int i = 0; i < servicesState.services.take(3).length; i++) {
              final service = servicesState.services[i];
              _testResults += '  - ${service.name} (${service.formattedPrice}, ${service.formattedDuration})\n';
            }
          }
          _testResults += '\n';
        });
      } else if (servicesState.status == ServicesStatus.error) {
        setState(() {
          _testResults += '❌ Ошибка загрузки услуг: ${servicesState.errorMessage}\n\n';
        });
      }
    } catch (e) {
      setState(() {
        _testResults += '❌ Исключение при загрузке услуг: $e\n\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testMasters() async {
    setState(() {
      _isLoading = true;
      _testResults += 'Загрузка мастеров...\n';
    });

    try {
      await ref.read(mastersProvider.notifier).loadActiveMasters();
      
      final mastersState = ref.read(mastersProvider);
      
      if (mastersState.status == MastersStatus.loaded) {
        setState(() {
          _testResults += '✅ Мастера загружены успешно!\n';
          _testResults += 'Количество активных мастеров: ${mastersState.masters.length}\n';
          
          if (mastersState.masters.isNotEmpty) {
            _testResults += 'Примеры мастеров:\n';
            for (int i = 0; i < mastersState.masters.take(3).length; i++) {
              final master = mastersState.masters[i];
              _testResults += '  - ${master.fullName} (рейтинг: ${master.formattedRating}, опыт: ${master.formattedExperience})\n';
            }
          }
          _testResults += '\n';
        });
      } else if (mastersState.status == MastersStatus.error) {
        setState(() {
          _testResults += '❌ Ошибка загрузки мастеров: ${mastersState.errorMessage}\n\n';
        });
      }
    } catch (e) {
      setState(() {
        _testResults += '❌ Исключение при загрузке мастеров: $e\n\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
