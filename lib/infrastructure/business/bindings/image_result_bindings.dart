import 'package:ml_test/infrastructure/business/controllers/results/image_result_controller.dart';
import 'package:get/get.dart';

class ImageResultBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageResultController>(() => ImageResultController());
  }
}
