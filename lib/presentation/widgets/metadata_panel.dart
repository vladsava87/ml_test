import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/presentation/widgets/meta_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MetadataPanel extends StatelessWidget {
  const MetadataPanel({
    super.key,
    required this.typeLabel,
    required this.fileSizeLabel,
    required this.dateLabel,
    this.isOpeningPdf,
    this.onOpenPdf,
  });

  final String typeLabel;
  final String fileSizeLabel;
  final String dateLabel;

  final RxBool? isOpeningPdf;
  final VoidCallback? onOpenPdf;

  bool get _hasPdf => isOpeningPdf != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MetaChip(icon: Icons.category, label: typeLabel),
                const SizedBox(width: 8),
                MetaChip(icon: Icons.storage, label: fileSizeLabel),
                const SizedBox(width: 8),
                MetaChip(icon: Icons.calendar_today, label: dateLabel),
              ],
            ),
          ),
          if (_hasPdf) ...[
            Obx(
              () => Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isOpeningPdf!.value
                        ? Center(
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            label: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                AppStrings.openInPdfViewer.tr,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            onPressed: isOpeningPdf!.value ? null : onOpenPdf,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
