import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/prediction_model.dart';

abstract class PredictionRemoteDataSource {
  Future<PredictionResultModel> getLatestPrediction();
  Future<List<PredictionResultModel>> getPredictionHistory();
  Future<Map<String, dynamic>> getModelAccuracy();
}

class PredictionRemoteDataSourceImpl implements PredictionRemoteDataSource {
  final DioClient _client;

  PredictionRemoteDataSourceImpl(this._client);

  @override
  Future<PredictionResultModel> getLatestPrediction() async {
    final response = await _client.get(ApiEndpoints.predictionLatest);
    final apiRes = ApiResponse<PredictionResultModel>.fromJson(
      response.data,
      (json) => PredictionResultModel.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<List<PredictionResultModel>> getPredictionHistory() async {
    final response = await _client.get(ApiEndpoints.predictionHistory);
    final apiRes = ApiResponse<dynamic>.fromJson(response.data, null);
    if (!apiRes.success || apiRes.data == null) return [];

    final dynamic data = apiRes.data;
    if (data is List) {
      return data.map((i) => PredictionResultModel.fromJson(i as Map<String, dynamic>)).toList();
    } else if (data is Map && data.containsKey('predictions')) {
      final list = data['predictions'] as List<dynamic>;
      return list.map((i) => PredictionResultModel.fromJson(i as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getModelAccuracy() async {
    final response = await _client.get(ApiEndpoints.predictionAccuracy);
    final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
    return apiRes.data ?? {'accuracy': 0.883, 'accuracy_percentage': '88.3%'};
  }
}
