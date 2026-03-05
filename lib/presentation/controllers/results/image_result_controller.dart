import 'dart:io';
import 'package:ml_test/infrastructure/constants/app_navigation_args.dart';
import 'package:get/get.dart';

class ImageResultController extends GetxController {
  late File originalFile;
  late File? processedFile;

  final isProcessing = false.obs;
  final beforeAfterSlider = 0.5.obs;

  ImageResultController();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    originalFile = args[AppNavigationArgs.keyOriginalFile] as File;
    processedFile = args[AppNavigationArgs.keyProcessedFile] as File?;
  }
}
