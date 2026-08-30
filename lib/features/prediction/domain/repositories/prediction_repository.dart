import '../../data/models/prediction_model.dart';

abstract class PredictionRepository {
  Future<PredictionResultModel> getLatestPrediction();
  Future<List<PredictionResultModel>> getPredictionHistory();
  Future<Map<String, dynamic>> getModelAccuracy();
}
