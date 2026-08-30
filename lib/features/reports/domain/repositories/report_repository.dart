import 'dart:io';

abstract class ReportRepository {
  Future<File> downloadPdfReport(int predictionId);
}
