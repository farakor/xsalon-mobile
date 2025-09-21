import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class ModernFloatingMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final List<ModernMenuBarItem> items;
  final EdgeInsets margin;
  final double height;

  const ModernFloatingMenu({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.items,
    this.margin = const EdgeInsets.all(16),
    this.height = 80,
  });

  @override
  State<ModernFloatingMenu> createState() => _ModernFloatingMenuState();
}

class _ModernFloatingMenuState extends State<ModernFloatingMenu>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Запускаем анимации
    _slideController.forward();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: widget.margin,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Фоновый индикатор
                  _BackgroundIndicator(
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
                        child: _ModernMenuButton(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => widget.onIndexChanged(index),
                          animationController: _animationController,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundIndicator extends StatefulWidget {
  final int selectedIndex;
  final int itemCount;

  const _BackgroundIndicator({
    required this.selectedIndex,
    required this.itemCount,
  });

  @override
  State<_BackgroundIndicator> createState() => _BackgroundIndicatorState();
}

class _BackgroundIndicatorState extends State<_BackgroundIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _previousIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(_BackgroundIndicator oldWidget) {
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
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final currentPosition = _previousIndex + (widget.selectedIndex - _previousIndex) * progress;
        
        return Positioned(
          left: (currentPosition / widget.itemCount) * MediaQuery.of(context).size.width,
          top: 8,
          bottom: 8,
          child: Container(
            width: (MediaQuery.of(context).size.width - 32) / widget.itemCount - 8,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
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

class _ModernMenuButton extends StatefulWidget {
  final ModernMenuBarItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final AnimationController animationController;

  const _ModernMenuButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.animationController,
  });

  @override
  State<_ModernMenuButton> createState() => _ModernMenuButtonState();
}

class _ModernMenuButtonState extends State<_ModernMenuButton>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _selectionController;
  late Animation<double> _tapAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOut,
    ));

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(_ModernMenuButton oldWidget) {
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
        animation: Listenable.merge([
          _tapController,
          _selectionController,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _tapAnimation.value,
            child: Container(
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Иконка с анимацией и эффектами
                  Transform.scale(
                    scale: _iconScaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                        color: widget.isSelected 
                            ? Colors.white 
                            : AppTheme.textSecondaryColor,
                        size: 26,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Текст с анимацией прозрачности
                  AnimatedBuilder(
                    animation: _textOpacityAnimation,
                    child: Text(
                      widget.item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.labelSmall.copyWith(
                        color: widget.isSelected 
                            ? Colors.white 
                            : AppTheme.textSecondaryColor,
                        fontWeight: widget.isSelected 
                            ? FontWeight.w600 
                            : FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    builder: (context, child) {
                      return Opacity(
                        opacity: widget.isSelected 
                            ? _textOpacityAnimation.value 
                            : 0.7,
                        child: child,
                      );
                    },
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

class ModernMenuBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ModernMenuBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
