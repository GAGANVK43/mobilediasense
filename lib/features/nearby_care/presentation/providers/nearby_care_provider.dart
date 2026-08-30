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

enum LocationState {
  initial,
  locating,
  gpsSuccess,
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  manualSearch,
}

class NearbyCareState {
  final List<FacilityModel> facilities;
  final bool isLoading;
  final String? error;
  final String activeType;
  final String searchQuery;
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
    this.searchQuery = 'Bengaluru',
    this.locationState = LocationState.initial,
    this.latitude,
    this.longitude,
    this.radiusMeters = 5000,
    this.sortBy = 'distance',
  });

  NearbyCareState copyWith({
    List<FacilityModel>? facilities,
    bool? isLoading,
    String? error,
    String? activeType,
    String? searchQuery,
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
      searchQuery: searchQuery ?? this.searchQuery,
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

  String _normalizeCity(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('bangalore') || lower.contains('bengaluru')) return 'Bengaluru';
    if (lower.contains('mysore') || lower.contains('mysuru')) return 'Mysuru';
    if (lower.contains('bombay') || lower.contains('mumbai')) return 'Mumbai';
    if (lower.contains('madras') || lower.contains('chennai')) return 'Chennai';
    if (lower.contains('calcutta') || lower.contains('kolkata')) return 'Kolkata';
    if (lower.contains('hubli') || lower.contains('hubballi')) return 'Hubballi';
    if (lower.contains('delhi') || lower.contains('new delhi')) return 'New Delhi';
    if (lower.contains('hyderabad') || lower.contains('secunderabad')) return 'Hyderabad';
    return raw.trim();
  }

  Future<void> initLocationAndSearch() async {
    // Attempt automatic GPS location first
    await searchByCurrentGps(silentFallback: true);
  }

  Future<void> searchByCurrentGps({bool silentFallback = false}) async {
    state = state.copyWith(isLoading: true, error: null, locationState: LocationState.locating);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          locationState: LocationState.serviceDisabled,
          error: silentFallback ? null : 'Location services (GPS) are disabled on your device. Please turn on GPS or search manually.',
        );
        if (silentFallback) await searchCare(query: 'Bengaluru', isManual: true);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            locationState: LocationState.permissionDenied,
            error: silentFallback ? null : 'Location permission was denied. You can search for your city or area manually.',
          );
          if (silentFallback) await searchCare(query: 'Bengaluru', isManual: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          locationState: LocationState.permissionDeniedForever,
          error: silentFallback ? null : 'Location permission is permanently denied in settings. Please enable it in App Settings or search manually.',
        );
        if (silentFallback) await searchCare(query: 'Bengaluru', isManual: true);
        return;
      }

      // Permission granted: Get device coordinates
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      final list = await _repository.getNearbyFacilities(
        latitude: position.latitude,
        longitude: position.longitude,
        type: state.activeType,
        radius: state.radiusMeters,
      );

      state = state.copyWith(
        facilities: _applySort(list, state.sortBy),
        isLoading: false,
        locationState: LocationState.gpsSuccess,
        latitude: position.latitude,
        longitude: position.longitude,
        searchQuery: 'My Current Location (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})',
      );
    } catch (e) {
      if (silentFallback) {
        await searchCare(query: 'Bengaluru', isManual: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not obtain GPS location (${e.toString().replaceAll('Exception: ', '')}). Try searching for your city manually.',
        );
      }
    }
  }

  Future<void> searchCare({
    String? query,
    String? type,
    int? radius,
    String? sortBy,
    bool isManual = false,
  }) async {
    final searchType = type ?? state.activeType;
    final searchQ = query != null ? _normalizeCity(query) : state.searchQuery;
    final rad = radius ?? state.radiusMeters;
    final sort = sortBy ?? state.sortBy;

    state = state.copyWith(
      isLoading: true,
      error: null,
      activeType: searchType,
      searchQuery: searchQ,
      radiusMeters: rad,
      sortBy: sort,
      locationState: isManual ? LocationState.manualSearch : state.locationState,
    );

    try {
      List<FacilityModel> list;
      if (!isManual && state.latitude != null && state.longitude != null && query == null) {
        // Query by coordinates
        list = await _repository.getNearbyFacilities(
          latitude: state.latitude,
          longitude: state.longitude,
          type: searchType,
          radius: rad,
        );
      } else {
        // Query by normalized city / area text
        list = await _repository.getNearbyFacilities(
          query: searchQ,
          type: searchType,
          radius: rad,
        );
      }

      state = state.copyWith(
        facilities: _applySort(list, sort),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
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
      // Default: distance
      sorted.sort((a, b) => a.distance.compareTo(b.distance));
    }
    return sorted;
  }
}

final nearbyCareProvider =
    StateNotifierProvider<NearbyCareNotifier, NearbyCareState>((ref) {
  final repo = ref.watch(nearbyCareRepositoryProvider);
  return NearbyCareNotifier(repo);
});

