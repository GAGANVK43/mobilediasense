import 'package:equatable/equatable.dart';

class FoodNutritionalItem extends Equatable {
  final String foodName;
  final double caloriesKcal;
  final double carbohydratesG;
  final double netCarbsG;
  final double proteinG;
  final double fiberG;
  final double fatsG;
  final int glycemicIndex;
  final double glycemicLoad;
  final String portionSize;
  final String diabeticSuitability; // "Diabetic Friendly", "Moderate / Control Portion", "High Risk / Limit"
  final String suitabilityColor;    // "emerald", "amber", "red"

  const FoodNutritionalItem({
    required this.foodName,
    required this.caloriesKcal,
    required this.carbohydratesG,
    required this.netCarbsG,
    required this.proteinG,
    required this.fiberG,
    required this.fatsG,
    required this.glycemicIndex,
    required this.glycemicLoad,
    required this.portionSize,
    required this.diabeticSuitability,
    required this.suitabilityColor,
  });

  factory FoodNutritionalItem.fromJson(Map<String, dynamic> json) {
    return FoodNutritionalItem(
      foodName: json['food_name']?.toString() ?? 'Item',
      caloriesKcal: (json['calories_kcal'] as num?)?.toDouble() ?? 0.0,
      carbohydratesG: (json['carbohydrates_g'] as num?)?.toDouble() ?? 0.0,
      netCarbsG: (json['net_carbs_g'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      fiberG: (json['fiber_g'] as num?)?.toDouble() ?? 0.0,
      fatsG: (json['fats_g'] as num?)?.toDouble() ?? 0.0,
      glycemicIndex: (json['glycemic_index'] as num?)?.toInt() ?? 50,
      glycemicLoad: (json['glycemic_load'] as num?)?.toDouble() ?? 10.0,
      portionSize: json['portion_size']?.toString() ?? '1 serving',
      diabeticSuitability: json['diabetic_suitability']?.toString() ?? 'Diabetic Friendly',
      suitabilityColor: json['suitability_color']?.toString() ?? 'emerald',
    );
  }

  @override
  List<Object?> get props => [foodName, caloriesKcal, carbohydratesG, glycemicIndex];
}

class FoodAnalysisModel extends Equatable {
  final String dishName;
  final List<String> identifiedItems;
  final double totalCaloriesKcal;
  final double totalCarbohydratesG;
  final double totalNetCarbsG;
  final double totalProteinG;
  final double totalFiberG;
  final double totalFatsG;
  final int averageGlycemicIndex;
  final String overallSuitability;
  final String suitabilityColor;
  final String suggestedPortion;
  final List<FoodNutritionalItem> nutritionalDetails;
  final String clinicalRecommendation;

  const FoodAnalysisModel({
    required this.dishName,
    required this.identifiedItems,
    required this.totalCaloriesKcal,
    required this.totalCarbohydratesG,
    required this.totalNetCarbsG,
    required this.totalProteinG,
    required this.totalFiberG,
    required this.totalFatsG,
    required this.averageGlycemicIndex,
    required this.overallSuitability,
    required this.suitabilityColor,
    required this.suggestedPortion,
    required this.nutritionalDetails,
    required this.clinicalRecommendation,
  });

  factory FoodAnalysisModel.fromJson(Map<String, dynamic> json) {
    var items = <FoodNutritionalItem>[];
    if (json['nutritional_details'] is List) {
      items = (json['nutritional_details'] as List)
          .map((i) => FoodNutritionalItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    var idList = <String>[];
    if (json['identified_items'] is List) {
      idList = (json['identified_items'] as List).map((e) => e.toString()).toList();
    }

    return FoodAnalysisModel(
      dishName: json['dish_name']?.toString() ?? 'Meal Analysis',
      identifiedItems: idList,
      totalCaloriesKcal: (json['total_calories_kcal'] as num?)?.toDouble() ?? 0.0,
      totalCarbohydratesG: (json['total_carbohydrates_g'] as num?)?.toDouble() ?? 0.0,
      totalNetCarbsG: (json['total_net_carbs_g'] as num?)?.toDouble() ?? 0.0,
      totalProteinG: (json['total_protein_g'] as num?)?.toDouble() ?? 0.0,
      totalFiberG: (json['total_fiber_g'] as num?)?.toDouble() ?? 0.0,
      totalFatsG: (json['total_fats_g'] as num?)?.toDouble() ?? 0.0,
      averageGlycemicIndex: (json['average_glycemic_index'] as num?)?.toInt() ?? 50,
      overallSuitability: json['overall_suitability']?.toString() ?? 'Diabetic Friendly',
      suitabilityColor: json['suitability_color']?.toString() ?? 'emerald',
      suggestedPortion: json['suggested_portion']?.toString() ?? 'Moderate single portion',
      nutritionalDetails: items,
      clinicalRecommendation: json['clinical_recommendation']?.toString() ??
          'Balanced nutrition suitable for blood sugar management.',
    );
  }

  @override
  List<Object?> get props => [dishName, totalCaloriesKcal, overallSuitability];
}
