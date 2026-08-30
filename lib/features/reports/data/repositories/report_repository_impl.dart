import 'dart:io';
import '../datasources/report_remote_datasource.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl(this._remoteDataSource);

  @override
  Future<File> downloadPdfReport(int predictionId) {
    return _remoteDataSource.downloadPdfReport(predictionId);
  }
}
