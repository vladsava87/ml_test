import 'package:camera/camera.dart' as camera;
import 'package:ml_test/presentation/controllers/camera_controller.dart';
import 'package:ml_test/infrastructure/constants/app_navigation_args.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/presentation/router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraPage extends GetView<CameraController> {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initCamera().catchError(
      (_) => Get.snackbar(
        AppStrings.error.tr,
        AppStrings.failedToInitCamera.tr,
        backgroundColor: Colors.deepPurpleAccent.shade100,
        colorText: Colors.white,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (!controller.isInitialized.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  const CircularProgressIndicator(),
                  Text(AppStrings.initializingCamera.tr),
                ],
              ),
            );
          }

          final cameraController = controller.cameraController.value!;
          return Stack(
            children: [
              Positioned.fill(child: camera.CameraPreview(cameraController)),

              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),

              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final file = await controller.takePicture();
                        if (file != null) {
                          Get.back();
                          Get.toNamed(
                            AppRouter.fileProcess,
                            arguments: AppNavigationArgs.fileProcess(
                              file: file,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
