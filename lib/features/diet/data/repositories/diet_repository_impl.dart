import '../models/diet_model.dart';
import '../datasources/diet_remote_datasource.dart';
import '../../domain/repositories/diet_repository.dart';

class DietRepositoryImpl implements DietRepository {
  final DietRemoteDataSource _remoteDataSource;

  DietRepositoryImpl(this._remoteDataSource);

  @override
  Future<DietPlanModel> getLatestDietPlan() => _remoteDataSource.getLatestDietPlan();

  @override
  Future<DietPlanModel> getDietPlanByPrediction(int predictionId) =>
      _remoteDataSource.getDietPlanByPrediction(predictionId);
}
