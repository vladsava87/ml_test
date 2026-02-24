import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:ml_test/infrastructure/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:ml_test/domain/interfaces/data/i_db_provider.dart';

class DbProvider implements IDbProvider {
  static const _dbName = AppConstants.databaseFile;
  static const _dbVersion = 1;

  Database? _db;
  Completer<Database>? _openingCompleter;

  @override
  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final opening = _openingCompleter;
    if (opening != null) return opening.future;

    _openingCompleter = Completer<Database>();
    try {
      final db = await _openDb();
      _db = db;
      _openingCompleter!.complete(db);
      return db;
    } catch (e, st) {
      _openingCompleter!.completeError(e, st);
      rethrow;
    } finally {
      _openingCompleter = null;
    }
  }

  @override
  Future<void> init() async {
    await database;
  }

  @override
  Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) {
      await db.close();
    }
  }

  @override
  Future<void> deleteDb() async {
    final dbDir = await getDatabasesPath();
    final dbPath = path.join(dbDir, _dbName);
    await close();
    await deleteDatabase(dbPath);
  }

  Future<Database> _openDb() async {
    final dbDir = await getDatabasesPath();
    final dbPath = path.join(dbDir, _dbName);

    var passphrase = await _getPassKeyAsync();
    final escapedKey = passphrase.replaceAll("'", "''");

    try {
      return openDatabase(
        dbPath,
        version: _dbVersion,
        password: escapedKey,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await _createSchema(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _migrate(db, oldVersion, newVersion);
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE processed_files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filename TEXT NOT NULL,
        thumbnailBytes BLOB,
        originalPath TEXT NOT NULL,
        processedPath TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        sizeBytes INTEGER NOT NULL,
        processingType INTEGER NOT NULL,
        ocrText TEXT
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_files_createdAt ON processed_files(createdAt);',
    );
    await db.execute(
      'CREATE INDEX idx_files_filename ON processed_files(filename);',
    );
  }

  Future<void> _migrate(Database db, int oldVersion, int newVersion) async {}

  Future<String> _getPassKeyAsync() async {
    final secureStorage = FlutterSecureStorage();
    const passphraseKey = 'dbPassphrase';

    String? passphrase = await secureStorage.read(key: passphraseKey);
    if (passphrase == null) {
      passphrase = _generatePassphrase();
      await secureStorage.write(key: passphraseKey, value: passphrase);
    }

    return passphrase;
  }

  String _generatePassphrase() {
    final random = Random.secure();
    final key = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(key);
  }
}
