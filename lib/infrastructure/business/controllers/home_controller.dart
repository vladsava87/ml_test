import 'dart:io';
import 'package:ml_test/domain/models/processed_file_model.dart';
import 'package:ml_test/domain/interfaces/data/i_processed_file_repository.dart';
import 'package:ml_test/infrastructure/router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController {
  final _picker = ImagePicker();
  final isPicking = false.obs;
  final isLoading = false.obs;
  final files = <ProcessedFileModel>[].obs;
  final totalFiles = 0.obs;
  final IProcessedFileRepository _repository;

  int currentPage = 0;

  int get pageSize => 15;

  HomeController(this._repository);

  @override
  void onInit() {
    super.onInit();
    loadRecent();
  }

  Future<void> loadRecent() async {
    isLoading.value = true;
    files.value = [];

    try {
      final results = await Future.wait([
        _repository.listRecent(limit: pageSize, offset: 0),
        _repository.countAll(),
      ]);
      files.value = results[0] as List<ProcessedFileModel>;
      totalFiles.value = results[1] as int;
      currentPage = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore(int nextPage, int pageSize) async {
    if (isLoading.value) return;
    if (files.length >= totalFiles.value) return;

    isLoading.value = true;
    try {
      final nextItems = await _repository.listRecent(
        limit: pageSize,
        offset: nextPage * pageSize,
      );
      files.addAll(nextItems);
      currentPage = nextPage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFile(int? id) async {
    if (id == null) return;
    await _repository.delete(id);
    loadRecent();
  }

  Future<List<File>?> pickMultiImage() async {
    if (isPicking.value) return null;

    try {
      isPicking.value = true;
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 95);
      if (images.isEmpty) return null;
      return images.map((x) => File(x.path)).toList();
    } finally {
      isPicking.value = false;
    }
  }

  Future<void> openHistoryForFile(ProcessedFileModel item) async {
    Get.toNamed(AppRouter.history, arguments: item);
  }

  void toggleLanguage() {
    final currentLocale = Get.locale;
    if (currentLocale?.languageCode == 'es') {
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      Get.updateLocale(const Locale('es', 'ES'));
    }
  }
}
