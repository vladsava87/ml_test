import 'dart:io';
import 'package:ml_test/domain/enums/e_batch_item_status.dart';
import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/domain/models/batch_processing_models.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchItemTile extends StatelessWidget {
  final BatchItem item;
  const BatchItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(item.originalPath),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text('${AppStrings.item.tr} ${item.id}'),
      subtitle: _buildSubtitle(),
      trailing: _buildTrailing(),
    );
  }

  Widget _buildSubtitle() {
    switch (item.status) {
      case EBatchItemStatus.pending:
        return Text(AppStrings.pending.tr);
      case EBatchItemStatus.processing:
        return Text(
          item.currentStep?.localizedString ?? AppStrings.processing.tr,
          style: const TextStyle(color: Colors.blue),
        );
      case EBatchItemStatus.done:
        final typeStr = item.detectedType?.name ?? AppStrings.unknown.tr;
        return Text(
          '${AppStrings.done.tr}: $typeStr',
          style: TextStyle(
            color: item.detectedType == EImageType.unknown
                ? Colors.red
                : Colors.green,
          ),
        );
      case EBatchItemStatus.error:
        return Text(
          '${AppStrings.error.tr}: ${item.errorMessage}',
          style: const TextStyle(color: Colors.red),
        );
    }
  }

  Widget _buildTrailing() {
    switch (item.status) {
      case EBatchItemStatus.pending:
        return const Icon(Icons.hourglass_empty);
      case EBatchItemStatus.processing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case EBatchItemStatus.done:
        if (item.detectedType == EImageType.unknown) {
          return const Icon(Icons.error, color: Colors.red);
        }
        return const Icon(Icons.check_circle, color: Colors.green);
      case EBatchItemStatus.error:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}
