import 'package:ml_test/presentation/controllers/camera_controller.dart';
import 'package:get/get.dart';

class CameraBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraController>(() => CameraController());
  }
}
