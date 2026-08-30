import '../../data/models/prediction_model.dart';

abstract class PredictionRepository {
  Future<PredictionResultModel> createPrediction(Map<String, dynamic> data);
  Future<PredictionResultModel> getLatestPrediction();
  Future<List<PredictionResultModel>> getPredictionHistory();
  Future<Map<String, dynamic>> getModelAccuracy();
}
