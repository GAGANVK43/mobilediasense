import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/health_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../prediction/presentation/providers/prediction_provider.dart';
import '../../../nearby_care/presentation/screens/nearby_care_screen.dart';
import '../providers/report_provider.dart';

class ReportsAndCareScreen extends ConsumerWidget {
  const ReportsAndCareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Care & Reports'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryLight,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.picture_as_pdf_outlined), text: 'PDF Reports'),
              Tab(icon: Icon(Icons.local_hospital_outlined), text: 'Nearby Clinics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PdfReportsTabView(),
            NearbyCareScreen(),
          ],
        ),
      ),
    );
  }
}

class _PdfReportsTabView extends ConsumerWidget {
  const _PdfReportsTabView();

  Widget _buildHeroCard(BuildContext context, WidgetRef ref, ReportDownloadState reportState) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Clinical PDF Report',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimaryLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Official AI Diabetes Screening Report',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: AppButton(
                  text: reportState.isDownloading ? 'Downloading...' : 'Download PDF',
                  icon: Icons.download_rounded,
                  isLoading: reportState.isDownloading,
                  onPressed: reportState.isDownloading
                      ? null
                      : () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('⏳ Generating & Downloading PDF Report...')),
                          );
                          await ref.read(reportNotifierProvider.notifier).downloadAndOpenPdf(0);
                          final s = ref.read(reportNotifierProvider);
                          if (s.error != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Download failed: ${s.error}'), backgroundColor: Colors.red),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Report PDF downloaded successfully!'), backgroundColor: Colors.green),
                            );
                          }
                        },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: AppButton(
                  text: 'Share',
                  icon: Icons.share_rounded,
                  isOutlined: true,
                  onPressed: reportState.isDownloading
                      ? null
                      : () {
                          ref.read(reportNotifierProvider.notifier).sharePdfReport(0);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionsAsync = ref.watch(predictionHistoryProvider);
    final reportState = ref.watch(reportNotifierProvider);

    return predictionsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          SkeletonLoader(width: double.infinity, height: 80),
          SizedBox(height: AppSpacing.sm),
          SkeletonLoader(width: double.infinity, height: 80),
        ],
      ),
      error: (err, _) => Center(child: Text(err.toString())),
      data: (predictions) {
        if (predictions.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _buildHeroCard(context, ref, reportState),
              const SizedBox(height: AppSpacing.sm),
              EmptyStateView(
                title: 'No Previous Screening History',
                description: 'You can download your latest report above or take a fresh assessment.',
                actionText: 'Start Assessment',
                onAction: () => context.push('/assessment/wizard'),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: predictions.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHeroCard(context, ref, reportState);
            }

            final p = predictions[index - 1];
            final predId = p.id ?? index;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HealthCard(
                onTap: () {
                  context.push('/prediction/result', extra: {
                    'id': p.id ?? index,
                    'assessment_id': p.assessmentId,
                    'prediction': p.prediction,
                    'risk_percentage': p.riskPercentage,
                    'confidence': p.confidence,
                    'recommendation': p.recommendation,
                  });
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DiaSense Health Report #$predId',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Risk: ${p.riskPercentage.toStringAsFixed(1)}% • ${p.prediction}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                          if (p.createdAt != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              Formatters.formatDateTime(p.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Download PDF',
                      icon: reportState.isDownloading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Icon(Icons.download_rounded, color: AppColors.primary, size: 22),
                      onPressed: reportState.isDownloading
                          ? null
                          : () {
                              ref.read(reportNotifierProvider.notifier).downloadAndOpenPdf(predId);
                            },
                    ),
                    IconButton(
                      tooltip: 'Share Report',
                      icon: const Icon(Icons.share_outlined, color: AppColors.textSecondaryLight, size: 20),
                      onPressed: reportState.isDownloading
                          ? null
                          : () {
                              ref.read(reportNotifierProvider.notifier).sharePdfReport(predId);
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
