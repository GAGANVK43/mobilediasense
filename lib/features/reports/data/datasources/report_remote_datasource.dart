import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class ReportRemoteDataSource {
  Future<File> downloadPdfReport(int predictionId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final DioClient _client;

  ReportRemoteDataSourceImpl(this._client);

  @override
  Future<File> downloadPdfReport(int predictionId) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = predictionId > 0
        ? 'DiaSense_Diabetes_Report_$predictionId.pdf'
        : 'DiaSense_Diabetes_Report_latest.pdf';
    final filePath = '${tempDir.path}/$fileName';

    final options = Options(
      responseType: ResponseType.bytes,
      headers: {
        'Accept': 'application/pdf',
      },
    );

    try {
      final endpoint = predictionId > 0
          ? ApiEndpoints.reportPdf(predictionId)
          : '/api/reports/latest/pdf';
      await _client.dio.download(
        endpoint,
        filePath,
        options: options,
      );
    } catch (_) {
      // If specific ID fails, automatically download latest assessment report
      await _client.dio.download(
        '/api/reports/latest/pdf',
        filePath,
        options: options,
      );
    }

    final file = File(filePath);
    if (!await file.exists() || await file.length() == 0) {
      throw Exception('Failed to write PDF file to device storage.');
    }

    return file;
  }
}
