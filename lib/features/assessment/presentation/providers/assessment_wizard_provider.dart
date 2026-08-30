import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/assessment_remote_datasource.dart';
import '../../data/repositories/assessment_repository_impl.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../data/models/assessment_model.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final remote = AssessmentRemoteDataSourceImpl(dio);
  return AssessmentRepositoryImpl(remote);
});

class AssessmentWizardState {
  final int currentStep; // 0 to 4 (Step 1 to Step 5)
  final int pregnancies;
  final double glucose;
  final double bloodPressure;
  final double skinThickness;
  final double insulin;
  final double heightCm;
  final double weightKg;
  final double diabetesPedigreeFunction;
  final int age;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, dynamic>? submissionResult;

  const AssessmentWizardState({
    this.currentStep = 0,
    this.pregnancies = 0,
    this.glucose = 120.0,
    this.bloodPressure = 80.0,
    this.skinThickness = 20.0,
    this.insulin = 80.0,
    this.heightCm = 170.0,
    this.weightKg = 70.0,
    this.diabetesPedigreeFunction = 0.47,
    this.age = 35,
    this.isSubmitting = false,
    this.errorMessage,
    this.submissionResult,
  });

  double get calculatedBmi {
    if (heightCm <= 0) return 24.2;
    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  AssessmentWizardState copyWith({
    int? currentStep,
    int? pregnancies,
    double? glucose,
    double? bloodPressure,
    double? skinThickness,
    double? insulin,
    double? heightCm,
    double? weightKg,
    double? diabetesPedigreeFunction,
    int? age,
    bool? isSubmitting,
    String? errorMessage,
    Map<String, dynamic>? submissionResult,
  }) {
    return AssessmentWizardState(
      currentStep: currentStep ?? this.currentStep,
      pregnancies: pregnancies ?? this.pregnancies,
      glucose: glucose ?? this.glucose,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      skinThickness: skinThickness ?? this.skinThickness,
      insulin: insulin ?? this.insulin,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      diabetesPedigreeFunction: diabetesPedigreeFunction ?? this.diabetesPedigreeFunction,
      age: age ?? this.age,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      submissionResult: submissionResult ?? this.submissionResult,
    );
  }
}

class AssessmentWizardNotifier extends StateNotifier<AssessmentWizardState> {
  final AssessmentRepository _repository;

  AssessmentWizardNotifier(this._repository) : super(const AssessmentWizardState());

  void setStep(int step) => state = state.copyWith(currentStep: step);
  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updatePersonal({int? age, int? pregnancies}) {
    state = state.copyWith(age: age, pregnancies: pregnancies);
  }

  void updatePhysical({double? heightCm, double? weightKg, double? skinThickness}) {
    state = state.copyWith(heightCm: heightCm, weightKg: weightKg, skinThickness: skinThickness);
  }

  void updateClinical({double? glucose, double? bloodPressure, double? insulin, double? dpf}) {
    state = state.copyWith(
      glucose: glucose,
      bloodPressure: bloodPressure,
      insulin: insulin,
      diabetesPedigreeFunction: dpf,
    );
  }

  Future<bool> submitAssessment() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final assessment = AssessmentModel(
        pregnancies: state.pregnancies,
        glucose: state.glucose,
        bloodPressure: state.bloodPressure,
        skinThickness: state.skinThickness,
        insulin: state.insulin,
        bmi: double.parse(state.calculatedBmi.toStringAsFixed(1)),
        diabetesPedigreeFunction: state.diabetesPedigreeFunction,
        age: state.age,
      );

      final result = await _repository.createAssessment(assessment);
      state = state.copyWith(
        isSubmitting: false,
        submissionResult: result,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() {
    state = const AssessmentWizardState();
  }
}

final assessmentWizardProvider =
    StateNotifierProvider<AssessmentWizardNotifier, AssessmentWizardState>((ref) {
  final repo = ref.watch(assessmentRepositoryProvider);
  return AssessmentWizardNotifier(repo);
});

final assessmentHistoryProvider = FutureProvider.autoDispose<List<AssessmentModel>>((ref) async {
  final repo = ref.watch(assessmentRepositoryProvider);
  return await repo.getAssessmentHistory();
});
