import 'package:before_after/before_after.dart';
import 'package:ml_test/presentation/controllers/results/image_result_controller.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/presentation/widgets/image_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageResultPage extends GetView<ImageResultController> {
  const ImageResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.faceResult.tr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: controller.processedFile != null
                    ? Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: BeforeAfter(
                                value: controller.beforeAfterSlider.value,
                                before: Image.file(
                                  controller.processedFile!,
                                  fit: BoxFit.cover,
                                ),
                                after: Image.file(
                                  controller.originalFile,
                                  fit: BoxFit.cover,
                                ),
                                onValueChanged: (val) =>
                                    controller.beforeAfterSlider.value = val,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ImageCard(
                              title: AppStrings.before.tr,
                              child: Image.file(
                                controller.originalFile,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ImageCard(
                              title: AppStrings.after.tr,
                              child: Center(
                                child: Text(AppStrings.noEnhancementApplied.tr),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isProcessing.value
                        ? null
                        : () => Get.back(),
                    child: Text(AppStrings.done.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
