import 'package:ml_test/presentation/controllers/file_processing/batch_process_controller.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/presentation/widgets/batch_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchProcessPage extends GetView<BatchProcessController> {
  const BatchProcessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop && context.mounted) {
          controller.stopProcess();
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.batchProcessing.tr),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _showExitConfirmation(context);
              if (shouldPop) {
                controller.stopProcess();
                Get.back();
              }
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => Text(
                  AppStrings.processingItemsProgress.trParams({
                    'count': controller.files.length.toString(),
                    'percent': (controller.currentProgress.value * 100)
                        .toInt()
                        .toString(),
                  }),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(
                () => LinearProgressIndicator(
                  value: controller.currentProgress.value,
                  minHeight: 4,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.batchItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.batchItems[index];
                    return BatchItemTile(item: item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.confirmExit.tr),
            content: Text(AppStrings.batchProcessingInProgress.tr),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppStrings.stay.tr),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  AppStrings.leave.tr,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
