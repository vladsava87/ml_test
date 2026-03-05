import 'package:ml_test/presentation/controllers/file_processing/file_process_controller.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileProcessPage extends GetView<FileProcessController> {
  const FileProcessPage({super.key});

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
          title: Text(AppStrings.processingImage.tr),
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
        body: SafeArea(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Image.file(
                      controller.originalFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                Text(
                  controller.currentStep.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.confirmExit.tr),
            content: Text(AppStrings.imageProcessingInProgress.tr),
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
