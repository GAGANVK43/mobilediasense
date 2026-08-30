import '../../data/models/diet_model.dart';

abstract class DietRepository {
  Future<DietPlanModel> getLatestDietPlan();
  Future<DietPlanModel> getDietPlanByPrediction(int predictionId);
}
