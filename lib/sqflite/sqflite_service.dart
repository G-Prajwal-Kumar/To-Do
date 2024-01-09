import "package:sqflite/sqflite.dart";
import 'package:path/path.dart';
import 'package:keka_to_do_list/sqflite/todo_db.dart';

class SqfliteService {
  Database? _database;

  Future<Database> get database async {
    if(_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    final path = await getDatabasesPath();
    return join(path, 'todo.db');
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return database;
  }

  Future<void> create(Database database, int version) async => await TodoDB().createTable(database);
}