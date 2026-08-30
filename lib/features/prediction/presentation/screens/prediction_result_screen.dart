import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/disclaimer_card.dart';
import '../../../../core/widgets/health_card.dart';
import '../../../../core/widgets/risk_gauge.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../reports/presentation/providers/report_provider.dart';

class PredictionResultScreen extends ConsumerWidget {
  final Map<String, dynamic>? resultData;

  const PredictionResultScreen({super.key, this.resultData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.fullName ?? 'Patient';

    final id = resultData?['id'] ?? 1;
    final assessmentId = 'REP-' + id.toString().padLeft(5, '0');
    final prediction = resultData?['prediction']?.toString() ?? 'Non-Diabetic';
    final riskPct = (resultData?['risk_percentage'] as num?)?.toDouble() ?? 24.5;
    final confidence = (resultData?['confidence'] as num?)?.toDouble() ?? 95.0;
    final healthScore = (100 - riskPct).clamp(20, 100).toInt();
    final recommendation = resultData?['recommendation']?.toString() ??
        'Maintain a balanced low-glycemic diet, engage in 30+ minutes of daily moderate activity, and schedule regular metabolic checkups.';

    final isHigh = prediction.toLowerCase().contains('diabetic') || riskPct >= 50.0;
    final isModerate = !isHigh && riskPct >= 25.0;
    final riskCategory = isHigh ? 'High Risk' : isModerate ? 'Moderate Risk' : 'Low Risk';

    // Contributing Factors
    final factors = (resultData?['contributing_factors'] as List?) ?? [
      {
        'factor': 'Blood Glucose',
        'value': ' mg/dL',
        'impact': (resultData?['glucose'] as num? ?? 115) > 140 ? 'High' : (resultData?['glucose'] as num? ?? 115) > 100 ? 'Elevated' : 'Optimal',
        'description': 'Fasting blood glucose level relative to normal metabolic baseline (<100 mg/dL).'
      },
      {
        'factor': 'BMI Score',
        'value': ' kg/m²',
        'impact': (resultData?['bmi'] as num? ?? 24.2) > 30 ? 'High' : (resultData?['bmi'] as num? ?? 24.2) > 25 ? 'Moderate' : 'Optimal',
        'description': 'Body Mass Index calculated from height and weight.'
      },
      {
        'factor': 'Blood Pressure',
        'value': ' mmHg',
        'impact': (resultData?['blood_pressure'] as num? ?? 75) > 90 ? 'Elevated' : 'Optimal',
        'description': 'Diastolic arterial pressure at rest.'
      },
      {
        'factor': 'Insulin',
        'value': ' µU/mL',
        'impact': 'Optimal',
        'description': 'Fasting serum insulin level.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Assessment Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // 1. Official Report Header Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
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
                        Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Official Clinical AI Assessment',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Patient Diabetes Risk Analysis',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assessment ID:  | Patient: ',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Risk Gauge & Metabolic Score Card
            HealthCard(
              child: Column(
                children: [
                  RiskGauge(
                    riskPercentage: riskPct,
                    riskCategory: riskCategory,
                    size: 190,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Prediction Confidence: %',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),

                  // Health Score Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Overall Metabolic Health Score',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        ' / 100',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: healthScore >= 70 ? AppColors.riskLow : AppColors.riskModerate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: LinearProgressIndicator(
                      value: healthScore / 100.0,
                      minHeight: 8,
                      backgroundColor: AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        healthScore >= 70 ? AppColors.riskLow : AppColors.riskModerate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. AI Model Recommendation
            HealthCard(
              backgroundColor: AppColors.primarySurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_outlined, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'AI Model Assessment Summary',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    recommendation,
                    style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textPrimaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 4. Contributing Clinical Factors List
            HealthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Contributing Clinical Factors',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...factors.map((f) {
                    final factor = f['factor']?.toString() ?? '';
                    final val = f['value']?.toString() ?? '';
                    final impact = f['impact']?.toString() ?? 'Optimal';
                    final desc = f['description']?.toString() ?? '';

                    Color badgeColor = AppColors.riskLow;
                    Color badgeBg = AppColors.riskLowBg;
                    if (impact == 'High') {
                      badgeColor = AppColors.riskHigh;
                      badgeBg = AppColors.riskHighBg;
                    } else if (impact == 'Elevated' || impact == 'Moderate') {
                      badgeColor = AppColors.riskModerate;
                      badgeBg = AppColors.riskModerateBg;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                factor,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              Row(
                                children: [
                                  Text(
                                    val,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeBg,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                      border: Border.all(color: badgeColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      impact,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 5. Action Buttons
            AppButton(
              text: 'Download Official PDF Report',
              icon: Icons.picture_as_pdf_outlined,
              onPressed: () {
                final intPredId = id is int ? id : int.tryParse(id.toString()) ?? 1;
                ref.read(reportNotifierProvider.notifier).downloadAndOpenPdf(intPredId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading PDF Medical Report...')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'View Diet Plan',
                    icon: Icons.restaurant_menu_rounded,
                    isOutlined: true,
                    onPressed: () => context.push('/diet'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: 'Find Care',
                    icon: Icons.local_hospital_outlined,
                    isOutlined: true,
                    onPressed: () => context.push('/nearby-care'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            AppButton(
              text: 'Return to Dashboard',
              isOutlined: true,
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 6. Safety Disclaimer
            const DisclaimerCard(),
          ],
        ),
      ),
    );
  }
}
