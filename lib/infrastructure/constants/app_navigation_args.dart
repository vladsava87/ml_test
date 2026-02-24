import 'dart:io';
import 'package:ml_test/domain/models/batch_processing_models.dart';

class AppNavigationArgs {
  static const String keyFile = 'file';
  static const String keyFiles = 'files';
  static const String keyOriginalFile = 'originalFile';
  static const String keyProcessedFile = 'processedFile';
  static const String keyFoundText = 'foundText';
  static const String keyPdfPath = 'pdfPath';
  static const String keyProcessedItems = 'processedItems';

  static Map<String, dynamic> fileProcess({required File file}) {
    return {keyFile: file};
  }

  static Map<String, dynamic> batchProcess({required List<File> files}) {
    return {keyFiles: files};
  }

  static Map<String, dynamic> imageResult({
    required File originalFile,
    File? processedFile,
  }) {
    return {keyOriginalFile: originalFile, keyProcessedFile: processedFile};
  }

  static Map<String, dynamic> documentResult({
    required File originalFile,
    String? foundText,
    String? pdfPath,
  }) {
    return {
      keyOriginalFile: originalFile,
      keyFoundText: foundText,
      keyPdfPath: pdfPath,
    };
  }

  static Map<String, dynamic> batchSummary({
    required List<BatchItem> processedItems,
  }) {
    return {keyProcessedItems: processedItems};
  }
}
