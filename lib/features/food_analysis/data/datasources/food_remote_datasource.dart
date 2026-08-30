import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/food_analysis_model.dart';

abstract class FoodRemoteDataSource {
  Future<FoodAnalysisModel> analyzeText(String query);
  Future<FoodAnalysisModel> analyzeImage(File imageFile);
}

class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final DioClient _client;

  FoodRemoteDataSourceImpl(this._client);

  @override
  Future<FoodAnalysisModel> analyzeText(String query) async {
    final response = await _client.post(
      ApiEndpoints.foodAnalyzeText,
      data: {'query': query},
    );
    final apiRes = ApiResponse<FoodAnalysisModel>.fromJson(
      response.data,
      (json) => FoodAnalysisModel.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<FoodAnalysisModel> analyzeImage(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    final response = await _client.post(
      ApiEndpoints.foodAnalyzeImage,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final apiRes = ApiResponse<FoodAnalysisModel>.fromJson(
      response.data,
      (json) => FoodAnalysisModel.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }
}
