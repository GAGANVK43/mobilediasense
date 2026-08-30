import 'package:equatable/equatable.dart';

class FacilityModel extends Equatable {
  final int id;
  final String name;
  final String facilityType;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String? address;
  final String? phone;
  final bool open247;

  const FacilityModel({
    required this.id,
    required this.name,
    required this.facilityType,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.address,
    this.phone,
    this.open247 = false,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Healthcare Center',
      facilityType: json['facility_type']?.toString() ?? 'Hospital',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 1000.0,
      address: json['address']?.toString() ?? 'Main Road, Health District',
      phone: json['phone']?.toString(),
      open247: json['open_24_7'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, latitude, longitude, distanceMeters];
}
