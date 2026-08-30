import '../models/prediction_model.dart';
import '../datasources/prediction_remote_datasource.dart';
import '../../domain/repositories/prediction_repository.dart';

class PredictionRepositoryImpl implements PredictionRepository {
  final PredictionRemoteDataSource _remoteDataSource;

  PredictionRepositoryImpl(this._remoteDataSource);

  @override
  Future<PredictionResultModel> getLatestPrediction() => _remoteDataSource.getLatestPrediction();

  @override
  Future<List<PredictionResultModel>> getPredictionHistory() => _remoteDataSource.getPredictionHistory();

  @override
  Future<Map<String, dynamic>> getModelAccuracy() => _remoteDataSource.getModelAccuracy();
}
