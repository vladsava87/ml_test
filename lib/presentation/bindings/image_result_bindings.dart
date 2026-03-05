import 'package:ml_test/presentation/controllers/results/image_result_controller.dart';
import 'package:get/get.dart';

class ImageResultBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageResultController>(() => ImageResultController());
  }
}
