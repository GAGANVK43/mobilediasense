import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/health_card.dart';

class MealCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const MealCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimaryLight),
          ),
        ],
      ),
    );
  }
}
