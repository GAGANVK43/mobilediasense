import 'package:equatable/equatable.dart';

class DietPlanModel extends Equatable {
  final int? id;
  final int? predictionId;
  final String breakfast;
  final String lunch;
  final String dinner;
  final String snacks;
  final String exercise;
  final String tips;

  const DietPlanModel({
    this.id,
    this.predictionId,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.exercise,
    required this.tips,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    return DietPlanModel(
      id: json['id'] as int?,
      predictionId: json['prediction_id'] as int?,
      breakfast: json['breakfast'] as String? ?? 'High-fiber oatmeal with chia seeds and unsweetened almond milk.',
      lunch: json['lunch'] as String? ?? 'Quinoa bowl with grilled vegetables and lean protein.',
      dinner: json['dinner'] as String? ?? 'Steamed leafy greens with baked salmon or tofu.',
      snacks: json['snacks'] as String? ?? 'Handful of raw almonds, walnuts, or cucumber slices.',
      exercise: json['exercise'] as String? ?? '30 minutes of brisk walking or moderate aerobic exercise daily.',
      tips: json['tips'] as String? ?? 'Drink 2.5-3L water daily. Avoid sugary beverages and refined carbs.',
    );
  }

  @override
  List<Object?> get props => [id, predictionId, breakfast, lunch, dinner, exercise];
}
