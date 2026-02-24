import 'dart:io';
import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/domain/models/processed_file_model.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ImageViewer extends StatelessWidget {
  final ProcessedFileModel item;

  const ImageViewer({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    if (item.type == EImageType.document) {
      final hasOriginal =
          item.originalPath.isNotEmpty && File(item.originalPath).existsSync();
      return Stack(
        children: [
          if (hasOriginal)
            InteractiveViewer(
              child: Center(
                child: Image.file(File(item.originalPath), fit: BoxFit.contain),
              ),
            )
          else
            const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.white38,
                size: 64,
              ),
            ),
          if (item.ocrText != null && item.ocrText!.isNotEmpty)
            Positioned(
              bottom: 12,
              right: 12,
              child: FloatingActionButton.small(
                heroTag: 'ocrTextBtn',
                tooltip: AppStrings.viewExtractedText.tr,
                onPressed: () => _showOcrSheet(context),
                child: const Icon(Icons.text_snippet),
              ),
            ),
        ],
      );
    }

    final displayPath = File(item.processedPath).existsSync()
        ? item.processedPath
        : (item.originalPath.isNotEmpty && File(item.originalPath).existsSync()
              ? item.originalPath
              : null);

    if (displayPath == null) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white38, size: 64),
      );
    }

    return InteractiveViewer(
      child: Center(child: Image.file(File(displayPath), fit: BoxFit.contain)),
    );
  }

  void _showOcrSheet(BuildContext context) {
    final text = item.ocrText ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.extractedTextTitle.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: AppStrings.copyToClipboard.tr,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      Get.snackbar(
                        AppStrings.copied.tr,
                        AppStrings.textCopied.tr,
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.grey[400],
                        colorText: Colors.black87,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: ctrl,
                  child: SelectableText(text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
