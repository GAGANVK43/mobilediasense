import '../models/nearby_care_model.dart';
import '../datasources/nearby_care_remote_datasource.dart';
import '../../domain/repositories/nearby_care_repository.dart';

class NearbyCareRepositoryImpl implements NearbyCareRepository {
  final NearbyCareRemoteDataSource _remoteDataSource;

  NearbyCareRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<FacilityModel>> getNearbyFacilities({
    double? latitude,
    double? longitude,
    String? query,
    String type = 'hospital',
    int radius = 5000,
  }) {
    return _remoteDataSource.getNearbyFacilities(
      latitude: latitude,
      longitude: longitude,
      query: query,
      type: type,
      radius: radius,
    );
  }
}
