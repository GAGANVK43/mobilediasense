import 'package:equatable/equatable.dart';
import 'user_model.dart';

class UserProfileStats extends Equatable {
  final UserModel user;
  final int totalAssessments;
  final String? latestPrediction;
  final double? latestRiskScore;
  final double? latestConfidence;
  final DateTime? latestAssessmentDate;

  const UserProfileStats({
    required this.user,
    this.totalAssessments = 0,
    this.latestPrediction,
    this.latestRiskScore,
    this.latestConfidence,
    this.latestAssessmentDate,
  });

  factory UserProfileStats.fromJson(Map<String, dynamic> json) {
    return UserProfileStats(
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : UserModel(
              id: json['id'] as int? ?? 0,
              fullName: json['full_name'] as String? ?? '',
              email: json['email'] as String? ?? '',
              age: json['age'] as int?,
              gender: json['gender'] as String?,
            ),
      totalAssessments: json['total_assessments'] as int? ?? 0,
      latestPrediction: json['latest_prediction'] as String?,
      latestRiskScore: (json['latest_risk_score'] as num?)?.toDouble(),
      latestConfidence: (json['latest_confidence'] as num?)?.toDouble(),
      latestAssessmentDate: json['latest_assessment_date'] != null
          ? DateTime.tryParse(json['latest_assessment_date'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [user, totalAssessments, latestPrediction, latestRiskScore];
}
