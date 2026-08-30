import '../../data/models/assessment_model.dart';

abstract class AssessmentRepository {
  Future<Map<String, dynamic>> createAssessment(AssessmentModel assessment);
  Future<List<AssessmentModel>> getAssessmentHistory();
  Future<AssessmentModel> getAssessmentById(int id);
  Future<void> deleteAssessment(int id);
}
