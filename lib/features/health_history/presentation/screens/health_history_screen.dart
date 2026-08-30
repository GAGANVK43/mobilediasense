import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/health_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../assessment/presentation/providers/assessment_wizard_provider.dart';
import '../widgets/risk_trend_chart.dart';

class HealthHistoryScreen extends ConsumerWidget {
  const HealthHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(assessmentHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health History & Trends'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(assessmentHistoryProvider),
        child: historyAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: const [
              SkeletonLoader(width: double.infinity, height: 200),
              SizedBox(height: AppSpacing.md),
              SkeletonLoader(width: double.infinity, height: 80),
              SizedBox(height: AppSpacing.sm),
              SkeletonLoader(width: double.infinity, height: 80),
            ],
          ),
          error: (err, _) => ErrorStateView(
            message: err.toString(),
            onRetry: () => ref.refresh(assessmentHistoryProvider),
          ),
          data: (assessments) {
            if (assessments.isEmpty) {
              return EmptyStateView(
                title: 'No Health Records',
                description: 'Take your first health assessment to start tracking your clinical trends over time.',
                actionText: 'Take Assessment',
                onAction: () => context.push('/assessment/wizard'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Trend Chart
                HealthCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Glucose History (mg/dL)', style: Theme.of(context).textTheme.titleMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: const Text(
                              'Last 7 Records',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RiskTrendChart(assessments: assessments),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // History List Header
                Text(
                  'Recorded Assessments ()',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),

                ...assessments.map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: HealthCard(
                      onTap: () {
                        context.push('/assessment/details', extra: a);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (a.glucose > 140 ? AppColors.riskModerateBg : AppColors.riskLowBg),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: Icon(
                              Icons.assignment_outlined,
                              color: a.glucose > 140 ? AppColors.riskModerate : AppColors.riskLow,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Glucose:  mg/dL',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    Text(
                                      'BMI: ',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondaryLight),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  Formatters.formatDateTime(a.createdAt),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMutedLight),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
