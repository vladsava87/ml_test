import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/domain/models/processed_file_model.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

class HistoryController extends GetxController {
  late final ProcessedFileModel item;

  final isOpeningPdf = false.obs;

  @override
  void onInit() {
    super.onInit();
    item = Get.arguments as ProcessedFileModel;
  }

  bool get isDocument => item.type == EImageType.document;

  bool get hasPdf =>
      isDocument &&
      item.processedPath.isNotEmpty &&
      item.processedPath.endsWith('.pdf');

  bool get hasProcessedImage => !isDocument && item.processedPath.isNotEmpty;

  bool get hasOcrText => isDocument && (item.ocrText?.isNotEmpty ?? false);

  String get typeLabel => switch (item.type) {
    EImageType.document => AppStrings.documentScan.tr,
    EImageType.person => AppStrings.faceProcessed.tr,
    EImageType.unknown => AppStrings.unknownType.tr,
  };

  String get fileSizeLabel {
    final bytes = item.sizeBytes;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get dateLabel => DateFormat.yMMMd().format(item.createdAt.toLocal());

  Future<void> openPdf() async {
    if (!hasPdf || isOpeningPdf.value) return;

    isOpeningPdf.value = true;
    try {
      final result = await OpenFilex.open(item.processedPath);
      if (result.type != ResultType.done) {
        Get.snackbar(
          AppStrings.error.tr,
          '${AppStrings.couldNotOpenPdf.tr}: ${result.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.deepPurpleAccent.shade100,
          colorText: Colors.white,
        );
      }
    } finally {
      isOpeningPdf.value = false;
    }
  }
}
