import 'package:flutter/material.dart';
import '../../../core/theme/app_design_system.dart';

/// Action card component with icon, title, and tap action
/// Used for quick actions and navigation cards
class ActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDesignSystem.elevation2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDesignSystem.space16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.space12),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppDesignSystem.primary)
                      .withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMedium),
                ),
                child: Icon(
                  icon,
                  size: AppDesignSystem.iconLarge,
                  color: iconColor ?? AppDesignSystem.primary,
                ),
              ),
              const SizedBox(height: AppDesignSystem.space12),
              Text(
                title,
                style: AppDesignSystem.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppDesignSystem.space4),
                Text(
                  subtitle!,
                  style: AppDesignSystem.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
