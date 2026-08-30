import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final remote = ReportRemoteDataSourceImpl(dio);
  return ReportRepositoryImpl(remote);
});

class ReportDownloadState {
  final bool isDownloading;
  final String? downloadedPath;
  final String? error;

  const ReportDownloadState({
    this.isDownloading = false,
    this.downloadedPath,
    this.error,
  });
}

class ReportNotifier extends StateNotifier<ReportDownloadState> {
  final ReportRepository _repository;

  ReportNotifier(this._repository) : super(const ReportDownloadState());

  Future<void> downloadAndOpenPdf(int predictionId) async {
    state = const ReportDownloadState(isDownloading: true);
    try {
      final file = await _repository.downloadPdfReport(predictionId);
      state = ReportDownloadState(isDownloading: false, downloadedPath: file.path);
      await OpenFilex.open(file.path);
    } catch (e) {
      state = ReportDownloadState(
        isDownloading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final reportNotifierProvider =
    StateNotifierProvider<ReportNotifier, ReportDownloadState>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return ReportNotifier(repo);
});
