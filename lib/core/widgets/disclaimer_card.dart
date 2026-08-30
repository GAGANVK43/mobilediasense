import 'package:flutter/material.dart';
import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class DisclaimerCard extends StatelessWidget {
  final String? customText;

  const DisclaimerCard({super.key, this.customText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.riskModerateBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.riskModerate.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 20, color: AppColors.riskModerate),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              customText ?? AppConstants.medicalDisclaimer,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
