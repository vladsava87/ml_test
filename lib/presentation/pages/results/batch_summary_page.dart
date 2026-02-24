import 'package:ml_test/infrastructure/business/controllers/results/batch_summary_controller.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/presentation/widgets/batch_result_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchSummaryPage extends StatefulWidget {
  const BatchSummaryPage({super.key});

  @override
  State<BatchSummaryPage> createState() => _BatchSummaryPageState();
}

class _BatchSummaryPageState extends State<BatchSummaryPage> {
  late final BatchSummaryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BatchSummaryController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.refreshMainController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.batchResults.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: controller.processedItems.length,
          itemBuilder: (context, index) {
            final item = controller.processedItems[index];
            return BatchResultCard(item: item);
          },
        ),
      ),
    );
  }
}
