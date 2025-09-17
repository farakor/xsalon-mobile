import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Отладочный виджет для проверки загрузки услуг
class DebugServicesLoading extends StatefulWidget {
  const DebugServicesLoading({super.key});

  @override
  State<DebugServicesLoading> createState() => _DebugServicesLoadingState();
}

class _DebugServicesLoadingState extends State<DebugServicesLoading> {
  String _debugOutput = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отладка загрузки услуг'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Отладка проблем с загрузкой услуг',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkOrganizations,
                    child: const Text('1. Проверить организации'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkUserProfile,
                    child: const Text('2. Проверить профиль'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkServices,
                    child: const Text('3. Проверить услуги'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkCategories,
                    child: const Text('4. Проверить категории'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _runFullDiagnostic,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Полная диагностика'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _debugOutput = '';
                });
              },
              child: const Text('Очистить'),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Результаты отладки:',
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
                    _debugOutput.isEmpty ? 'Нажмите кнопки выше для диагностики...' : _debugOutput,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addOutput(String message) {
    setState(() {
      _debugOutput += '$message\n';
    });
  }

  Future<void> _checkOrganizations() async {
    setState(() {
      _isLoading = true;
    });

    _addOutput('=== ПРОВЕРКА ОРГАНИЗАЦИЙ ===');
    
    try {
      final supabase = Supabase.instance.client;
      
      // Проверяем все организации
      final allOrgs = await supabase
          .from('organizations')
          .select('id, name, is_active, created_at');
      
      _addOutput('Всего организаций в БД: ${allOrgs.length}');
      
      if (allOrgs.isNotEmpty) {
        for (final org in allOrgs) {
          _addOutput('  - ${org['name']} (${org['id']}) - ${org['is_active'] ? 'активна' : 'неактивна'}');
        }
      }
      
      // Проверяем активные организации
      final activeOrgs = await supabase
          .from('organizations')
          .select('id, name')
          .eq('is_active', true);
      
      _addOutput('Активных организаций: ${activeOrgs.length}');
      
      if (activeOrgs.isEmpty) {
        _addOutput('⚠️ ПРОБЛЕМА: Нет активных организаций!');
        
        // Пытаемся создать тестовую организацию
        _addOutput('Создаем тестовую организацию...');
        final newOrg = await supabase
            .from('organizations')
            .insert({
              'name': 'XSalon Test Debug',
              'description': 'Тестовая организация для отладки',
              'is_active': true,
            })
            .select('id, name')
            .single();
            
        _addOutput('✅ Создана организация: ${newOrg['name']} (${newOrg['id']})');
      }
      
    } catch (e) {
      _addOutput('❌ Ошибка проверки организаций: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    _addOutput('\n=== ПРОВЕРКА ПРОФИЛЯ ПОЛЬЗОВАТЕЛЯ ===');
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      _addOutput('Текущий пользователь: ${user?.id ?? 'не авторизован'}');
      
      if (user != null) {
        // Проверяем профиль пользователя
        final profile = await supabase
            .from('user_profiles')
            .select('id, full_name, role')
            .eq('id', user.id)
            .maybeSingle();
        
        if (profile != null) {
          _addOutput('Профиль найден:');
          _addOutput('  - Имя: ${profile['full_name'] ?? 'не указано'}');
          _addOutput('  - Роль: ${profile['role'] ?? 'не указана'}');
          _addOutput('  - Организация: XSalon (единая система)');
          
          // Организация больше не требуется - единая система
          if (false) {
            _addOutput('⚠️ ПРОБЛЕМА: У пользователя нет привязки к организации!');
          }
        } else {
          _addOutput('⚠️ ПРОБЛЕМА: Профиль пользователя не найден!');
          
          // Создаем профиль
          _addOutput('Создаем профиль пользователя...');
          await supabase
              .from('user_profiles')
              .insert({
                'id': user.id,
                'full_name': 'Тестовый пользователь',
                'role': 'client',
              });
          _addOutput('✅ Профиль создан');
        }
      }
      
    } catch (e) {
      _addOutput('❌ Ошибка проверки профиля: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkServices() async {
    setState(() {
      _isLoading = true;
    });

    _addOutput('\n=== ПРОВЕРКА УСЛУГ ===');
    
    try {
      final supabase = Supabase.instance.client;
      
      // Проверяем все услуги
      final allServices = await supabase
          .from('services')
          .select('id, name, category_id, is_active, price, duration_minutes');
      
      _addOutput('Всего услуг в БД: ${allServices.length}');
      
      if (allServices.isNotEmpty) {
        // Все услуги теперь в единой системе
        _addOutput('Услуги в системе XSalon:');
        for (final service in allServices) {
          _addOutput('  - ${service['name']} (${service['is_active'] ? 'активна' : 'неактивна'}) - ${service['price']}₽, ${service['duration_minutes']}мин');
        }
      } else {
        _addOutput('⚠️ ПРОБЛЕМА: В БД нет услуг!');
      }
      
      // Проверяем активные услуги
      final activeServices = await supabase
          .from('services')
          .select('id, name')
          .eq('is_active', true);
      
      _addOutput('Активных услуг: ${activeServices.length}');
      
    } catch (e) {
      _addOutput('❌ Ошибка проверки услуг: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkCategories() async {
    setState(() {
      _isLoading = true;
    });

    _addOutput('\n=== ПРОВЕРКА КАТЕГОРИЙ ===');
    
    try {
      final supabase = Supabase.instance.client;
      
      // Проверяем все категории
      final allCategories = await supabase
          .from('service_categories')
          .select('id, name, is_active');
      
      _addOutput('Всего категорий в БД: ${allCategories.length}');
      
      if (allCategories.isNotEmpty) {
        for (final category in allCategories) {
          _addOutput('  - ${category['name']} (${category['id']}) - ${category['is_active'] ? 'активна' : 'неактивна'}');
        }
      } else {
        _addOutput('⚠️ ПРОБЛЕМА: В БД нет категорий услуг!');
      }
      
      // Проверяем связь услуг и категорий
      final servicesWithCategories = await supabase
          .from('services')
          .select('''
            id,
            name,
            category_id,
            service_categories!inner(
              id,
              name
            )
          ''')
          .eq('is_active', true)
          .limit(5);
      
      _addOutput('Услуги с категориями (первые 5):');
      for (final service in servicesWithCategories) {
        _addOutput('  - ${service['name']} → ${service['service_categories']['name']}');
      }
      
    } catch (e) {
      _addOutput('❌ Ошибка проверки категорий: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _runFullDiagnostic() async {
    setState(() {
      _debugOutput = '';
    });
    
    await _checkOrganizations();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _checkUserProfile();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _checkCategories();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _checkServices();
    
    _addOutput('\n=== ИТОГИ ДИАГНОСТИКИ ===');
    _addOutput('Диагностика завершена. Проверьте результаты выше.');
    _addOutput('Если есть проблемы, исправьте их в БД и повторите тест.');
  }
}
