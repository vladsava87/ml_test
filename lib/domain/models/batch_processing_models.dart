import 'package:ml_test/domain/enums/e_batch_item_status.dart';
import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/domain/enums/e_batch_item_step.dart';

class BatchItem {
  final String id;
  final String originalPath;
  EBatchItemStatus status;
  EImageType? detectedType;
  String? resultPath;
  String? errorMessage;
  String? extractedText;
  EBatchItemStep? currentStep;

  BatchItem({
    required this.id,
    required this.originalPath,
    this.status = EBatchItemStatus.pending,
    this.detectedType,
    this.resultPath,
    this.errorMessage,
    this.extractedText,
    this.currentStep,
  });

  BatchItem copyWith({
    EBatchItemStatus? status,
    EImageType? detectedType,
    String? resultPath,
    String? errorMessage,
    String? extractedText,
    EBatchItemStep? currentStep,
  }) {
    return BatchItem(
      id: id,
      originalPath: originalPath,
      status: status ?? this.status,
      detectedType: detectedType ?? this.detectedType,
      resultPath: resultPath ?? this.resultPath,
      errorMessage: errorMessage ?? this.errorMessage,
      extractedText: extractedText ?? this.extractedText,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
