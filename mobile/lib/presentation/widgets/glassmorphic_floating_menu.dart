import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class GlassmorphicFloatingMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final List<GlassMenuBarItem> items;
  final EdgeInsets margin;
  final double height;

  const GlassmorphicFloatingMenu({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.items,
    this.margin = const EdgeInsets.all(16),
    this.height = 75,
  });

  @override
  State<GlassmorphicFloatingMenu> createState() => _GlassmorphicFloatingMenuState();
}

class _GlassmorphicFloatingMenuState extends State<GlassmorphicFloatingMenu>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _selectionController;
  late Animation<double> _entranceAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _entranceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    ));

    // Запускаем анимацию входа
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _entranceAnimation,
        child: Container(
          margin: widget.margin,
          height: widget.height,
          child: Stack(
            children: [
              // Glassmorphic background
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Selection indicator
              _GlassSelectionIndicator(
                selectedIndex: widget.selectedIndex,
                itemCount: widget.items.length,
              ),
              
              // Menu items
              Row(
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == widget.selectedIndex;

                  return Expanded(
                    child: _GlassMenuButton(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => widget.onIndexChanged(index),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassSelectionIndicator extends StatefulWidget {
  final int selectedIndex;
  final int itemCount;

  const _GlassSelectionIndicator({
    required this.selectedIndex,
    required this.itemCount,
  });

  @override
  State<_GlassSelectionIndicator> createState() => _GlassSelectionIndicatorState();
}

class _GlassSelectionIndicatorState extends State<_GlassSelectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _previousIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(_GlassSelectionIndicator oldWidget) {
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
      animation: _controller,
      builder: (context, child) {
        final progress = _slideAnimation.value;
        final scale = _scaleAnimation.value;
        final screenWidth = MediaQuery.of(context).size.width - 32; // учитываем margin
        final itemWidth = screenWidth / widget.itemCount;
        final currentPosition = _previousIndex + (widget.selectedIndex - _previousIndex) * progress;
        
        return Positioned(
          left: (currentPosition * itemWidth) + 8,
          top: 8,
          bottom: 8,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: itemWidth - 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.9),
                    AppTheme.secondaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassMenuButton extends StatefulWidget {
  final GlassMenuBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlassMenuButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_GlassMenuButton> createState() => _GlassMenuButtonState();
}

class _GlassMenuButtonState extends State<_GlassMenuButton>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _selectionController;
  late Animation<double> _tapAnimation;
  late Animation<double> _iconBounceAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    _iconBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));

    _textFadeAnimation = Tween<double>(
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
  void didUpdateWidget(_GlassMenuButton oldWidget) {
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
                  // Иконка с bounce эффектом
                  Transform.scale(
                    scale: _iconBounceAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                        color: widget.isSelected 
                            ? Colors.white 
                            : Colors.black.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Текст с fade эффектом
                  AnimatedBuilder(
                    animation: _textFadeAnimation,
                    child: Text(
                      widget.item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.labelSmall.copyWith(
                        color: widget.isSelected 
                            ? Colors.white 
                            : Colors.black.withOpacity(0.7),
                        fontWeight: widget.isSelected 
                            ? FontWeight.w700 
                            : FontWeight.w500,
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                    builder: (context, child) {
                      return Opacity(
                        opacity: widget.isSelected 
                            ? _textFadeAnimation.value 
                            : 0.8,
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

class GlassMenuBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const GlassMenuBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
