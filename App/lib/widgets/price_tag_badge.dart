import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../ui_tokens.dart';

/// Modern price tag badge component
class PriceTagBadge extends StatelessWidget {
  final double price;
  final bool isSmall;

  const PriceTagBadge({
    Key? key,
    required this.price,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? UITokens.spacing12 : UITokens.spacing16,
        vertical: isSmall ? UITokens.spacing6 : UITokens.spacing10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(isSmall ? UITokens.radiusSmall : UITokens.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '₹',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: isSmall ? 14 : 18,
              height: 1,
            ),
          ),
          Text(
            price.toStringAsFixed(0),
            style: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: isSmall ? 16 : 22,
              letterSpacing: 0.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

