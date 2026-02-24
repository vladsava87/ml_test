import 'package:path_provider/path_provider.dart';
import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/domain/models/processed_file_model.dart';
import 'package:ml_test/infrastructure/data/models/processed_file_row_entity.dart';
import 'package:ml_test/domain/interfaces/data/i_processed_file_repository.dart';
import 'package:ml_test/domain/interfaces/data/i_processed_file_table_provider.dart';

class ProcessedFileRepository implements IProcessedFileRepository {
  final IProcessedFileTableProvider _processedFileTableProvider;

  ProcessedFileRepository(this._processedFileTableProvider);

  @override
  Future<List<ProcessedFileModel>> listRecent({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final entities = await _processedFileTableProvider.getFiles(
        limit: limit,
        offset: offset,
      );

      final docsDir = await getApplicationDocumentsDirectory();

      return entities.map((e) => _toDomain(e, docsDir.path)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> save(ProcessedFileModel row) async {
    return await _processedFileTableProvider.updateFile(_toEntity(row));
  }

  @override
  Future<void> delete(int id) => _processedFileTableProvider.deleteFileById(id);

  @override
  Future<int> countAll() async {
    try {
      return await _processedFileTableProvider.countFiles();
    } catch (e) {
      return 0;
    }
  }

  ProcessedFileModel _toDomain(
    ProcessedFileRowEntity e,
    String currentDocsPath,
  ) {
    String parsePath(String savedPath) {
      if (savedPath.isEmpty) return savedPath;

      // Rebuild the path to bypass iOS Sandbox UUID changes
      if (savedPath.contains('/Documents/')) {
        return '$currentDocsPath/${savedPath.split('/Documents/').last}';
      }

      // For legacy files saved in iOS /tmp/ or /Library/Caches/ before the persistence fix
      if (currentDocsPath.endsWith('/Documents')) {
        final sandboxRoot = currentDocsPath.substring(
          0,
          currentDocsPath.length - 10,
        );
        if (savedPath.contains('/tmp/')) {
          return '$sandboxRoot/tmp/${savedPath.split('/tmp/').last}';
        }
        if (savedPath.contains('/Library/Caches/')) {
          return '$sandboxRoot/Library/Caches/${savedPath.split('/Library/Caches/').last}';
        }
      }

      return savedPath;
    }

    return ProcessedFileModel(
      id: e.id,
      filename: e.filename,
      thumbnailBytes: e.thumbnailBytes,
      originalPath: parsePath(e.originalPath),
      processedPath: parsePath(e.processedPath),
      createdAt: e.createdAt,
      type: EImageType.values.elementAt(e.processingType),
      sizeBytes: e.sizeBytes,
      ocrText: e.ocrText,
    );
  }

  ProcessedFileRowEntity _toEntity(ProcessedFileModel d) =>
      ProcessedFileRowEntity(
        id: d.id,
        filename: d.filename,
        thumbnailBytes: d.thumbnailBytes,
        originalPath: d.originalPath,
        processedPath: d.processedPath,
        createdAt: d.createdAt,
        processingType: d.type.index,
        sizeBytes: d.sizeBytes,
        ocrText: d.ocrText,
      );
}
