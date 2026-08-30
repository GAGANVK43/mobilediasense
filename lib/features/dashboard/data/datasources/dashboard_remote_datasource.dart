import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient _client;

  DashboardRemoteDataSourceImpl(this._client);

  @override
  Future<DashboardDataModel> getDashboardData() async {
    final response = await _client.get(ApiEndpoints.dashboard);
    final apiRes = ApiResponse<DashboardDataModel>.fromJson(
      response.data,
      (json) => DashboardDataModel.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }
}
