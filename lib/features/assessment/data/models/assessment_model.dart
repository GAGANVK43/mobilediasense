import 'package:equatable/equatable.dart';

class AssessmentModel extends Equatable {
  final int? id;
  final int? userId;
  final int pregnancies;
  final double glucose;
  final double bloodPressure;
  final double skinThickness;
  final double insulin;
  final double bmi;
  final double diabetesPedigreeFunction;
  final int age;
  final DateTime? createdAt;

  const AssessmentModel({
    this.id,
    this.userId,
    this.pregnancies = 0,
    required this.glucose,
    required this.bloodPressure,
    this.skinThickness = 20.0,
    this.insulin = 80.0,
    required this.bmi,
    this.diabetesPedigreeFunction = 0.47,
    required this.age,
    this.createdAt,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      pregnancies: json['pregnancies'] as int? ?? 0,
      glucose: (json['glucose'] as num?)?.toDouble() ?? 120.0,
      bloodPressure: (json['blood_pressure'] as num?)?.toDouble() ?? 80.0,
      skinThickness: (json['skin_thickness'] as num?)?.toDouble() ?? 20.0,
      insulin: (json['insulin'] as num?)?.toDouble() ?? 80.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 25.0,
      diabetesPedigreeFunction: (json['diabetes_pedigree_function'] as num?)?.toDouble() ?? 0.47,
      age: json['age'] as int? ?? 30,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'pregnancies': pregnancies,
        'glucose': glucose,
        'blood_pressure': bloodPressure,
        'skin_thickness': skinThickness,
        'insulin': insulin,
        'bmi': bmi,
        'diabetes_pedigree_function': diabetesPedigreeFunction,
        'age': age,
      };

  @override
  List<Object?> get props => [
        id,
        pregnancies,
        glucose,
        bloodPressure,
        skinThickness,
        insulin,
        bmi,
        diabetesPedigreeFunction,
        age,
      ];
}
