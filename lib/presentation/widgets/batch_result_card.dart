import 'dart:io';
import 'package:ml_test/domain/enums/e_batch_item_status.dart';
import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/infrastructure/constants/app_navigation_args.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/presentation/router.dart';
import 'package:ml_test/presentation/constants/icon_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class BatchResultCard extends StatelessWidget {
  final dynamic item;
  const BatchResultCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _getImageWidget(item)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    switch (item.detectedType) {
                      EImageType.document => AppStrings.documentScan.tr,
                      EImageType.person => AppStrings.faceProcessed.tr,
                      EImageType.unknown => AppStrings.unknown.tr,
                      Object() => AppStrings.unknown.tr,
                      null => AppStrings.unknown.tr,
                    },
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: switch (item.detectedType) {
                        EImageType.document => Colors.black,
                        EImageType.person => Colors.black,
                        EImageType.unknown => Colors.red,
                        Object() => Colors.red,
                        null => Colors.red,
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (item.detectedType == EImageType.document && item.resultPath == null) {
      return;
    }
    if (item.status == EBatchItemStatus.error) return;

    if (item.detectedType == EImageType.document) {
      Get.toNamed(
        AppRouter.documentResult,
        arguments: AppNavigationArgs.documentResult(
          originalFile: File(item.originalPath),
          foundText: item.extractedText,
          pdfPath: item.resultPath,
        ),
      );
    } else if (item.detectedType == EImageType.person) {
      Get.toNamed(
        AppRouter.imageResult,
        arguments: AppNavigationArgs.imageResult(
          originalFile: File(item.originalPath),
          processedFile: item.resultPath != null
              ? File(item.resultPath!)
              : null,
        ),
      );
    }
  }

  Widget _getImageWidget(dynamic item) {
    return switch (item.detectedType) {
      EImageType.document => Padding(
        padding: const EdgeInsets.all(24),
        child: SvgPicture.asset(IconConstants.pdfIcon, width: 50, height: 50),
      ),
      EImageType.person => Image.file(
        File(item.resultPath ?? item.originalPath),
        fit: BoxFit.cover,
      ),
      _ => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.help_outline, size: 40, color: Colors.grey),
        ),
      ),
    };
  }
}
