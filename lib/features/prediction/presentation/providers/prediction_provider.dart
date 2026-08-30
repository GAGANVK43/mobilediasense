import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/prediction_remote_datasource.dart';
import '../../data/repositories/prediction_repository_impl.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../../data/models/prediction_model.dart';

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final remote = PredictionRemoteDataSourceImpl(dio);
  return PredictionRepositoryImpl(remote);
});

final latestPredictionProvider = FutureProvider.autoDispose<PredictionResultModel>((ref) async {
  final repo = ref.watch(predictionRepositoryProvider);
  return await repo.getLatestPrediction();
});

final predictionHistoryProvider = FutureProvider.autoDispose<List<PredictionResultModel>>((ref) async {
  final repo = ref.watch(predictionRepositoryProvider);
  return await repo.getPredictionHistory();
});
