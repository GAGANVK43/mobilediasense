import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/nearby_care_model.dart';

abstract class NearbyCareRemoteDataSource {
  Future<List<FacilityModel>> getNearbyFacilities({
    double? latitude,
    double? longitude,
    String? query,
    String type = 'hospital',
  });
}

class NearbyCareRemoteDataSourceImpl implements NearbyCareRemoteDataSource {
  final DioClient _client;

  NearbyCareRemoteDataSourceImpl(this._client);

  @override
  Future<List<FacilityModel>> getNearbyFacilities({
    double? latitude,
    double? longitude,
    String? query,
    String type = 'hospital',
  }) async {
    final response = await _client.get(
      ApiEndpoints.nearbyCare,
      queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (query != null && query.isNotEmpty) 'query': query,
        'type': type,
      },
    );

    final apiRes = ApiResponse<dynamic>.fromJson(response.data, null);
    if (!apiRes.success || apiRes.data == null) return [];

    final data = apiRes.data;
    if (data is Map && data.containsKey('facilities')) {
      final list = data['facilities'] as List<dynamic>;
      return list.map((i) => FacilityModel.fromJson(i as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
