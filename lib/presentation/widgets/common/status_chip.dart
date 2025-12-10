import 'package:flutter/material.dart';
import '../../../core/theme/app_design_system.dart';

/// Status chip component - small pill-shaped indicator
/// Used for categories, statuses, and tags
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected
        ? color
        : color.withValues(alpha: 0.1);
    
    final textColor = selected
        ? AppDesignSystem.textOnPrimary
        : color;

    final widget = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignSystem.space12,
        vertical: AppDesignSystem.space8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
        border: selected
            ? null
            : Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppDesignSystem.iconSmall,
              color: textColor,
            ),
            const SizedBox(width: AppDesignSystem.space4),
          ],
          Text(
            label,
            style: AppDesignSystem.labelMedium.copyWith(
              color: textColor,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
        child: widget,
      );
    }

    return widget;
  }
}
