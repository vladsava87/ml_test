import 'package:ml_test/infrastructure/data/models/processed_file_row_entity.dart';

abstract class IProcessedFileTableProvider {
  Future<int> updateFile(ProcessedFileRowEntity row);
  Future<ProcessedFileRowEntity?> getFileById(String id);
  Future<List<ProcessedFileRowEntity>> getFiles({
    int limit = 10,
    int offset = 0,
  });
  Future<int> deleteFileById(int id);
  Future<int> clearAllFiles();
  Future<int> countFiles();
}
