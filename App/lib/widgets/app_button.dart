import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../ui_tokens.dart';

/// Consistent button component with minimal styling
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonType type;
  final double? width;

  const AppButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = ButtonType.elevated,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }

  Widget _buildButton(BuildContext context) {
    if (type == ButtonType.elevated) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : icon != null
                ? Icon(icon, size: 20)
                : const SizedBox.shrink(),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: UITokens.elevationSmall,
          shadowColor: AppColors.primary.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UITokens.radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UITokens.spacing24,
            vertical: UITokens.spacing12,
          ),
        ),
      );
    } else if (type == ButtonType.outlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : icon != null
                ? Icon(icon, size: 20)
                : const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UITokens.radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UITokens.spacing24,
            vertical: UITokens.spacing12,
          ),
        ),
      );
    } else {
      return TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : icon != null
                ? Icon(icon, size: 20)
                : const SizedBox.shrink(),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: UITokens.spacing16,
            vertical: UITokens.spacing8,
          ),
        ),
      );
    }
  }
}

enum ButtonType { elevated, outlined, text }







