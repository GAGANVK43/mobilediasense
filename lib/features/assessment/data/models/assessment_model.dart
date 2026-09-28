import 'package:equatable/equatable.dart';

class AssessmentModel extends Equatable {
  final int? id;
  final int? userId;

  // Indian Patient Dataset fields
  final String patientGroup;
  final String gender;
  final int age;
  final double bmi;
  final double bloodPressure;
  final double hba1c;
  final double fastingGlucose;
  final double physicalActivityHours;
  final double dailySugarIntake;
  final double fastFoodFrequency;
  final double sleepHours;
  final double familyHistory;
  final double monthlyIncome;
  final double month;

  // Legacy fields
  final int pregnancies;
  final double glucose;
  final double skinThickness;
  final double insulin;
  final double diabetesPedigreeFunction;
  final DateTime? createdAt;

  const AssessmentModel({
    this.id,
    this.userId,
    this.patientGroup = 'Urban',
    this.gender = 'Male',
    required this.age,
    required this.bmi,
    required this.bloodPressure,
    this.hba1c = 5.7,
    this.fastingGlucose = 100.0,
    this.physicalActivityHours = 2.0,
    this.dailySugarIntake = 30.0,
    this.fastFoodFrequency = 2.0,
    this.sleepHours = 7.0,
    this.familyHistory = 0.0,
    this.monthlyIncome = 35000.0,
    this.month = 6.0,
    this.pregnancies = 0,
    this.glucose = 100.0,
    this.skinThickness = 20.0,
    this.insulin = 80.0,
    this.diabetesPedigreeFunction = 0.47,
    this.createdAt,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    final fg = (json['fasting_glucose'] as num?)?.toDouble() ??
        (json['glucose'] as num?)?.toDouble() ??
        100.0;
    return AssessmentModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      patientGroup: json['patient_group']?.toString() ?? 'Urban',
      gender: json['gender']?.toString() ?? 'Male',
      age: json['age'] as int? ?? 35,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 24.5,
      bloodPressure: (json['blood_pressure'] as num?)?.toDouble() ?? 120.0,
      hba1c: (json['hba1c'] as num?)?.toDouble() ?? 5.7,
      fastingGlucose: fg,
      physicalActivityHours: (json['physical_activity_hours'] as num?)?.toDouble() ?? 2.0,
      dailySugarIntake: (json['daily_sugar_intake'] as num?)?.toDouble() ?? 30.0,
      fastFoodFrequency: (json['fast_food_frequency'] as num?)?.toDouble() ?? 2.0,
      sleepHours: (json['sleep_hours'] as num?)?.toDouble() ?? 7.0,
      familyHistory: (json['family_history'] as num?)?.toDouble() ?? 0.0,
      monthlyIncome: (json['monthly_income'] as num?)?.toDouble() ?? 35000.0,
      month: (json['month'] as num?)?.toDouble() ?? 6.0,
      pregnancies: json['pregnancies'] as int? ?? 0,
      glucose: fg,
      skinThickness: (json['skin_thickness'] as num?)?.toDouble() ?? 20.0,
      insulin: (json['insulin'] as num?)?.toDouble() ?? 80.0,
      diabetesPedigreeFunction: (json['diabetes_pedigree_function'] as num?)?.toDouble() ?? 0.47,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'patient_group': patientGroup,
        'gender': gender,
        'age': age,
        'bmi': bmi,
        'blood_pressure': bloodPressure,
        'hba1c': hba1c,
        'fasting_glucose': fastingGlucose,
        'physical_activity_hours': physicalActivityHours,
        'daily_sugar_intake': dailySugarIntake,
        'fast_food_frequency': fastFoodFrequency,
        'sleep_hours': sleepHours,
        'family_history': familyHistory,
        'monthly_income': monthlyIncome,
        'month': month,
        'glucose': fastingGlucose,
        'pregnancies': pregnancies,
        'skin_thickness': skinThickness,
        'insulin': insulin,
        'diabetes_pedigree_function': diabetesPedigreeFunction,
      };

  @override
  List<Object?> get props => [
        id,
        patientGroup,
        gender,
        age,
        bmi,
        bloodPressure,
        hba1c,
        fastingGlucose,
        physicalActivityHours,
        dailySugarIntake,
        fastFoodFrequency,
        sleepHours,
        familyHistory,
        monthlyIncome,
        month,
      ];
}
