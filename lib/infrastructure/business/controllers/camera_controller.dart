import 'dart:io';
import 'package:camera/camera.dart' as camera;
import 'package:get/get.dart';

class CameraController extends GetxController {
  final cameraController = Rxn<camera.CameraController>();
  final isInitialized = false.obs;
  final isCapturing = false.obs;

  camera.CameraLensDirection currentLens = camera.CameraLensDirection.back;

  Future<void> initCamera({
    camera.CameraLensDirection lens = camera.CameraLensDirection.back,
  }) async {
    final cameras = await camera.availableCameras();

    final selected = cameras.firstWhere(
      (c) => c.lensDirection == lens,
      orElse: () => cameras.first,
    );

    final controller = camera.CameraController(
      selected,
      camera.ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();

    cameraController.value?.dispose();
    cameraController.value = controller;

    currentLens = lens;
    isInitialized.value = true;
  }

  Future<File?> takePicture() async {
    final controller = cameraController.value;
    if (controller == null || !controller.value.isInitialized) return null;

    if (isCapturing.value) return null;

    try {
      isCapturing.value = true;
      final camera.XFile file = await controller.takePicture();
      return File(file.path);
    } catch (_) {
      return null;
    } finally {
      isCapturing.value = false;
    }
  }

  @override
  void onClose() {
    cameraController.value?.dispose();
    super.onClose();
  }
}
