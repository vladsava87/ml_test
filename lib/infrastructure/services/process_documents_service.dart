import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ml_test/domain/interfaces/services/i_process_documents_service.dart';
import 'package:ml_test/domain/interfaces/services/i_pdf_service.dart';
import 'package:get/get.dart';

class ProcessDocumentsService implements IProcessDocumentsService {
  static const MethodChannel _channel = MethodChannel(
    'com.vladsava.ml_test/document_processing',
  );

  @override
  Future<String?> processDocument(
    String imagePath, {
    List<Offset>? points,
    Size? streamSize,
  }) async {
    try {
      final List<Map<String, double>>? serializedPoints = points
          ?.map((p) => {'x': p.dx, 'y': p.dy})
          .toList();

      final Uint8List? processedImageBytes = await _channel
          .invokeMethod<Uint8List>('processDocument', {
            'imagePath': imagePath,
            'points': serializedPoints,
            'streamWidth': streamSize?.width,
            'streamHeight': streamSize?.height,
          });

      if (processedImageBytes == null) return null;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/temp_processed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(processedImageBytes);

      final pdfService = Get.find<IPdfService>();
      final String pdfPath = await pdfService.createPdfFromImage(tempFile);

      return pdfPath;
    } on PlatformException catch (e) {
      debugPrint('ProcessDocumentsService error: ${e.message}');
      return null;
    }
  }
}
