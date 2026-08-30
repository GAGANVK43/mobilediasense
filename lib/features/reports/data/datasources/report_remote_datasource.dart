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
    final filePath = '/DiaSense_Report_.pdf';

    await _client.dio.download(
      ApiEndpoints.reportPdf(predictionId),
      filePath,
    );

    return File(filePath);
  }
}
