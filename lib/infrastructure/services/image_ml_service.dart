import 'dart:io';
import 'package:ml_test/domain/enums/e_face_detector_profie.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:ml_test/domain/interfaces/services/i_image_ml_service.dart';

class ImageMlService implements IImageMlService {
  final Map<EFaceDetectorProfie, FaceDetector> _faceDetectors = {};

  ImageMlService();

  bool _busyFace = false;

  @override
  Future<List<Face>> detectFacesFromFile(
    File file,
    EFaceDetectorProfie profile, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_busyFace) return const [];
    _busyFace = true;
    try {
      final input = InputImage.fromFile(file);
      return await _getFaceDetector(
        profile,
      ).processImage(input).timeout(timeout);
    } finally {
      _busyFace = false;
    }
  }

  FaceDetector _getFaceDetector(EFaceDetectorProfie profile) {
    if (_faceDetectors.containsKey(profile)) {
      return _faceDetectors[profile]!;
    }

    final options = switch (profile) {
      EFaceDetectorProfie.fast => FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: false,
        enableContours: false,
      ),
      EFaceDetectorProfie.accurate => FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
      ),
    };

    final detector = FaceDetector(options: options);
    _faceDetectors[profile] = detector;
    return detector;
  }
}
