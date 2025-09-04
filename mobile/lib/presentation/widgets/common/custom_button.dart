import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppTheme.primaryColor;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);
    final effectivePadding = padding ?? const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    );

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: effectiveTextColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTheme.labelLarge.copyWith(
                  color: effectiveTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    Widget button = borderColor != null
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: effectiveBackgroundColor,
              foregroundColor: effectiveTextColor,
              side: BorderSide(color: borderColor!, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: effectiveBorderRadius,
              ),
              padding: effectivePadding,
            ),
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveBackgroundColor,
              foregroundColor: effectiveTextColor,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: effectiveBorderRadius,
              ),
              padding: effectivePadding,
            ),
            child: buttonChild,
          );

    if (!isFullWidth && width == null) {
      return button;
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: button,
    );
  }
}

// Варианты кнопок для удобства
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      backgroundColor: AppTheme.primaryColor,
      textColor: Colors.white,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      backgroundColor: Colors.white,
      textColor: AppTheme.primaryColor,
      borderColor: AppTheme.primaryColor,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      backgroundColor: AppTheme.errorColor,
      textColor: Colors.white,
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const SuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      backgroundColor: AppTheme.successColor,
      textColor: Colors.white,
    );
  }
}