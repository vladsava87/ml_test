import 'dart:io';
import 'package:ml_test/infrastructure/constants/app_navigation_args.dart';
import 'package:get/get.dart';

class DocumentResultController extends GetxController {
  late File file;

  final extractedText = ''.obs;
  final pdfPath = RxnString();
  final documentName = ''.obs;
  final searchQuery = ''.obs;
  final matchCount = 0.obs;
  final currentMatchIndex = 0.obs;
  final matchOffsets = <int>[].obs;

  DocumentResultController();

  int? get currentMatchOffset =>
      matchOffsets.isEmpty ? null : matchOffsets[currentMatchIndex.value];

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    file = args[AppNavigationArgs.keyOriginalFile] as File;
    extractedText.value = args[AppNavigationArgs.keyFoundText] as String? ?? '';
    pdfPath.value = args[AppNavigationArgs.keyPdfPath] as String?;

    documentName.value = file.uri.pathSegments.last;
  }

  void updateSearchQuery(String q) {
    searchQuery.value = q.trim();
    _recomputeMatches();
  }

  void clearSearch() {
    searchQuery.value = '';
    matchOffsets.clear();
    matchCount.value = 0;
    currentMatchIndex.value = 0;
  }

  void _recomputeMatches() {
    final text = extractedText.value;
    final q = searchQuery.value;

    matchOffsets.clear();
    matchCount.value = 0;
    currentMatchIndex.value = 0;

    if (q.isEmpty || text.isEmpty) return;

    final lowerText = text.toLowerCase();
    final lowerQ = q.toLowerCase();

    int start = 0;
    while (true) {
      final idx = lowerText.indexOf(lowerQ, start);
      if (idx < 0) break;
      matchOffsets.add(idx);
      start = idx + lowerQ.length;
    }

    matchCount.value = matchOffsets.length;
    currentMatchIndex.value = matchOffsets.isEmpty ? 0 : 0;
  }
}
