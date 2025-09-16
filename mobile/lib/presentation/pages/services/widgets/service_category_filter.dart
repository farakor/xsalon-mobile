import 'package:flutter/material.dart';
import '../../../../domain/entities/service.dart';
import '../../../theme/app_theme.dart';

class ServiceCategoryFilter extends StatelessWidget {
  final List<ServiceCategoryEntity> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const ServiceCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Кнопка "Все"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onCategorySelected(null),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selectedCategoryId == null 
                      ? AppTheme.primaryColor 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedCategoryId == null 
                        ? AppTheme.primaryColor 
                        : AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Все',
                  style: AppTheme.bodyMedium.copyWith(
                    color: selectedCategoryId == null 
                        ? Colors.white 
                        : AppTheme.textSecondaryColor,
                    fontWeight: selectedCategoryId == null 
                        ? FontWeight.w500 
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          // Категории
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (selectedCategoryId == category.id) {
                  onCategorySelected(null);
                } else {
                  onCategorySelected(category.id);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selectedCategoryId == category.id 
                      ? AppTheme.primaryColor 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedCategoryId == category.id 
                        ? AppTheme.primaryColor 
                        : AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  category.name,
                  style: AppTheme.bodyMedium.copyWith(
                    color: selectedCategoryId == category.id 
                        ? Colors.white 
                        : AppTheme.textSecondaryColor,
                    fontWeight: selectedCategoryId == category.id 
                        ? FontWeight.w500 
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
