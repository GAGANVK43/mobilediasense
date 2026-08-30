import '../models/assessment_model.dart';
import '../datasources/assessment_remote_datasource.dart';
import '../../domain/repositories/assessment_repository.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  final AssessmentRemoteDataSource _remoteDataSource;

  AssessmentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> createAssessment(AssessmentModel assessment) {
    return _remoteDataSource.createAssessment(assessment);
  }

  @override
  Future<List<AssessmentModel>> getAssessmentHistory() {
    return _remoteDataSource.getAssessmentHistory();
  }

  @override
  Future<AssessmentModel> getAssessmentById(int id) {
    return _remoteDataSource.getAssessmentById(id);
  }

  @override
  Future<void> deleteAssessment(int id) {
    return _remoteDataSource.deleteAssessment(id);
  }
}
