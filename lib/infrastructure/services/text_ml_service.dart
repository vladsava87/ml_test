import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ml_test/domain/interfaces/services/i_text_ml_service.dart';

class TextMlService implements ITextMlService {
  final TextRecognizer _textRecognizer;

  TextMlService()
    : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool _busyText = false;

  @override
  Future<RecognizedText> recognizeTextFromFile(
    File file, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (_busyText) {
      return RecognizedText(text: '', blocks: const []);
    }
    _busyText = true;
    try {
      final input = InputImage.fromFile(file);
      return await _textRecognizer.processImage(input).timeout(timeout);
    } finally {
      _busyText = false;
    }
  }
}
