import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:get/get.dart';

enum EBatchItemStep {
  startingProcess,
  normalizingImage,
  analyzingImage,
  applyingBwFilter,
  recognizingText,
  calculatingBounds,
  processingDocument,
  savingResult,
  completed,
  error;

  String get localizedString {
    switch (this) {
      case EBatchItemStep.startingProcess:
        return AppStrings.startingProcess.tr;
      case EBatchItemStep.normalizingImage:
        return AppStrings.normalizingImage.tr;
      case EBatchItemStep.analyzingImage:
        return AppStrings.analyzingImage.tr;
      case EBatchItemStep.applyingBwFilter:
        return AppStrings.applyingBwFilter.tr;
      case EBatchItemStep.recognizingText:
        return AppStrings.recognizingText.tr;
      case EBatchItemStep.calculatingBounds:
        return AppStrings.calculatingBounds.tr;
      case EBatchItemStep.processingDocument:
        return AppStrings.processingDocument.tr;
      case EBatchItemStep.savingResult:
        return AppStrings.savingResult.tr;
      case EBatchItemStep.completed:
        return AppStrings.done.tr;
      case EBatchItemStep.error:
        return AppStrings.error.tr;
    }
  }
}
