import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/disclaimer_card.dart';
import '../../../../core/widgets/health_card.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../providers/food_analysis_provider.dart';

class FoodAnalysisScreen extends ConsumerStatefulWidget {
  const FoodAnalysisScreen({super.key});

  @override
  ConsumerState<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends ConsumerState<FoodAnalysisScreen> {
  final _queryController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
      if (picked != null) {
        final file = File(picked.path);
        ref.read(foodAnalysisProvider.notifier).analyzeImage(file);
      }
    } catch (_) {}
  }

  Color _getSuitabilityColor(String color) {
    if (color == 'emerald') return AppColors.riskLow;
    if (color == 'amber') return AppColors.riskModerate;
    return AppColors.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    final foodState = ref.watch(foodAnalysisProvider);
    final result = foodState.result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food & Nutrition Scanner'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // 1. Text Search Box
            HealthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Describe Meal or Food Items', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _queryController,
                          decoration: InputDecoration(
                            hintText: 'e.g. 2 Idli with sambar & coconut chutney',
                            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMutedLight),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              borderSide: const BorderSide(color: AppColors.borderLight),
                            ),
                          ),
                          onSubmitted: (val) {
                            ref.read(foodAnalysisProvider.notifier).analyzeMealText(val);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                        icon: const Icon(Icons.search_rounded, color: Colors.white),
                        onPressed: () {
                          ref.read(foodAnalysisProvider.notifier).analyzeMealText(_queryController.text);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 2. Camera / Gallery Row
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Take Photo',
                    icon: Icons.camera_alt_outlined,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: 'Upload Image',
                    icon: Icons.photo_library_outlined,
                    isOutlined: true,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. Loading Indicator
            if (foodState.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: AppSpacing.md),
                      Text('Analyzing nutrition & glycemic index...', style: TextStyle(color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
              ),
            ],

            // 4. Error
            if (foodState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.riskHighBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(foodState.errorMessage!, style: const TextStyle(color: AppColors.riskHigh)),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // 5. Analysis Result
            if (result != null && !foodState.isLoading) ...[
              HealthCard(
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            result.dishName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getSuitabilityColor(result.suitabilityColor).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            result.overallSuitability,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _getSuitabilityColor(result.suitabilityColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Macro Badges
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            title: 'Calories',
                            value: result.totalCaloriesKcal.toStringAsFixed(0),
                            unit: 'kcal',
                            icon: Icons.local_fire_department_outlined,
                            iconColor: const Color(0xFFEA580C),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: MetricTile(
                            title: 'Net Carbs',
                            value: result.totalNetCarbsG.toStringAsFixed(1),
                            unit: 'g',
                            icon: Icons.grain_outlined,
                            iconColor: const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: MetricTile(
                            title: 'Glycemic Index',
                            value: result.averageGlycemicIndex.toString(),
                            unit: 'GI',
                            icon: Icons.speed_rounded,
                            iconColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text('Clinical Guidance', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      result.clinicalRecommendation,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimaryLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}
