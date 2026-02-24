import 'package:flutter/material.dart';

abstract class IProcessDocumentsService {
  Future<String?> processDocument(
    String imagePath, {
    List<Offset>? points,
    Size? streamSize,
  });
}
