import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class LiquidGlassMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final List<LiquidMenuBarItem> items;
  final EdgeInsets margin;
  final double baseHeight;
  final double expandedHeight;

  const LiquidGlassMenu({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.items,
    this.margin = const EdgeInsets.all(20),
    this.baseHeight = 65,
    this.expandedHeight = 75,
  });

  @override
  State<LiquidGlassMenu> createState() => _LiquidGlassMenuState();
}

class _LiquidGlassMenuState extends State<LiquidGlassMenu>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _liquidController;
  late Animation<double> _entranceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _liquidController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(_entranceAnimation);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 3),
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
    _liquidController.dispose();
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
          child: _LiquidGlassContainer(
            selectedIndex: widget.selectedIndex,
            items: widget.items,
            onIndexChanged: widget.onIndexChanged,
            baseHeight: widget.baseHeight,
            expandedHeight: widget.expandedHeight,
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassContainer extends StatefulWidget {
  final int selectedIndex;
  final List<LiquidMenuBarItem> items;
  final ValueChanged<int> onIndexChanged;
  final double baseHeight;
  final double expandedHeight;

  const _LiquidGlassContainer({
    required this.selectedIndex,
    required this.items,
    required this.onIndexChanged,
    required this.baseHeight,
    required this.expandedHeight,
  });

  @override
  State<_LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<_LiquidGlassContainer>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _rippleController;
  late Animation<double> _heightAnimation;
  late Animation<double> _borderRadiusAnimation;
  late Animation<double> _rippleAnimation;
  
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: widget.baseHeight,
      end: widget.expandedHeight,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.elasticOut,
    ));

    _borderRadiusAnimation = Tween<double>(
      begin: 32,
      end: 38,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    ));

    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOutCirc,
    );

    _previousIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(_LiquidGlassContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _morphController.forward().then((_) {
        _morphController.reverse();
      });
      _rippleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_morphController, _rippleController]),
      builder: (context, child) {
        return Container(
          height: _heightAnimation.value,
          child: Stack(
            children: [
              // Liquid Glass Background
              _buildLiquidGlassBackground(),
              
              // Ripple Effect
              _buildRippleEffect(),
              
              // Liquid Selection Indicator
              _LiquidSelectionIndicator(
                selectedIndex: widget.selectedIndex,
                previousIndex: _previousIndex,
                itemCount: widget.items.length,
                containerHeight: _heightAnimation.value,
              ),
              
              // Menu Items
              _buildMenuItems(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiquidGlassBackground() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRippleEffect() {
    if (_rippleAnimation.value == 0) return const SizedBox.shrink();
    
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final itemWidth = screenWidth / widget.items.length;
    final rippleCenter = (widget.selectedIndex + 0.5) * itemWidth;
    
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
        child: CustomPaint(
          painter: _RipplePainter(
            center: Offset(rippleCenter, _heightAnimation.value / 2),
            radius: _rippleAnimation.value * 100,
            color: AppTheme.primaryColor.withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Row(
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isSelected = index == widget.selectedIndex;

        return Expanded(
          child: _LiquidMenuButton(
            item: item,
            isSelected: isSelected,
            onTap: () => widget.onIndexChanged(index),
            containerHeight: _heightAnimation.value,
          ),
        );
      }).toList(),
    );
  }
}

class _LiquidSelectionIndicator extends StatefulWidget {
  final int selectedIndex;
  final int previousIndex;
  final int itemCount;
  final double containerHeight;

  const _LiquidSelectionIndicator({
    required this.selectedIndex,
    required this.previousIndex,
    required this.itemCount,
    required this.containerHeight,
  });

  @override
  State<_LiquidSelectionIndicator> createState() => _LiquidSelectionIndicatorState();
}

class _LiquidSelectionIndicatorState extends State<_LiquidSelectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _morphAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.25, 0.46, 0.45, 0.94), // Liquid curve
    );
    
    _morphAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
  }

  @override
  void didUpdateWidget(_LiquidSelectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
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
        final screenWidth = MediaQuery.of(context).size.width - 40;
        final itemWidth = screenWidth / widget.itemCount;
        final progress = _slideAnimation.value;
        final morphProgress = _morphAnimation.value;
        
        // Liquid morphing calculation
        final startPos = widget.previousIndex * itemWidth;
        final endPos = widget.selectedIndex * itemWidth;
        final currentPos = startPos + (endPos - startPos) * progress;
        
        // Dynamic width for liquid effect
        final baseWidth = itemWidth * 0.7;
        final stretchWidth = itemWidth * 1.2;
        final currentWidth = progress < 0.5 
            ? baseWidth + (stretchWidth - baseWidth) * (progress * 2)
            : stretchWidth - (stretchWidth - baseWidth) * ((progress - 0.5) * 2);
        
        return Positioned(
          left: currentPos + (itemWidth - currentWidth) / 2,
          top: 8,
          bottom: 8,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: currentWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.secondaryColor.withOpacity(0.9),
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25 + morphProgress * 5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20 + morphProgress * 10,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
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

class _LiquidMenuButton extends StatefulWidget {
  final LiquidMenuBarItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final double containerHeight;

  const _LiquidMenuButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.containerHeight,
  });

  @override
  State<_LiquidMenuButton> createState() => _LiquidMenuButtonState();
}

class _LiquidMenuButtonState extends State<_LiquidMenuButton>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _selectionController;
  late Animation<double> _tapAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;

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
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(_LiquidMenuButton oldWidget) {
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
              height: widget.containerHeight,
              child: Center(
                child: Transform.scale(
                  scale: _iconScaleAnimation.value,
                  child: Transform.rotate(
                    angle: _iconRotationAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                        color: widget.isSelected 
                            ? Colors.white 
                            : Colors.black.withOpacity(0.7),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  _RipplePainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LiquidMenuBarItem {
  final IconData icon;
  final IconData activeIcon;

  const LiquidMenuBarItem({
    required this.icon,
    required this.activeIcon,
  });
}
