import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class ContributingFactorBar extends StatelessWidget {
  final String featureName;
  final double score; // 0.0 to 1.0 or percentage
  final String impact;
  final String description;

  const ContributingFactorBar({
    super.key,
    required this.featureName,
    required this.score,
    required this.impact,
    this.description = '',
  });

  Color _getImpactColor() {
    final lower = impact.toLowerCase();
    if (lower.contains('high')) return AppColors.riskHigh;
    if (lower.contains('mod')) return AppColors.riskModerate;
    return AppColors.riskLow;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getImpactColor();
    final normalizedScore = score > 1.0 ? score / 100 : score;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                featureName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  impact,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: normalizedScore.clamp(0.05, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
            ),
          ],
        ],
      ),
    );
  }
}
