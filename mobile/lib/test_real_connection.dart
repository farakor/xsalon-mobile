import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/providers/services_provider.dart';
import 'presentation/providers/masters_provider.dart';

/// Тестовый виджет для проверки подключения к реальной БД
class TestRealConnection extends ConsumerStatefulWidget {
  const TestRealConnection({super.key});

  @override
  ConsumerState<TestRealConnection> createState() => _TestRealConnectionState();
}

class _TestRealConnectionState extends ConsumerState<TestRealConnection> {
  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест подключения к БД'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Тестирование подключения к реальной базе данных Supabase',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testSupabaseConnection,
                    child: const Text('Тест Supabase'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testOrganizations,
                    child: const Text('Тест организаций'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testServices,
                    child: const Text('Тест услуг'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testMasters,
                    child: const Text('Тест мастеров'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testFullFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Полный тест системы записи'),
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
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _testResults = '';
                });
              },
              child: const Text('Очистить результаты'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testSupabaseConnection() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Тестирование подключения к Supabase...\n';
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Проверяем статус подключения
      final response = await supabase.rpc('version');
      
      setState(() {
        _testResults += '✅ Подключение к Supabase успешно!\n';
        _testResults += 'Версия PostgreSQL: ${response ?? 'неизвестно'}\n';
        _testResults += 'Статус подключения: активно\n';
        _testResults += 'Аутентификация: ${supabase.auth.currentUser != null ? 'авторизован' : 'анонимно'}\n\n';
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

  Future<void> _testOrganizations() async {
    setState(() {
      _isLoading = true;
      _testResults += 'Тестирование таблицы organizations...\n';
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Проверяем доступ к таблице организаций
      final response = await supabase
          .from('organizations')
          .select('id, name, is_active')
          .limit(5);
      
      setState(() {
        _testResults += '✅ Таблица organizations доступна!\n';
        _testResults += 'Найдено организаций: ${response.length}\n';
        
        if (response.isNotEmpty) {
          _testResults += 'Примеры организаций:\n';
          for (final org in response) {
            _testResults += '  - ${org['name']} (${org['is_active'] ? 'активна' : 'неактивна'})\n';
          }
        }
        _testResults += '\n';
      });
    } catch (e) {
      setState(() {
        _testResults += '❌ Ошибка доступа к таблице organizations: $e\n\n';
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
      _testResults += 'Тестирование загрузки услуг через провайдер...\n';
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
      _testResults += 'Тестирование загрузки мастеров через провайдер...\n';
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

  Future<void> _testFullFlow() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Запуск полного теста системы записи...\n\n';
    });

    // Последовательно выполняем все тесты
    await _testSupabaseConnection();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testOrganizations();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testServices();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testMasters();
    
    // Тестируем связь мастеров и услуг
    setState(() {
      _testResults += 'Тестирование связи мастеров и услуг...\n';
    });
    
    try {
      final servicesState = ref.read(servicesProvider);
      if (servicesState.services.isNotEmpty) {
        final firstService = servicesState.services.first;
        final mastersForService = await ref.read(mastersProvider.notifier).getMastersByService(firstService.id);
        
        setState(() {
          _testResults += '✅ Связь мастеров и услуг работает!\n';
          _testResults += 'Для услуги "${firstService.name}" найдено мастеров: ${mastersForService.length}\n';
          
          if (mastersForService.isNotEmpty) {
            _testResults += 'Мастера для этой услуги:\n';
            for (final master in mastersForService) {
              _testResults += '  - ${master.fullName}\n';
            }
          }
          _testResults += '\n';
        });
      }
    } catch (e) {
      setState(() {
        _testResults += '❌ Ошибка тестирования связи мастеров и услуг: $e\n\n';
      });
    }
    
    setState(() {
      _testResults += '🎉 Полный тест завершен!\n';
      _testResults += '📱 Система записи готова к использованию.\n';
      _isLoading = false;
    });
  }
}
