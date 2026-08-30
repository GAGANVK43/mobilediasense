import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/disclaimer_card.dart';
import '../../../../core/widgets/health_card.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../data/models/assessment_model.dart';

class AssessmentDetailScreen extends StatelessWidget {
  final AssessmentModel assessment;

  const AssessmentDetailScreen({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Top Date Header
            HealthCard(
              backgroundColor: AppColors.primarySurface,
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assessment Timestamp', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                      Text(
                        Formatters.formatDateTime(assessment.createdAt),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Clinical Parameters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    title: 'Plasma Glucose',
                    value: assessment.glucose.toStringAsFixed(0),
                    unit: 'mg/dL',
                    icon: Icons.water_drop_outlined,
                    iconColor: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MetricTile(
                    title: 'Body Mass Index',
                    value: assessment.bmi.toStringAsFixed(1),
                    unit: 'kg/m²',
                    icon: Icons.monitor_weight_outlined,
                    iconColor: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    title: 'Blood Pressure',
                    value: assessment.bloodPressure.toStringAsFixed(0),
                    unit: 'mmHg',
                    icon: Icons.speed_rounded,
                    iconColor: AppColors.riskModerate,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MetricTile(
                    title: 'Serum Insulin',
                    value: assessment.insulin.toStringAsFixed(0),
                    unit: 'μU/mL',
                    icon: Icons.medication_outlined,
                    iconColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    title: 'Age',
                    value: '',
                    unit: 'years',
                    icon: Icons.cake_outlined,
                    iconColor: const Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MetricTile(
                    title: 'Pedigree Index',
                    value: assessment.diabetesPedigreeFunction.toStringAsFixed(2),
                    unit: 'score',
                    icon: Icons.family_restroom_rounded,
                    iconColor: const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
