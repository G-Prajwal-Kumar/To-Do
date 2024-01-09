import "package:sqflite/sqflite.dart";
import 'package:keka_to_do_list/sqflite/sqflite_service.dart';
import 'package:keka_to_do_list/Todo.dart';

class TodoDB {
  Future<void> createTable(Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS todos (
        "id" INTEGER NOT NULL,
        "title" TEXT NOT NULL,
        "description" TEXT NOT NULL,
        "dueDate" datetime,
        "createdDate" datetime,
        "deletedDate" datetime,
        "priority" INTEGER NOT NULL,
        "category" TEXT NOT NULL,
        "status" INTEGER NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
      )
    """);
  }

  Future<int> create({required String title, required String description, required String dueDate, required String createdDate, required String deletedDate, required String priority, required String category}) async {
    final database = await SqfliteService().database;
    return await database.rawInsert(
      """INSERT INTO todos (title, description, dueDate, createdDate, deletedDate, priority, category, status) VALUES (?,?,?,?,?,?,?,?)""",
      [title, description, dueDate, createdDate, deletedDate, priority, category, 0]
    );
  }

  Future<List<Todo>> fetchAll() async {
    final database = await SqfliteService().database;
    final todos = await database.rawQuery("""SELECT * FROM todos;""");
    print(todos);
    return todos.map((todo) => Todo.fromSqfliteDatabase(todo)).toList();
  }

  Future<Todo> fetchByID(int id) async {
    final database = await SqfliteService().database;
    final todo = await database.rawQuery("""SELECT * FROM todos WHERE id = ?""", [id]);
    return Todo.fromSqfliteDatabase(todo.first);
  }

  Future<List<String>> fetchCategories() async {
    final database = await SqfliteService().database;
    final cats = await database.rawQuery("""SELECT DISTINCT category from todos""");
    return cats.map((e) => e['category'].toString()).toList();
  }

  Future<int> renameCategory({required String prevCat, required String newCat}) async {
    final database = await SqfliteService().database;
    return await database.update(
      'todos',
      {
        'category' : newCat,
      },
      where: "category = ?",
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [prevCat],
    );
  }

  Future<int> update({required int id, required Map<String, Object> newData}) async {
    final database = await SqfliteService().database;
    return await database.update(
      'todos',
      newData,
      where: "id = ?",
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final database = await SqfliteService().database;
    return database.rawDelete("""DELETE FROM todos WHERE id = ?""", [id]);
  }
  
  Future<int> deleteTable(String tableName) async {
    final database = await SqfliteService().database;
    return database.delete(tableName);
  }
}