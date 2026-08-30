import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/disclaimer_card.dart';
import '../../../../core/widgets/health_card.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.fullName ?? 'Patient';
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primarySurface,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ' + userName + ' 👋',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const Text(
                  'DiaSense AI Healthcare Analytics',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardDataProvider);
        },
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.riskModerate),
                  const SizedBox(height: AppSpacing.md),
                  Text(err.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: 'Retry',
                    onPressed: () => ref.refresh(dashboardDataProvider),
                  ),
                ],
              ),
            ),
          ),
          data: (data) {
            final hasAssessment = data.assessmentHistory.isNotEmpty;
            final latestPred = data.latestPrediction;
            final riskPct = (latestPred?['risk_percentage'] as num?)?.toDouble() ?? 24.5;
            final riskLevel = latestPred != null
                ? (latestPred['prediction']?.toString() ?? data.riskLevel)
                : data.riskLevel;
            final healthScore = (100 - riskPct).clamp(20, 100).toInt();
            final bmi = data.healthSummary.latestBmi != null
                ? data.healthSummary.latestBmi!.toStringAsFixed(1)
                : '24.5';
            final lastAssessed = hasAssessment ? 'Verified' : 'Pending';

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // 1. Dashboard Hero Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Healthcare Analytics Dashboard',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'AI Health Risk Overview & Analytics',
                        style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitor your longitudinal diabetes risk scores, review automated clinical predictions, and access your custom diet and exercise prescriptions.',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.5, height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/assessment/wizard'),
                              icon: const Icon(Icons.add_circle_outline, size: 18),
                              label: const Text('Start Assessment', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0F766E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (hasAssessment && latestPred != null) {
                                  context.push('/prediction/result', extra: latestPred);
                                } else {
                                  context.push('/reports');
                                }
                              },
                              icon: const Icon(Icons.description_outlined, size: 18, color: Colors.white),
                              label: const Text('View Report', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Health Metrics Overview (4 Snapshots)
                const Text('Health Metrics Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _buildSnapshotCard('❤️ Health Score', '$healthScore / 100', 'Optimal Range', const Color(0xFFE11D48), () {
                      if (latestPred != null) {
                        context.push('/prediction/result', extra: latestPred);
                      } else {
                        context.push('/reports');
                      }
                    }),
                    const SizedBox(width: AppSpacing.sm),
                    _buildSnapshotCard('🩸 Diabetes Risk', riskLevel, 'Prob: ' + riskPct.toStringAsFixed(1) + '%', const Color(0xFF0284C7), () {
                      if (latestPred != null) {
                        context.push('/prediction/result', extra: latestPred);
                      } else {
                        context.push('/reports');
                      }
                    }),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _buildSnapshotCard('⚖️ BMI Score', '$bmi kg/m²', 'Standard Range', const Color(0xFF059669), () {
                      context.push('/history');
                    }),
                    const SizedBox(width: AppSpacing.sm),
                    _buildSnapshotCard('📅 Screening', lastAssessed, 'Longitudinal Track', const Color(0xFF7C3AED), () {
                      context.push('/history');
                    }),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Core AI Modules Grid (6 cards)
                const Text('Core AI Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.3,
                  children: [
                    _buildServiceCard(
                      'AI Prediction Engine',
                      'Execute fresh ML risk screening on physiological markers.',
                      Icons.psychology_outlined,
                      const Color(0xFF0F766E),
                      () => context.push('/assessment/wizard'),
                    ),
                    _buildServiceCard(
                      'Personalized Diet Plan',
                      'View customized 7-day meal prescriptions for your risk level.',
                      Icons.restaurant_menu_rounded,
                      const Color(0xFFF59E0B),
                      () => context.push('/diet'),
                    ),
                    _buildServiceCard(
                      'Exercise Intelligence',
                      'Risk-aware physical activity & workout recommendations.',
                      Icons.directions_run_rounded,
                      const Color(0xFFEC4899),
                      () => context.push('/diet'),
                    ),
                    _buildServiceCard(
                      'AI Food Vision Scanner',
                      'Scan meals with camera to analyze glycemic load & calories.',
                      Icons.camera_alt_outlined,
                      const Color(0xFF10B981),
                      () => context.push('/food-analysis'),
                    ),
                    _buildServiceCard(
                      'Find Care Near You',
                      'Discover diabetes specialists, clinics & laboratories.',
                      Icons.local_hospital_outlined,
                      const Color(0xFF3B82F6),
                      () => context.push('/nearby-care'),
                    ),
                    _buildServiceCard(
                      'Clinical PDF Reports',
                      'Download certified medical reports for physician review.',
                      Icons.picture_as_pdf_outlined,
                      const Color(0xFF8B5CF6),
                      () => context.push('/reports'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSnapshotCard(String title, String value, String sub, Color accent, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: accent)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryLight), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
