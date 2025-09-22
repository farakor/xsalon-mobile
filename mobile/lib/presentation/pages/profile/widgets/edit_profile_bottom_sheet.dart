import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../data/models/user_profile.dart';
import '../../../theme/app_theme.dart';

class EditProfileBottomSheet extends ConsumerStatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onProfileUpdated;

  const EditProfileBottomSheet({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  ConsumerState<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends ConsumerState<EditProfileBottomSheet> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Мужской', 'Женский'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.userProfile.fullName);
    _phoneController = TextEditingController(text: widget.userProfile.phone);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _selectedDateOfBirth = widget.userProfile.dateOfBirth;
    _selectedGender = widget.userProfile.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.edit,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Редактировать профиль',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      Text(
                        'Обновите свои личные данные',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    LucideIcons.x,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Полное имя',
                    icon: LucideIcons.user,
                    hintText: 'Введите ваше имя',
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Телефон',
                    icon: LucideIcons.phone,
                    hintText: '+998 90 123 45 67',
                    keyboardType: TextInputType.phone,
                    enabled: false, // Телефон нельзя изменить
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: LucideIcons.mail,
                    hintText: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  // Date of Birth
                  _buildDateField(),
                  const SizedBox(height: 16),
                  
                  // Gender
                  _buildGenderField(),
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Сохранить изменения',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  
                  // Bottom padding for keyboard
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            style: AppTheme.bodyMedium.copyWith(
              color: enabled ? AppTheme.textPrimaryColor : AppTheme.textSecondaryColor,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Дата рождения',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 0.5,
            ),
          ),
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      LucideIcons.cake,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _selectedDateOfBirth != null
                          ? _formatDate(_selectedDateOfBirth!)
                          : 'Выберите дату рождения',
                      style: AppTheme.bodyMedium.copyWith(
                        color: _selectedDateOfBirth != null
                            ? AppTheme.textPrimaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  Icon(
                    LucideIcons.calendar,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Пол',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 0.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              hintText: 'Выберите пол',
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  LucideIcons.user,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: _genderOptions.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(
                  gender,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите ваше имя'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProfile = widget.userProfile.copyWith(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        dateOfBirth: _selectedDateOfBirth,
        gender: _selectedGender,
        updatedAt: DateTime.now(),
      );

      await widget.onProfileUpdated(updatedProfile);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления профиля: $error'),
            backgroundColor: Colors.red,
          ),
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

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
