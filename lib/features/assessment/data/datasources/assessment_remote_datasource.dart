import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/assessment_model.dart';

abstract class AssessmentRemoteDataSource {
  Future<Map<String, dynamic>> createAssessment(AssessmentModel assessment);
  Future<List<AssessmentModel>> getAssessmentHistory();
  Future<AssessmentModel> getAssessmentById(int id);
  Future<void> deleteAssessment(int id);
}

class AssessmentRemoteDataSourceImpl implements AssessmentRemoteDataSource {
  final DioClient _client;

  AssessmentRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> createAssessment(AssessmentModel assessment) async {
    final response = await _client.post(
      ApiEndpoints.assessment,
      data: assessment.toJson(),
    );
    final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<List<AssessmentModel>> getAssessmentHistory() async {
    final response = await _client.get(ApiEndpoints.assessmentHistory);
    final apiRes = ApiResponse<dynamic>.fromJson(response.data, null);
    if (!apiRes.success || apiRes.data == null) {
      return [];
    }

    final dynamic data = apiRes.data;
    if (data is List) {
      return data.map((item) => AssessmentModel.fromJson(item as Map<String, dynamic>)).toList();
    } else if (data is Map && data.containsKey('assessments')) {
      final list = data['assessments'] as List<dynamic>;
      return list.map((item) => AssessmentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<AssessmentModel> getAssessmentById(int id) async {
    final response = await _client.get(ApiEndpoints.assessmentById(id));
    final apiRes = ApiResponse<AssessmentModel>.fromJson(
      response.data,
      (json) => AssessmentModel.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<void> deleteAssessment(int id) async {
    await _client.delete(ApiEndpoints.assessmentById(id));
  }
}
