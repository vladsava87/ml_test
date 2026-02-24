import 'package:ml_test/infrastructure/business/controllers/history_controller.dart';
import 'package:get/get.dart';

class HistoryBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(HistoryController());
  }
}
