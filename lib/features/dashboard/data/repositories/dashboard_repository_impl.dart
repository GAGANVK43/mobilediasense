import '../models/dashboard_model.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<DashboardDataModel> getDashboardData() {
    return _remoteDataSource.getDashboardData();
  }
}
