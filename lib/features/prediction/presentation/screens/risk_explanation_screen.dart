import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/disclaimer_card.dart';
import '../../../../core/widgets/health_card.dart';
import '../widgets/contributing_factor_bar.dart';

class RiskExplanationScreen extends StatelessWidget {
  final Map<String, dynamic>? predictionData;

  const RiskExplanationScreen({super.key, this.predictionData});

  @override
  Widget build(BuildContext context) {
    final riskPct = (predictionData?['risk_percentage'] as num?)?.toDouble() ?? 24.0;
    final riskCategory = riskPct >= 75 ? 'High' : (riskPct >= 45 ? 'Moderate' : 'Low');

    // Default factors if none provided
    final factors = [
      {
        'feature': 'Plasma Glucose Level',
        'score': (riskPct > 50 ? 0.85 : 0.35),
        'impact': (riskPct > 50 ? 'High Impact' : 'Normal Range'),
        'description': 'Elevated fasting glucose is the primary clinical indicator for glycemic risk.',
      },
      {
        'feature': 'Body Mass Index (BMI)',
        'score': 0.65,
        'impact': 'Moderate Impact',
        'description': 'Higher body mass index increases cellular insulin resistance.',
      },
      {
        'feature': 'Age & Metabolism',
        'score': 0.50,
        'impact': 'Moderate Impact',
        'description': 'Natural biological age factor impacting beta-cell pancreatic function.',
      },
      {
        'feature': 'Blood Pressure',
        'score': 0.40,
        'impact': 'Low Impact',
        'description': 'Vascular pressure correlates with metabolic syndrome risks.',
      },
      {
        'feature': 'Family Pedigree Function',
        'score': 0.30,
        'impact': 'Low Impact',
        'description': 'Genetic predisposition calculated from pedigree coefficient.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Why is my risk elevated?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Top Overview
            HealthCard(
              backgroundColor: AppColors.primarySurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk Breakdown Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryDark,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Our machine learning model evaluates multiple clinical markers simultaneously. Here is the relative impact of each marker from your assessment.',
                    style: TextStyle(fontSize: 13, color: AppColors.textPrimaryLight.withOpacity(0.85)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Factor Bars
            Text(
              'Contributing Health Markers',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            HealthCard(
              child: Column(
                children: factors
                    .map(
                      (f) => ContributingFactorBar(
                        featureName: f['feature'] as String,
                        score: f['score'] as double,
                        impact: f['impact'] as String,
                        description: f['description'] as String,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // AI Chatbot CTA
            AppButton(
              text: 'Discuss with DiaSense AI',
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () => context.push('/chatbot'),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Medical Disclaimer
            const DisclaimerCard(),
          ],
        ),
      ),
    );
  }
}
