import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/diet_remote_datasource.dart';
import '../../data/repositories/diet_repository_impl.dart';
import '../../domain/repositories/diet_repository.dart';
import '../../data/models/diet_model.dart';

final dietRepositoryProvider = Provider<DietRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final remote = DietRemoteDataSourceImpl(dio);
  return DietRepositoryImpl(remote);
});

final latestDietPlanProvider = FutureProvider.autoDispose<DietPlanModel>((ref) async {
  final repo = ref.watch(dietRepositoryProvider);
  return await repo.getLatestDietPlan();
});
