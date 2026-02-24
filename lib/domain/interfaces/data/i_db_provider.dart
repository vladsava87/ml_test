import 'package:sqflite_sqlcipher/sqflite.dart';

abstract class IDbProvider {
  Future<Database> get database;
  Future<void> init();
  Future<void> close();
  Future<void> deleteDb();
}
