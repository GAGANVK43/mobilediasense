import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/nearby_care_remote_datasource.dart';
import '../../data/repositories/nearby_care_repository_impl.dart';
import '../../domain/repositories/nearby_care_repository.dart';
import '../../data/models/nearby_care_model.dart';

final nearbyCareRepositoryProvider = Provider<NearbyCareRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final remote = NearbyCareRemoteDataSourceImpl(dio);
  return NearbyCareRepositoryImpl(remote);
});

enum LocationMode { currentGps, manual }

enum LocationState {
  initial,
  locating,
  gpsSuccess,
  manualSuccess,
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  error,
}

class NearbyCareState {
  final List<FacilityModel> facilities;
  final bool isLoading;
  final String? error;
  final String activeType;
  final String displayName;
  final LocationMode locationMode;
  final LocationState locationState;
  final double? latitude;
  final double? longitude;
  final int radiusMeters;
  final String sortBy;

  const NearbyCareState({
    this.facilities = const [],
    this.isLoading = false,
    this.error,
    this.activeType = 'hospital',
    this.displayName = 'Bengaluru',
    this.locationMode = LocationMode.manual,
    this.locationState = LocationState.initial,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.radiusMeters = 5000,
    this.sortBy = 'distance',
  });

  NearbyCareState copyWith({
    List<FacilityModel>? facilities,
    bool? isLoading,
    String? error,
    String? activeType,
    String? displayName,
    LocationMode? locationMode,
    LocationState? locationState,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    String? sortBy,
  }) {
    return NearbyCareState(
      facilities: facilities ?? this.facilities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeType: activeType ?? this.activeType,
      displayName: displayName ?? this.displayName,
      locationMode: locationMode ?? this.locationMode,
      locationState: locationState ?? this.locationState,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class NearbyCareNotifier extends StateNotifier<NearbyCareState> {
  final NearbyCareRepository _repository;

  NearbyCareNotifier(this._repository) : super(const NearbyCareState()) {
    initLocationAndSearch();
  }

  Future<void> initLocationAndSearch() async {
    // Mode 1: Automatically attempt current GPS location on first load
    await useCurrentLocation(silentOnDenial: true);
  }

  /// MODE 1: Use User's Current GPS Location Directly
  Future<void> useCurrentLocation({bool silentOnDenial = false}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      locationState: LocationState.locating,
    );

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          locationState: LocationState.serviceDisabled,
          error: silentOnDenial
              ? null
              : 'Location services (GPS) are turned off. Please turn on GPS or search a location manually.',
        );
        if (silentOnDenial) {
          await searchManualLocation('Bengaluru');
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            locationState: LocationState.permissionDenied,
            error: silentOnDenial
                ? null
                : 'Location permission is required to detect nearby facilities automatically. You can also search manually.',
          );
          if (silentOnDenial) {
            await searchManualLocation('Bengaluru');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          locationState: LocationState.permissionDeniedForever,
          error: silentOnDenial
              ? null
              : 'Location permission is disabled in system settings. Please enable it in Settings or search manually.',
        );
        if (silentOnDenial) {
          await searchManualLocation('Bengaluru');
        }
        return;
      }

      // Step 3: Obtain GPS coordinates
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Step 4: Use GPS coordinates directly for nearby search
      final facilities = await _repository.getNearbyFacilities(
        latitude: position.latitude,
        longitude: position.longitude,
        type: state.activeType,
        radius: state.radiusMeters,
      );

      state = state.copyWith(
        facilities: _applySort(facilities, state.sortBy),
        isLoading: false,
        error: null,
        locationMode: LocationMode.currentGps,
        locationState: LocationState.gpsSuccess,
        latitude: position.latitude,
        longitude: position.longitude,
        displayName: 'Current Location (${position.latitude.toStringAsFixed(2)}°N, ${position.longitude.toStringAsFixed(2)}°E)',
      );
    } catch (e) {
      if (silentOnDenial) {
        await searchManualLocation('Bengaluru');
      } else {
        state = state.copyWith(
          isLoading: false,
          locationState: LocationState.error,
          error: 'Unable to access your current GPS location. Please try again or search manually.',
        );
      }
    }
  }

  /// MODE 2: Manually Search Any City, Area, or 6-digit Indian PIN Code
  Future<void> searchManualLocation(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      displayName: cleanQuery,
      locationMode: LocationMode.manual,
    );

    try {
      final facilities = await _repository.getNearbyFacilities(
        query: cleanQuery,
        type: state.activeType,
        radius: state.radiusMeters,
      );

      // Update coordinates if facilities returned
      double? lat = state.latitude;
      double? lon = state.longitude;
      if (facilities.isNotEmpty) {
        // Average / center near first facility
        lat = facilities.first.latitude;
        lon = facilities.first.longitude;
      }

      state = state.copyWith(
        facilities: _applySort(facilities, state.sortBy),
        isLoading: false,
        error: null,
        latitude: lat,
        longitude: lon,
        displayName: cleanQuery.titleCase,
        locationState: LocationState.manualSuccess,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        locationState: LocationState.error,
        error: 'Location not found. Try entering a city (e.g. Bengaluru, Mysuru, Mumbai), area (e.g. Whitefield, Indiranagar), or 6-digit PIN code (e.g. 560049).',
      );
    }
  }

  /// Change Category (Hospitals & Clinics vs Diagnostic Labs)
  Future<void> changeCategory(String type) async {
    if (state.activeType == type && !state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      activeType: type,
    );

    try {
      List<FacilityModel> list;
      if (state.latitude != null && state.longitude != null) {
        list = await _repository.getNearbyFacilities(
          latitude: state.latitude,
          longitude: state.longitude,
          type: type,
          radius: state.radiusMeters,
        );
      } else {
        list = await _repository.getNearbyFacilities(
          query: state.displayName,
          type: type,
          radius: state.radiusMeters,
        );
      }

      state = state.copyWith(
        facilities: _applySort(list, state.sortBy),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load healthcare facilities right now. Please try again.',
      );
    }
  }

  /// Change Search Radius (5km, 10km, 25km) using existing coordinates
  Future<void> changeRadius(int radiusMeters) async {
    if (state.radiusMeters == radiusMeters && !state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      radiusMeters: radiusMeters,
    );

    try {
      List<FacilityModel> list;
      if (state.latitude != null && state.longitude != null) {
        list = await _repository.getNearbyFacilities(
          latitude: state.latitude,
          longitude: state.longitude,
          type: state.activeType,
          radius: radiusMeters,
        );
      } else {
        list = await _repository.getNearbyFacilities(
          query: state.displayName,
          type: state.activeType,
          radius: radiusMeters,
        );
      }

      state = state.copyWith(
        facilities: _applySort(list, state.sortBy),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load healthcare facilities for this radius. Please try again.',
      );
    }
  }

  void setSortBy(String sort) {
    state = state.copyWith(
      sortBy: sort,
      facilities: _applySort(state.facilities, sort),
    );
  }

  List<FacilityModel> _applySort(List<FacilityModel> items, String sortBy) {
    final sorted = List<FacilityModel>.from(items);
    if (sortBy == 'name') {
      sorted.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortBy == 'rating') {
      sorted.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
    } else {
      sorted.sort((a, b) => a.distance.compareTo(b.distance));
    }
    return sorted;
  }
}

extension on String {
  String get titleCase {
    if (isEmpty) return this;
    return split(' ')
        .map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '')
        .join(' ');
  }
}

final nearbyCareProvider =
    StateNotifierProvider<NearbyCareNotifier, NearbyCareState>((ref) {
  final repo = ref.watch(nearbyCareRepositoryProvider);
  return NearbyCareNotifier(repo);
});

