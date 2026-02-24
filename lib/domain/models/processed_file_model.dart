import 'dart:convert';
import 'dart:typed_data';
import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:flutter/material.dart';

class ProcessedFileModel {
  final int? id;
  final String filename;
  final Uint8List? thumbnailBytes;
  final String originalPath;
  final String processedPath;
  final DateTime createdAt;
  final EImageType type;
  final int sizeBytes;
  final String? ocrText;

  ProcessedFileModel({
    this.id,
    required this.filename,
    this.thumbnailBytes,
    required this.originalPath,
    required this.processedPath,
    required this.createdAt,
    required this.type,
    required this.sizeBytes,
    this.ocrText,
  });

  ProcessedFileModel copyWith({
    int? id,
    String? filename,
    ValueGetter<Uint8List?>? thumbnailBytes,
    String? originalPath,
    String? processedPath,
    DateTime? createdAt,
    EImageType? type,
    int? sizeBytes,
    String? ocrText,
  }) {
    return ProcessedFileModel(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      thumbnailBytes: thumbnailBytes != null
          ? thumbnailBytes()
          : this.thumbnailBytes,
      originalPath: originalPath ?? this.originalPath,
      processedPath: processedPath ?? this.processedPath,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
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
      'type': type.index,
      'sizeBytes': sizeBytes,
      'ocrText': ocrText,
    };
  }

  factory ProcessedFileModel.fromMap(Map<String, dynamic> map) {
    return ProcessedFileModel(
      id: map['id'] ?? '',
      filename: map['filename'] ?? '',
      thumbnailBytes: map['thumbnailBytes'] != null
          ? Uint8List.fromList(map['thumbnailBytes'] as List<int>)
          : null,
      originalPath: map['originalPath'] ?? '',
      processedPath: map['processedPath'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      type: EImageType.values[map['type'] ?? 0],
      sizeBytes: map['sizeBytes']?.toInt() ?? 0,
      ocrText: map['ocrText'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ProcessedFileModel.fromJson(String source) =>
      ProcessedFileModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ProcessedFileModel(id: $id, filename: $filename, thumbnailBytes: $thumbnailBytes, originalPath: $originalPath, processedPath: $processedPath, createdAt: $createdAt, type: $type, sizeBytes: $sizeBytes, ocrText: $ocrText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProcessedFileModel &&
        other.id == id &&
        other.filename == filename &&
        other.thumbnailBytes == thumbnailBytes &&
        other.originalPath == originalPath &&
        other.processedPath == processedPath &&
        other.createdAt == createdAt &&
        other.type == type &&
        other.sizeBytes == sizeBytes &&
        other.ocrText == ocrText;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        filename.hashCode ^
        thumbnailBytes.hashCode ^
        originalPath.hashCode ^
        processedPath.hashCode ^
        createdAt.hashCode ^
        type.hashCode ^
        sizeBytes.hashCode ^
        ocrText.hashCode;
  }
}
