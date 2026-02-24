import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class ITextMlService {
  Future<RecognizedText> recognizeTextFromFile(
    File file, {
    Duration timeout = const Duration(seconds: 8),
  });
}
