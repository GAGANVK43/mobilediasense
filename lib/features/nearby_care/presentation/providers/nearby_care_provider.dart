import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class NearbyCareState {
  final List<FacilityModel> facilities;
  final bool isLoading;
  final String? error;
  final String activeType;
  final String searchQuery;

  const NearbyCareState({
    this.facilities = const [],
    this.isLoading = false,
    this.error,
    this.activeType = 'hospital',
    this.searchQuery = 'Bengaluru',
  });

  NearbyCareState copyWith({
    List<FacilityModel>? facilities,
    bool? isLoading,
    String? error,
    String? activeType,
    String? searchQuery,
  }) {
    return NearbyCareState(
      facilities: facilities ?? this.facilities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeType: activeType ?? this.activeType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class NearbyCareNotifier extends StateNotifier<NearbyCareState> {
  final NearbyCareRepository _repository;

  NearbyCareNotifier(this._repository) : super(const NearbyCareState()) {
    searchCare(query: 'Bengaluru');
  }

  Future<void> searchCare({String? query, String? type}) async {
    final searchType = type ?? state.activeType;
    final searchQ = query ?? state.searchQuery;

    state = state.copyWith(isLoading: true, error: null, activeType: searchType, searchQuery: searchQ);

    try {
      final list = await _repository.getNearbyFacilities(
        query: searchQ,
        type: searchType,
      );
      state = state.copyWith(facilities: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
      );
    }
  }
}

final nearbyCareProvider =
    StateNotifierProvider<NearbyCareNotifier, NearbyCareState>((ref) {
  final repo = ref.watch(nearbyCareRepositoryProvider);
  return NearbyCareNotifier(repo);
});
