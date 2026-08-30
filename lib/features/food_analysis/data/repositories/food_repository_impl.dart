import 'dart:io';
import '../models/food_analysis_model.dart';
import '../datasources/food_remote_datasource.dart';
import '../../domain/repositories/food_repository.dart';

class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource _remoteDataSource;

  FoodRepositoryImpl(this._remoteDataSource);

  @override
  Future<FoodAnalysisModel> analyzeText(String query) => _remoteDataSource.analyzeText(query);

  @override
  Future<FoodAnalysisModel> analyzeImage(File imageFile) => _remoteDataSource.analyzeImage(imageFile);
}
