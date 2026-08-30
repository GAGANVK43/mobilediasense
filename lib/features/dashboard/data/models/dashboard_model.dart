import 'package:equatable/equatable.dart';

class HealthSummaryModel extends Equatable {
  final int healthScore;
  final String riskLevel;
  final int totalAssessments;
  final double? latestBmi;
  final double? latestGlucose;
  final double? latestBloodPressure;
  final DateTime? lastAssessedAt;

  const HealthSummaryModel({
    required this.healthScore,
    required this.riskLevel,
    required this.totalAssessments,
    this.latestBmi,
    this.latestGlucose,
    this.latestBloodPressure,
    this.lastAssessedAt,
  });

  factory HealthSummaryModel.fromJson(Map<String, dynamic> json) {
    return HealthSummaryModel(
      healthScore: json['health_score'] as int? ?? 90,
      riskLevel: json['risk_level'] as String? ?? 'Normal',
      totalAssessments: json['total_assessments'] as int? ?? 0,
      latestBmi: (json['latest_bmi'] as num?)?.toDouble(),
      latestGlucose: (json['latest_glucose'] as num?)?.toDouble(),
      latestBloodPressure: (json['latest_blood_pressure'] as num?)?.toDouble(),
      lastAssessedAt: json['last_assessed_at'] != null
          ? DateTime.tryParse(json['last_assessed_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [healthScore, riskLevel, totalAssessments, latestGlucose];
}

class DashboardDataModel extends Equatable {
  final HealthSummaryModel healthSummary;
  final Map<String, dynamic>? latestPrediction;
  final List<dynamic> assessmentHistory;
  final String riskLevel;
  final Map<String, dynamic>? dietPlan;
  final Map<String, dynamic>? userProfile;

  const DashboardDataModel({
    required this.healthSummary,
    this.latestPrediction,
    required this.assessmentHistory,
    required this.riskLevel,
    this.dietPlan,
    this.userProfile,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      healthSummary: json['health_summary'] != null
          ? HealthSummaryModel.fromJson(json['health_summary'] as Map<String, dynamic>)
          : const HealthSummaryModel(healthScore: 90, riskLevel: 'Normal', totalAssessments: 0),
      latestPrediction: json['latest_prediction'] as Map<String, dynamic>?,
      assessmentHistory: json['assessment_history'] as List<dynamic>? ?? [],
      riskLevel: json['risk_level'] as String? ?? 'Normal',
      dietPlan: json['diet_plan'] as Map<String, dynamic>?,
      userProfile: json['user_profile'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [healthSummary, latestPrediction, assessmentHistory, riskLevel];
}
