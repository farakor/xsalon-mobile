import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class SimpleFloatingMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final List<SimpleMenuBarItem> items;
  final EdgeInsets margin;
  final double height;

  const SimpleFloatingMenu({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.items,
    this.margin = const EdgeInsets.fromLTRB(16, 16, 16, 32),
    this.height = 60,
  });

  @override
  State<SimpleFloatingMenu> createState() => _SimpleFloatingMenuState();
}

class _SimpleFloatingMenuState extends State<SimpleFloatingMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Анимированный индикатор выбора
          _AnimatedSelectionIndicator(
            selectedIndex: widget.selectedIndex,
            itemCount: widget.items.length,
          ),
          
          // Кнопки меню
          Row(
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.selectedIndex;

              return Expanded(
                child: _SimpleMenuButton(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => widget.onIndexChanged(index),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSelectionIndicator extends StatefulWidget {
  final int selectedIndex;
  final int itemCount;

  const _AnimatedSelectionIndicator({
    required this.selectedIndex,
    required this.itemCount,
  });

  @override
  State<_AnimatedSelectionIndicator> createState() => _AnimatedSelectionIndicatorState();
}

class _AnimatedSelectionIndicatorState extends State<_AnimatedSelectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    
    _previousIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(_AnimatedSelectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        final progress = _slideAnimation.value;
        final screenWidth = MediaQuery.of(context).size.width - 32; // учитываем margin
        final itemWidth = screenWidth / widget.itemCount;
        final currentPosition = _previousIndex + (widget.selectedIndex - _previousIndex) * progress;
        
        return Positioned(
          left: (currentPosition * itemWidth) + 6,
          top: 6,
          bottom: 6,
          child: Container(
            width: itemWidth - 12,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(29),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SimpleMenuButton extends StatefulWidget {
  final SimpleMenuBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SimpleMenuButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SimpleMenuButton> createState() => _SimpleMenuButtonState();
}

class _SimpleMenuButtonState extends State<_SimpleMenuButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: double.infinity,
        child: Center(
          child: Icon(
            widget.isSelected ? widget.item.activeIcon : widget.item.icon,
            color: widget.isSelected 
                ? Colors.black 
                : AppTheme.textSecondaryColor,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class SimpleMenuBarItem {
  final IconData icon;
  final IconData activeIcon;

  const SimpleMenuBarItem({
    required this.icon,
    required this.activeIcon,
  });
}
