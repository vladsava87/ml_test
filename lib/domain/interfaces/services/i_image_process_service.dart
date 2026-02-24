import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

abstract class IImageProcessService {
  Future<String?> applyFaceBw({
    required File file,
    required List<Face> faces,
    double padFactor = 0.06,
    double featherSigma = 6.0,
  });

  Future<File?> normalizeImage(File file);
}
