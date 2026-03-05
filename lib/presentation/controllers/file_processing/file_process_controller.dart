import 'dart:io';
import 'dart:ui' as ui;
import 'package:ml_test/domain/enums/e_face_detector_profie.dart';
import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/domain/helpers/image_helpers.dart';
import 'package:ml_test/domain/models/processed_file_model.dart';
import 'package:ml_test/presentation/controllers/home_controller.dart';
import 'package:ml_test/infrastructure/constants/app_navigation_args.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/domain/interfaces/data/i_processed_file_repository.dart';
import 'package:ml_test/domain/interfaces/services/i_image_ml_service.dart';
import 'package:ml_test/domain/interfaces/services/i_image_process_service.dart';
import 'package:ml_test/domain/interfaces/services/i_process_documents_service.dart';
import 'package:ml_test/domain/interfaces/services/i_text_ml_service.dart';
import 'package:ml_test/presentation/router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileProcessController extends GetxController {
  final textMl = Get.find<ITextMlService>();
  final imageMl = Get.find<IImageMlService>();
  final imageProcess = Get.find<IImageProcessService>();
  final processService = Get.find<IProcessDocumentsService>();

  final detectedType = EImageType.unknown.obs;
  final isProcessing = false.obs;
  final currentStep = AppStrings.startingProcess.tr.obs;

  final resultPath = RxnString();
  final extractedText = RxnString();
  bool _isStopped = false;
  final IProcessedFileRepository _repository;

  late final File originalFile;
  late HomeController _mainController;

  FileProcessController(this._repository);

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    originalFile = args[AppNavigationArgs.keyFile] as File;

    _mainController = Get.find<HomeController>();
  }

  @override
  void onReady() {
    super.onReady();
    _startProcessingAndNavigate();
  }

  Future<void> _startProcessingAndNavigate() async {
    try {
      final docType = await process();

      refreshMainController();
      if (docType == EImageType.person) {
        Get.offNamed(
          AppRouter.imageResult,
          arguments: AppNavigationArgs.imageResult(
            originalFile: originalFile,
            processedFile: resultPath.value != null
                ? File(resultPath.value!)
                : null,
          ),
        );
      } else if (docType == EImageType.document) {
        Get.offNamed(
          AppRouter.documentResult,
          arguments: AppNavigationArgs.documentResult(
            originalFile: originalFile,
            foundText: extractedText.value,
            pdfPath: resultPath.value,
          ),
        );
      } else if (docType == EImageType.unknown) {
        if (_isStopped) {
          Get.back();
          return;
        }

        Get.back();
        Get.snackbar(
          AppStrings.unknownType.tr,
          AppStrings.couldNotClassifyImage.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.deepPurpleAccent.shade100,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        AppStrings.error.tr,
        '${AppStrings.processingErrorPrefix.tr}$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.deepPurpleAccent.shade100,
        colorText: Colors.white,
      );
    }
  }

  void stopProcess() {
    _isStopped = true;
  }

  void refreshMainController() {
    _mainController.loadRecent();
  }

  Future<EImageType> process() async {
    isProcessing.value = true;
    detectedType.value = EImageType.unknown;
    resultPath.value = null;
    extractedText.value = null;

    try {
      currentStep.value = AppStrings.normalizingImage.tr;
      final normalizedFile = await imageProcess.normalizeImage(originalFile);
      final processingFile = normalizedFile ?? originalFile;

      if (_isStopped) return EImageType.unknown;

      currentStep.value = AppStrings.analyzingImage.tr;
      final faces = await imageMl.detectFacesFromFile(
        processingFile,
        EFaceDetectorProfie.accurate,
      );

      if (_isStopped) return EImageType.unknown;

      if (faces.isNotEmpty) {
        detectedType.value = EImageType.person;
        currentStep.value = AppStrings.applyingBwFilter.tr;
        final processedPath = await imageProcess.applyFaceBw(
          file: originalFile,
          faces: faces,
        );
        if (_isStopped) {
          return EImageType.unknown;
        }

        if (processedPath != null) {
          final sizeBytes = await File(processedPath).length();
          final thumbnailBytes = await ImageHelpers.extractThumbnail(
            originalFile,
          );

          var newFile = ProcessedFileModel(
            filename: originalFile.path.split('/').last,
            originalPath: originalFile.path,
            processedPath: processedPath,
            createdAt: DateTime.now(),
            type: EImageType.person,
            thumbnailBytes: thumbnailBytes,
            sizeBytes: sizeBytes,
          );

          try {
            currentStep.value = AppStrings.savingResult.tr;
            await _repository.save(newFile);
          } catch (e) {
            Get.snackbar(
              AppStrings.error.tr,
              '${AppStrings.failedToSaveResult.tr}$e',
              backgroundColor: Colors.deepPurpleAccent.shade100,
              colorText: Colors.white,
            );
          }
        }

        resultPath.value = processedPath;
        return detectedType.value;
      }

      currentStep.value = AppStrings.recognizingText.tr;
      final recognized = await textMl.recognizeTextFromFile(processingFile);
      if (_isStopped) return EImageType.unknown;
      final text = recognized.text.trim();

      final hasDocText = text.length >= 30 || recognized.blocks.length >= 2;
      if (hasDocText) {
        detectedType.value = EImageType.document;
        extractedText.value = text;

        currentStep.value = AppStrings.calculatingBounds.tr;
        List<ui.Offset>? textBounds;
        if (recognized.blocks.isNotEmpty) {
          double? minX, minY, maxX, maxY;
          for (final block in recognized.blocks) {
            final rect = block.boundingBox;
            minX = minX == null
                ? rect.left
                : (rect.left < minX ? rect.left : minX);
            minY = minY == null
                ? rect.top
                : (rect.top < minY ? rect.top : minY);
            maxX = maxX == null
                ? rect.right
                : (rect.right > maxX ? rect.right : maxX);
            maxY = maxY == null
                ? rect.bottom
                : (rect.bottom > maxY ? rect.bottom : maxY);
          }

          if (minX != null && minY != null && maxX != null && maxY != null) {
            const padding = 40.0;
            textBounds = [
              ui.Offset(minX - padding, minY - padding),
              ui.Offset(maxX + padding, minY - padding),
              ui.Offset(maxX + padding, maxY + padding),
              ui.Offset(minX - padding, maxY + padding),
            ];
          }
        }

        currentStep.value = AppStrings.processingDocument.tr;
        final pdfPath = await processService.processDocument(
          processingFile.path,
          points: textBounds,
        );
        if (_isStopped) return EImageType.unknown;

        if (pdfPath != null) {
          final sizeBytes = await File(pdfPath).length();

          var newFile = ProcessedFileModel(
            filename: originalFile.path.split('/').last,
            originalPath: originalFile.path,
            processedPath: pdfPath,
            createdAt: DateTime.now(),
            type: EImageType.document,
            sizeBytes: sizeBytes,
            ocrText: text,
          );

          try {
            currentStep.value = AppStrings.savingResult.tr;
            await _repository.save(newFile);
          } catch (e) {
            Get.snackbar(
              AppStrings.error.tr,
              '${AppStrings.failedToSaveResult.tr}$e',
              backgroundColor: Colors.deepPurpleAccent.shade100,
              colorText: Colors.white,
            );
          }
        }

        resultPath.value = pdfPath;
        return detectedType.value;
      }

      detectedType.value = EImageType.unknown;

      isProcessing.value = false;
      return detectedType.value;
    } finally {
      isProcessing.value = false;
    }
  }
}
