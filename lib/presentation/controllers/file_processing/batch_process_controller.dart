import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:ml_test/domain/enums/e_batch_item_status.dart';
import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/domain/helpers/image_helpers.dart';
import 'package:ml_test/domain/models/batch_processing_models.dart';
import 'package:ml_test/domain/enums/e_batch_item_step.dart';
import 'package:ml_test/domain/models/processed_file_model.dart';
import 'package:ml_test/infrastructure/constants/app_navigation_args.dart';
import 'package:ml_test/domain/interfaces/data/i_processed_file_repository.dart';
import 'package:ml_test/domain/interfaces/services/i_batch_process_service.dart';
import 'package:ml_test/presentation/router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchProcessController extends GetxController {
  late List<File> files;
  final batchItems = <BatchItem>[].obs;
  final isFinished = false.obs;
  final currentProgress = 0.0.obs;

  final _service = Get.find<IBatchProcessService>();
  final IProcessedFileRepository _repository;

  BatchProcessController(this._repository);

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    files = args[AppNavigationArgs.keyFiles] as List<File>;

    _initializeItems();
    _startProcess();

    ever(isFinished, (finished) {
      if (finished) {
        Get.offNamed(
          AppRouter.batchSummary,
          arguments: AppNavigationArgs.batchSummary(processedItems: batchItems),
        );
      }
    });
  }

  void _initializeItems() {
    batchItems.value = files.asMap().entries.map((entry) {
      return BatchItem(
        id: entry.key.toString(),
        originalPath: entry.value.path,
      );
    }).toList();
  }

  void _startProcess() {
    _service.startBatchProcess(files).listen((event) {
      final type = event['type'];
      if (type == 'status') {
        _updateItemStatus(
          event['index'],
          event['status'],
          error: event['error'],
        );
      } else if (type == 'step') {
        final stepEnum = EBatchItemStep.values.byName(event['step'] as String);
        _updateItemStep(event['index'], stepEnum);
      } else if (type == 'result') {
        _updateItemResult(
          event['index'],
          event['detectedType'],
          event['resultPath'],
          event['extractedText'],
        );

        _insertIntoRepository(batchItems[event['index']]);
      } else if (type == 'complete') {
        isFinished.value = true;
      }

      _updateProgress();
    });
  }

  void _updateItemStatus(int index, EBatchItemStatus status, {String? error}) {
    batchItems[index] = batchItems[index].copyWith(
      status: status,
      errorMessage: error,
    );
  }

  void _updateItemStep(int index, EBatchItemStep step) {
    batchItems[index] = batchItems[index].copyWith(currentStep: step);
  }

  void _updateItemResult(
    int index,
    EImageType type,
    String? resultPath,
    String? extractedText,
  ) {
    batchItems[index] = batchItems[index].copyWith(
      status: EBatchItemStatus.done,
      detectedType: type,
      resultPath: resultPath,
      extractedText: extractedText,
    );
  }

  void _updateProgress() {
    int doneOrError = batchItems
        .where(
          (item) =>
              item.status == EBatchItemStatus.done ||
              item.status == EBatchItemStatus.error,
        )
        .length;
    currentProgress.value = doneOrError / batchItems.length;
  }

  void stopProcess() {
    _service.stop();
  }

  void _insertIntoRepository(BatchItem batchItem) async {
    if (batchItem.resultPath == null ||
        batchItem.detectedType == EImageType.unknown) {
      return;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final sizeBytes = await File(batchItem.resultPath!).length();
    final originalFile = File(batchItem.originalPath);

    final extOriginal = batchItem.originalPath.split('.').last;
    final persistentOrigPath =
        '${docsDir.path}/orig_${timestamp}_${batchItem.id}.$extOriginal';
    await originalFile.copy(persistentOrigPath);

    if (batchItem.detectedType == EImageType.document) {
      var newFile = ProcessedFileModel(
        filename: batchItem.originalPath.split('/').last,
        originalPath: persistentOrigPath,
        processedPath: batchItem.resultPath!,
        createdAt: DateTime.now(),
        type: EImageType.document,
        sizeBytes: sizeBytes,
        ocrText: batchItem.extractedText!,
      );

      try {
        _repository.save(newFile);
      } catch (e) {
        debugPrint('Error saving processed document: $e');
      }
    } else if (batchItem.detectedType == EImageType.person) {
      final thumbnailBytes = await ImageHelpers.extractThumbnail(originalFile);

      final persistentProcPath =
          '${docsDir.path}/face_bw_${timestamp}_${batchItem.id}.jpg';
      await File(batchItem.resultPath!).copy(persistentProcPath);

      var newFile = ProcessedFileModel(
        filename: batchItem.originalPath.split('/').last,
        originalPath: persistentOrigPath,
        processedPath: persistentProcPath,
        createdAt: DateTime.now(),
        type: EImageType.person,
        sizeBytes: sizeBytes,
        thumbnailBytes: thumbnailBytes,
      );

      try {
        _repository.save(newFile);
      } catch (e) {
        debugPrint('Error saving processed document: $e');
      }
    }
  }
}
