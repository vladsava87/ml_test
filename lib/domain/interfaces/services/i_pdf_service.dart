import 'dart:io';

abstract class IPdfService {
  Future<String> createPdfFromImage(File imageFile, {String? extractedText});
}
