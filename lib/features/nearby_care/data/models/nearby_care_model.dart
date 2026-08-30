import 'package:equatable/equatable.dart';

/// FIX C3: Complete rewrite to match actual backend NearbyFacilityItem schema.
/// Previous version mapped wrong field names:
///   - 'facility_type'  → backend sends 'type'
///   - 'distance_meters' → backend sends 'distance' (float, in km)
///   - 'open_24_7'      → backend sends 'open_now'
///   - id as int        → backend sends String e.g. "osm_node_123456789"
class FacilityModel extends Equatable {
  final String id;
  final String name;
  final String type;        // "Hospital", "Medical Clinic", etc.
  final String category;    // "hospital" or "laboratory"
  final String address;
  final double latitude;
  final double longitude;
  final double distance;    // in kilometres
  final String distanceUnit;
  final double? rating;
  final bool? openNow;
  final String? phone;
  final String? website;
  final String? mapsUrl;

  const FacilityModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.distanceUnit = 'km',
    this.rating,
    this.openNow,
    this.phone,
    this.website,
    this.mapsUrl,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      // Backend returns String IDs like "osm_node_123456789" — not int
      id: json['id']?.toString() ?? '0',
      name: json['name']?.toString() ?? 'Healthcare Center',
      type: json['type']?.toString() ?? 'Hospital',
      category: json['category']?.toString() ?? 'hospital',
      address: json['address']?.toString() ?? 'Local Address',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      // Backend sends 'distance' (float km), not 'distance_meters'
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      distanceUnit: json['distance_unit']?.toString() ?? 'km',
      rating: (json['rating'] as num?)?.toDouble(),
      // Backend sends 'open_now', not 'open_24_7'
      openNow: json['open_now'] as bool?,
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      mapsUrl: json['maps_url']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, name, latitude, longitude, distance];
}

