import 'dart:io';
import 'package:ml_test/domain/enums/e_face_detector_profie.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

abstract class IImageMlService {
  Future<List<Face>> detectFacesFromFile(
    File file,
    EFaceDetectorProfie profile, {
    Duration timeout = const Duration(seconds: 10),
  });
}
