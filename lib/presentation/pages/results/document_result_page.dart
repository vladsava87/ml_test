import 'package:ml_test/infrastructure/business/controllers/results/document_result_controller.dart';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/presentation/widgets/highlighted_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

class DocumentResultPage extends StatefulWidget {
  const DocumentResultPage({super.key});

  @override
  State<DocumentResultPage> createState() => _DocumentResultPageState();
}

class _DocumentResultPageState extends State<DocumentResultPage> {
  late final DocumentResultController controller;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();

    controller = Get.put(DocumentResultController());

    ever<int>(controller.currentMatchIndex, (_) => _jumpToCurrentMatch());
    ever<int>(controller.matchCount, (_) => _jumpToCurrentMatch());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.pdfCreated.tr)),
      body: SafeArea(
        child: Obx(() {
          final text = controller.extractedText.value;
          final pdf = controller.pdfPath.value;

          final q = controller.searchQuery.value;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        controller.documentName.value,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: controller.updateSearchQuery,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: AppStrings.searchInText.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: q.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        controller.clearSearch();
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: Colors.black12,
                          padding: const EdgeInsets.all(12),
                          child: text.isEmpty
                              ? Center(
                                  child: Text(AppStrings.noExtractedText.tr),
                                )
                              : SingleChildScrollView(
                                  controller: _scrollCtrl,
                                  child: HighlightedText(
                                    text: text,
                                    query: q,
                                    currentMatchOffset:
                                        controller.currentMatchOffset,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),

                    ElevatedButton.icon(
                      onPressed: text.isEmpty
                          ? null
                          : () async {
                              await Clipboard.setData(
                                ClipboardData(text: text),
                              );
                              if (mounted) {
                                Get.snackbar(
                                  AppStrings.copied.tr,
                                  AppStrings.textCopied.tr,
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.grey[400],
                                  colorText: Colors.black87,
                                );
                              }
                            },
                      icon: const Icon(Icons.copy),
                      label: Text(AppStrings.copyText.tr),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: (pdf == null || pdf.isEmpty)
                        ? null
                        : () async {
                            final result = await OpenFilex.open(pdf);
                            if (mounted && result.type != ResultType.done) {
                              Get.snackbar(
                                AppStrings.error.tr,
                                '${AppStrings.couldNotOpenPdf.tr}${result.message}',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor:
                                    Colors.deepPurpleAccent.shade100,
                                colorText: Colors.white,
                              );
                            }
                          },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(AppStrings.openPdf.tr),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _jumpToCurrentMatch() {
    final offset = controller.currentMatchOffset;
    final q = controller.searchQuery.value;
    if (offset == null || q.isEmpty) return;

    final textUpTo = controller.extractedText.value.substring(0, offset);
    final lines = '\n'.allMatches(textUpTo).length;

    const lineHeight = 18.0;
    final target = (lines * lineHeight).clamp(
      0.0,
      _scrollCtrl.position.hasContentDimensions
          ? _scrollCtrl.position.maxScrollExtent
          : double.infinity,
    );

    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }
}
