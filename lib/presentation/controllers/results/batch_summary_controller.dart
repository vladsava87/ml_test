import 'package:ml_test/domain/models/batch_processing_models.dart';
import 'package:ml_test/presentation/controllers/home_controller.dart';
import 'package:ml_test/infrastructure/constants/app_navigation_args.dart';
import 'package:ml_test/domain/interfaces/data/i_processed_file_repository.dart';
import 'package:get/get.dart';

class BatchSummaryController extends GetxController {
  late List<BatchItem> processedItems;
  late HomeController _mainController;

  @override
  void onClose() {
    super.onClose();
    processedItems.clear();
  }

  @override
  void onInit() {
    super.onInit();

    processedItems =
        (Get.arguments
                as Map<String, dynamic>)[AppNavigationArgs.keyProcessedItems]
            as List<BatchItem>;

    _mainController = Get.put(
      HomeController(Get.find<IProcessedFileRepository>()),
    );
  }

  void refreshMainController() {
    _mainController.loadRecent();
  }
}
