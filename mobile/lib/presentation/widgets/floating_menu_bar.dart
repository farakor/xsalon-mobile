import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class FloatingMenuBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final List<FloatingMenuBarItem> items;
  final EdgeInsets margin;
  final double height;
  final double borderRadius;

  const FloatingMenuBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.items,
    this.margin = const EdgeInsets.all(16),
    this.height = 70,
    this.borderRadius = 35,
  });

  @override
  State<FloatingMenuBar> createState() => _FloatingMenuBarState();
}

class _FloatingMenuBarState extends State<FloatingMenuBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _slideAnimation = Tween<double>(
      begin: 10,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Row(
                  children: widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == widget.selectedIndex;

                    return Expanded(
                      child: _FloatingMenuBarButton(
                        item: item,
                        isSelected: isSelected,
                        onTap: () => widget.onIndexChanged(index),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingMenuBarButton extends StatefulWidget {
  final FloatingMenuBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _FloatingMenuBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FloatingMenuBarButton> createState() => _FloatingMenuBarButtonState();
}

class _FloatingMenuBarButtonState extends State<_FloatingMenuBarButton>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _selectionController;
  late Animation<double> _tapAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    _selectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOutBack,
    ));

    _colorAnimation = ColorTween(
      begin: AppTheme.textSecondaryColor,
      end: Colors.white,
    ).animate(_selectionController);

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(_FloatingMenuBarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _tapController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _tapController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_tapController, _selectionController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _tapAnimation.value,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.8),
                          AppTheme.secondaryColor.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Иконка с анимацией
                  Transform.scale(
                    scale: 1.0 + (_selectionAnimation.value * 0.1),
                    child: Icon(
                      widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                      color: widget.isSelected 
                          ? Colors.white 
                          : AppTheme.textSecondaryColor,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Текст с анимацией
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTheme.labelSmall.copyWith(
                      color: widget.isSelected 
                          ? Colors.white 
                          : AppTheme.textSecondaryColor,
                      fontWeight: widget.isSelected 
                          ? FontWeight.w600 
                          : FontWeight.w500,
                    ),
                    child: Text(
                      widget.item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FloatingMenuBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FloatingMenuBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
