import 'package:ml_test/domain/models/processed_file_model.dart';

abstract class IProcessedFileRepository {
  Future<List<ProcessedFileModel>> listRecent({
    int limit = 100,
    int offset = 0,
  });
  Future<int> save(ProcessedFileModel row);
  Future<void> delete(int id);
  Future<int> countAll();
}
