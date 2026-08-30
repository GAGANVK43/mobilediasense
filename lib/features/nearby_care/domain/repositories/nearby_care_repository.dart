import '../../data/models/nearby_care_model.dart';

abstract class NearbyCareRepository {
  Future<List<FacilityModel>> getNearbyFacilities({
    double? latitude,
    double? longitude,
    String? query,
    String type = 'hospital',
  });
}
