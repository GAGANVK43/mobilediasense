import 'dart:io';
import '../../data/models/food_analysis_model.dart';

abstract class FoodRepository {
  Future<FoodAnalysisModel> analyzeText(String query);
  Future<FoodAnalysisModel> analyzeImage(File imageFile);
}
