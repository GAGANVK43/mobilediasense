import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/models/dashboard_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final remote = DashboardRemoteDataSourceImpl(dio);
  return DashboardRepositoryImpl(remote);
});

final dashboardDataProvider = FutureProvider.autoDispose<DashboardDataModel>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return await repo.getDashboardData();
});
