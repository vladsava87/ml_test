import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@immutable
class ProcessedFileRowEntity {
  final int? id;
  final String filename;
  final Uint8List? thumbnailBytes;
  final String originalPath;
  final String processedPath;
  final DateTime createdAt;
  final int processingType;
  final int sizeBytes;
  final String? ocrText;

  const ProcessedFileRowEntity({
    this.id,
    required this.filename,
    this.thumbnailBytes,
    required this.originalPath,
    required this.processedPath,
    required this.createdAt,
    required this.processingType,
    required this.sizeBytes,
    this.ocrText,
  });

  ProcessedFileRowEntity copyWith({
    ValueGetter<int?>? id,
    String? filename,
    ValueGetter<Uint8List?>? thumbnailBytes,
    String? originalPath,
    String? processedPath,
    DateTime? createdAt,
    int? processingType,
    int? sizeBytes,
    String? ocrText,
  }) {
    return ProcessedFileRowEntity(
      id: id != null ? id() : this.id,
      filename: filename ?? this.filename,
      thumbnailBytes: thumbnailBytes != null
          ? thumbnailBytes()
          : this.thumbnailBytes,
      originalPath: originalPath ?? this.originalPath,
      processedPath: processedPath ?? this.processedPath,
      createdAt: createdAt ?? this.createdAt,
      processingType: processingType ?? this.processingType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      ocrText: ocrText ?? this.ocrText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'thumbnailBytes': thumbnailBytes,
      'originalPath': originalPath,
      'processedPath': processedPath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'processingType': processingType,
      'sizeBytes': sizeBytes,
      'ocrText': ocrText,
    };
  }

  factory ProcessedFileRowEntity.fromMap(Map<String, dynamic> map) {
    return ProcessedFileRowEntity(
      id: map['id'] ?? '',
      filename: map['filename'] ?? '',
      thumbnailBytes: map['thumbnailBytes'] != null
          ? Uint8List.fromList(map['thumbnailBytes'] as List<int>)
          : null,
      originalPath: map['originalPath'] ?? '',
      processedPath: map['processedPath'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      processingType: map['processingType']?.toInt() ?? 0,
      sizeBytes: map['sizeBytes']?.toInt() ?? 0,
      ocrText: map['ocrText'],
    );
  }
}
