import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_theme.dart';

class SettingsSection extends StatefulWidget {
  const SettingsSection({super.key});

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _darkMode = false;
  String _language = 'Русский';
  String _currency = 'UZS';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          // Notifications Settings
          _buildNotificationSettings(),
          const SizedBox(height: 16),
          // Appearance Settings
          _buildAppearanceSettings(),
          const SizedBox(height: 16),
          // Language and Region
          _buildLanguageSettings(),
          const SizedBox(height: 16),
          // Privacy Settings
          _buildPrivacySettings(),
          const SizedBox(height: 16),
          // Account Settings
          _buildAccountSettings(),
          const SizedBox(height: 16),
          // Support and Info
          _buildSupportSettings(),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsCard(
      'Уведомления',
      LucideIcons.bell,
      [
        _buildSwitchTile(
          'Включить уведомления',
          'Получать push-уведомления',
          _notificationsEnabled,
          (value) => setState(() => _notificationsEnabled = value),
        ),
        if (_notificationsEnabled) ...[
          _buildSwitchTile(
            'Звук',
            'Звуковые уведомления',
            _soundEnabled,
            (value) => setState(() => _soundEnabled = value),
          ),
          _buildSwitchTile(
            'Вибрация',
            'Вибрация при уведомлениях',
            _vibrationEnabled,
            (value) => setState(() => _vibrationEnabled = value),
          ),
          _buildSwitchTile(
            'Email уведомления',
            'Получать уведомления на почту',
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
          _buildSwitchTile(
            'SMS уведомления',
            'Получать SMS о записях',
            _smsNotifications,
            (value) => setState(() => _smsNotifications = value),
          ),
        ],
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return _buildSettingsCard(
      'Внешний вид',
      Icons.palette,
      [
        _buildSwitchTile(
          'Темная тема',
          'Использовать темное оформление',
          _darkMode,
          (value) => setState(() => _darkMode = value),
        ),
        _buildListTile(
          'Размер шрифта',
          'Средний',
          Icons.text_fields,
          () => _showFontSizeDialog(),
        ),
        _buildListTile(
          'Цветовая схема',
          'По умолчанию',
          Icons.color_lens,
          () => _showColorSchemeDialog(),
        ),
      ],
    );
  }

  Widget _buildLanguageSettings() {
    return _buildSettingsCard(
      'Язык и регион',
      Icons.language,
      [
        _buildListTile(
          'Язык',
          _language,
          Icons.translate,
          () => _showLanguageDialog(),
        ),
        _buildListTile(
          'Валюта',
          _currency,
          LucideIcons.dollarSign,
          () => _showCurrencyDialog(),
        ),
        _buildListTile(
          'Часовой пояс',
          'UTC+5 (Ташкент)',
          LucideIcons.calendarCheck,
          () => _showTimezoneDialog(),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSettingsCard(
      'Приватность и безопасность',
      Icons.security,
      [
        _buildListTile(
          'Сменить пароль',
          'Последнее изменение: 30 дней назад',
          LucideIcons.lock,
          () => _changePassword(),
        ),
        _buildListTile(
          'Двухфакторная аутентификация',
          'Отключена',
          Icons.security,
          () => _setup2FA(),
        ),
        _buildListTile(
          'Активные сессии',
          'Управление устройствами',
          Icons.devices,
          () => _showActiveSessions(),
        ),
        _buildListTile(
          'Конфиденциальность данных',
          'Настройки приватности',
          Icons.privacy_tip,
          () => _showPrivacySettings(),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return _buildSettingsCard(
      'Аккаунт',
      Icons.account_circle,
      [
        _buildListTile(
          'Экспорт данных',
          'Скачать копию ваших данных',
          LucideIcons.download,
          () => _exportData(),
        ),
        _buildListTile(
          'Синхронизация',
          'Последняя: только что',
          Icons.sync,
          () => _syncData(),
        ),
        _buildListTile(
          'Резервное копирование',
          'Автоматическое сохранение',
          Icons.backup,
          () => _showBackupSettings(),
        ),
      ],
    );
  }

  Widget _buildSupportSettings() {
    return _buildSettingsCard(
      'Поддержка и информация',
      Icons.help,
      [
        _buildListTile(
          'Справка',
          'Часто задаваемые вопросы',
          LucideIcons.helpCircle,
          () => _showHelp(),
        ),
        _buildListTile(
          'Обратная связь',
          'Отправить отзыв',
          Icons.feedback,
          () => _sendFeedback(),
        ),
        _buildListTile(
          'О приложении',
          'Версия 1.0.0',
          LucideIcons.info,
          () => _showAbout(),
        ),
        _buildListTile(
          'Условия использования',
          'Правила и политика',
          Icons.description,
          () => _showTerms(),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(String title, IconData icon, List<Widget> children) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: AppTheme.textSecondaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Размер шрифта'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Маленький'),
              value: 'small',
              groupValue: 'medium',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Средний'),
              value: 'medium',
              groupValue: 'medium',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Большой'),
              value: 'large',
              groupValue: 'medium',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorSchemeDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выбор цветовой схемы - в разработке')),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Русский'),
              value: 'Русский',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('O\'zbekcha'),
              value: 'O\'zbekcha',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите валюту'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('UZS (Сум)'),
              value: 'UZS',
              groupValue: _currency,
              onChanged: (value) {
                setState(() => _currency = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('USD (Доллар)'),
              value: 'USD',
              groupValue: _currency,
              onChanged: (value) {
                setState(() => _currency = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('RUB (Рубль)'),
              value: 'RUB',
              groupValue: _currency,
              onChanged: (value) {
                setState(() => _currency = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimezoneDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выбор часового пояса - в разработке')),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Смена пароля - в разработке')),
    );
  }

  void _setup2FA() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройка 2FA - в разработке')),
    );
  }

  void _showActiveSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Активные сессии - в разработке')),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки приватности - в разработке')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Экспорт данных - в разработке')),
    );
  }

  void _syncData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Синхронизация выполнена')),
    );
  }

  void _showBackupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки резервного копирования - в разработке')),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Справка - в разработке')),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отправка отзыва - в разработке')),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('XSalon - приложение для управления салоном красоты'),
            SizedBox(height: 8),
            Text('Версия: 1.0.0'),
            Text('Разработчик: XSalon Team'),
            Text('© 2024 XSalon. Все права защищены.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Условия использования - в разработке')),
    );
  }
}
