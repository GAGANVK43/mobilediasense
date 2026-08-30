import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/food_remote_datasource.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../domain/repositories/food_repository.dart';
import '../../data/models/food_analysis_model.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final remote = FoodRemoteDataSourceImpl(dio);
  return FoodRepositoryImpl(remote);
});

class FoodAnalysisState {
  final bool isLoading;
  final FoodAnalysisModel? result;
  final String? errorMessage;
  final File? selectedImage;

  const FoodAnalysisState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
    this.selectedImage,
  });

  FoodAnalysisState copyWith({
    bool? isLoading,
    FoodAnalysisModel? result,
    String? errorMessage,
    File? selectedImage,
  }) {
    return FoodAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

class FoodAnalysisNotifier extends StateNotifier<FoodAnalysisState> {
  final FoodRepository _repository;

  FoodAnalysisNotifier(this._repository) : super(const FoodAnalysisState());

  Future<void> analyzeMealText(String query) async {
    if (query.trim().isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final res = await _repository.analyzeText(query.trim());
      state = state.copyWith(isLoading: false, result: res);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> analyzeImage(File image) async {
    state = state.copyWith(isLoading: true, errorMessage: null, selectedImage: image);

    try {
      final res = await _repository.analyzeImage(image);
      state = state.copyWith(isLoading: false, result: res);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
      );
    }
  }

  void reset() {
    state = const FoodAnalysisState();
  }
}

final foodAnalysisProvider =
    StateNotifierProvider<FoodAnalysisNotifier, FoodAnalysisState>((ref) {
  final repo = ref.watch(foodRepositoryProvider);
  return FoodAnalysisNotifier(repo);
});
