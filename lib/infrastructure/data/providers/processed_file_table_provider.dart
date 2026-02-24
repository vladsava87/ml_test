import 'package:ml_test/infrastructure/data/models/processed_file_row_entity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ml_test/domain/interfaces/data/i_processed_file_table_provider.dart';
import 'package:ml_test/domain/interfaces/data/i_db_provider.dart';

class ProcessedFileTableProvider implements IProcessedFileTableProvider {
  final IDbProvider _dbProvider;

  static const table = 'processed_files';

  ProcessedFileTableProvider(this._dbProvider);

  @override
  Future<int> updateFile(ProcessedFileRowEntity row) async {
    final db = await _dbProvider.database;
    return await db.insert(
      table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<ProcessedFileRowEntity?> getFileById(String id) async {
    final db = await _dbProvider.database;

    final rows = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return ProcessedFileRowEntity.fromMap(rows.first);
  }

  @override
  Future<List<ProcessedFileRowEntity>> getFiles({
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await _dbProvider.database;

    final rows = await db.query(
      table,
      columns: const [
        'id',
        'filename',
        'thumbnailBytes',
        'originalPath',
        'processedPath',
        'createdAt',
        'processingType',
        'sizeBytes',
        'ocrText',
      ],
      limit: limit,
      offset: offset,
    );

    return rows.map(ProcessedFileRowEntity.fromMap).toList();
  }

  @override
  Future<int> deleteFileById(int id) async {
    final db = await _dbProvider.database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> clearAllFiles() async {
    final db = await _dbProvider.database;
    return db.delete(table);
  }

  @override
  Future<int> countFiles() async {
    final db = await _dbProvider.database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
