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
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Кнопка "Все"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Все'),
              selected: selectedCategoryId == null,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(null);
                }
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          ),
          // Категории
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category.name),
              selected: selectedCategoryId == category.id,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category.id);
                } else {
                  onCategorySelected(null);
                }
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          )),
        ],
      ),
    );
  }
}
