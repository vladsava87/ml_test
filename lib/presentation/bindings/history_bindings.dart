import 'package:ml_test/presentation/controllers/history_controller.dart';
import 'package:get/get.dart';

class HistoryBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(HistoryController());
  }
}
