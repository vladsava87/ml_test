import 'package:ml_test/infrastructure/business/controllers/history_controller.dart';
import 'package:ml_test/presentation/widgets/image_viewer.dart';
import 'package:ml_test/presentation/widgets/metadata_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          controller.item.filename,
          style: const TextStyle(fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ImageViewer(item: controller.item),
            ),
          ),
          MetadataPanel(
            typeLabel: controller.typeLabel,
            fileSizeLabel: controller.fileSizeLabel,
            dateLabel: controller.dateLabel,
            isOpeningPdf: controller.hasPdf ? controller.isOpeningPdf : null,
            onOpenPdf: controller.hasPdf ? controller.openPdf : null,
          ),
        ],
      ),
    );
  }
}
