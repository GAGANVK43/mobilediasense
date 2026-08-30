import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/diet_model.dart';

abstract class DietRemoteDataSource {
  Future<DietPlanModel> getLatestDietPlan();
  Future<DietPlanModel> getDietPlanByPrediction(int predictionId);
}

class DietRemoteDataSourceImpl implements DietRemoteDataSource {
  final DioClient _client;

  DietRemoteDataSourceImpl(this._client);

  @override
  Future<DietPlanModel> getLatestDietPlan() async {
    final response = await _client.get(ApiEndpoints.dietLatest);
    final apiRes = ApiResponse<DietPlanModel>.fromJson(
      response.data,
      (json) => DietPlanModel.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<DietPlanModel> getDietPlanByPrediction(int predictionId) async {
    final response = await _client.get(ApiEndpoints.dietByPrediction(predictionId));
    final apiRes = ApiResponse<DietPlanModel>.fromJson(
      response.data,
      (json) => DietPlanModel.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }
}
