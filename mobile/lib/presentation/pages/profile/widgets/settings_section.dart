import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.all(16),
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
      Icons.notifications,
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
          Icons.attach_money,
          () => _showCurrencyDialog(),
        ),
        _buildListTile(
          'Часовой пояс',
          'UTC+5 (Ташкент)',
          Icons.schedule,
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
          Icons.lock,
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
          Icons.download,
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
          Icons.help_outline,
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
          Icons.info,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
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
    return ListTile(
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
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
