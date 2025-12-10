import 'package:flutter/material.dart';
import '../../../core/theme/app_design_system.dart';

/// Trust badge component showing verification status
/// Displays: ✓ Verified / ⧗ Pending / ○ Not Verified
class TrustBadge extends StatelessWidget {
  final TrustStatus status;
  final String? customLabel;
  final bool compact;

  const TrustBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    
    if (compact) {
      return Icon(
        config.icon,
        size: AppDesignSystem.iconSmall,
        color: config.color,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignSystem.space12,
        vertical: AppDesignSystem.space4,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: AppDesignSystem.iconSmall,
            color: config.color,
          ),
          const SizedBox(width: AppDesignSystem.space4),
          Text(
            customLabel ?? config.label,
            style: AppDesignSystem.labelMedium.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (status) {
      case TrustStatus.verified:
        return _BadgeConfig(
          icon: Icons.verified,
          label: 'Verified',
          color: AppDesignSystem.success,
        );
      case TrustStatus.pending:
        return _BadgeConfig(
          icon: Icons.pending,
          label: 'Pending',
          color: AppDesignSystem.warning,
        );
      case TrustStatus.notVerified:
        return _BadgeConfig(
          icon: Icons.circle_outlined,
          label: 'Not Verified',
          color: AppDesignSystem.textDisabled,
        );
    }
  }
}

class _BadgeConfig {
  final IconData icon;
  final String label;
  final Color color;

  _BadgeConfig({
    required this.icon,
    required this.label,
    required this.color,
  });
}

enum TrustStatus {
  verified,
  pending,
  notVerified,
}
