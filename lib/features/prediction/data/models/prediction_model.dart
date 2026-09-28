import 'package:equatable/equatable.dart';

class ContributingFactor extends Equatable {
  final String feature;
  final String value;
  final double score;
  final String impact; // "High Risk", "Moderate Risk", "Optimal"
  final String description;

  const ContributingFactor({
    required this.feature,
    this.value = '',
    this.score = 0.0,
    required this.impact,
    this.description = '',
  });

  factory ContributingFactor.fromJson(Map<String, dynamic> json) {
    return ContributingFactor(
      feature: (json['factor'] ?? json['feature'] ?? 'Factor').toString(),
      value: (json['value'] ?? '').toString(),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      impact: (json['impact'] ?? 'Moderate').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [feature, value, score, impact, description];
}

class PredictionResultModel extends Equatable {
  final int? id;
  final int? assessmentId;
  final String prediction; // "Diabetic", "Non-Diabetic", "High Risk", "Low Risk"
  final double riskPercentage;
  final double confidence;
  final String recommendation;
  final List<ContributingFactor> contributingFactors;
  final DateTime? createdAt;

  const PredictionResultModel({
    this.id,
    this.assessmentId,
    required this.prediction,
    required this.riskPercentage,
    required this.confidence,
    required this.recommendation,
    this.contributingFactors = const [],
    this.createdAt,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    var factors = <ContributingFactor>[];
    if (json['contributing_factors'] is List) {
      factors = (json['contributing_factors'] as List)
          .map((item) => ContributingFactor.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return PredictionResultModel(
      id: json['id'] as int?,
      assessmentId: json['assessment_id'] as int?,
      prediction: json['prediction'] as String? ?? 'Non-Diabetic',
      riskPercentage: (json['risk_percentage'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 95.0,
      recommendation: json['recommendation'] as String? ??
          'Maintain a balanced, nutrient-dense diet and stay physically active.',
      contributingFactors: factors,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [id, prediction, riskPercentage, confidence];
}
