import 'package:flutter/material.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/health_card.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical & AI Transparency'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            HealthCard(
              backgroundColor: AppColors.primarySurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.health_and_safety_outlined, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Clinical Disclaimer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppConstants.medicalDisclaimer,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Machine Learning Model Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            const HealthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Model Type: Random Forest Classifier (Scikit-Learn)'),
                  SizedBox(height: 4),
                  Text('Validation Accuracy: ~88.3%'),
                  SizedBox(height: 4),
                  Text('Training Baseline: PIMA Indian Diabetes Dataset & clinical lifestyle parameters.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
