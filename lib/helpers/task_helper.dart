import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/models/task.dart';


class TaskHelper {

  static final TaskHelper _instance = TaskHelper.internal();

  factory TaskHelper() => _instance;

  TaskHelper.internal();

//   database init
  Database _db;

//   function to access database for app
  Future<Database> get db async
  {
//     if db instance is not null, retrieve.
    if (_db != null)
    {
      return _db;
    } // else create new instance.
    else
      {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
//     init
    final databasePath = await getDatabasesPath();

//     db file saving
    final path = join(databasePath, "todoapp.db");

    return openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {

//      Task db table creation
      await db.execute(
          "CREATE TABLE task("
          "id INTEGER PRIMARY KEY, "
          "title TEXT, "
          "description TEXT, "
          "dueDate DATETIME, "
          "isDone INTEGER)");
    });
  }

//   count function, used for length of list on main page
  Future<int> getCount() async {
    Database database = await db;
    return Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM task"));
  }

//   close function
  Future close() async {
    Database database = await db;
    database.close();
  }

//   save function
  Future<Task> save(Task task) async {
    Database database = await db;
    task.id = await database.insert('task', task.toMap());
    return task;
  }

//   find by matching ID
  Future<Task> getById(int id) async {
    Database database = await db;
    List<Map> maps = await database.query('task',
        columns: ['id', 'title', 'description', 'dueDate', 'isDone'],
        where: 'id = ?',
        whereArgs: [id]);

    if (maps.length > 0) {
      return Task.fromMap(maps.first);
    } else {
      return null;
    }
  }

//   delete function
  Future<int> delete(int id) async {
    Database database = await db;
    return await database.delete('task', where: 'id = ?', whereArgs: [id]);
  }

//  deleteAll tasks function
  Future<int> deleteAll() async {
    Database database = await db;
    return await database.rawDelete("DELETE * from task");
  }

//   update function
  Future<int> update(Task task) async {
    Database database = await db;
    return await database
        .update('task', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

//   getAll Tasks function
  Future<List<Task>> getAll() async {
    Database database = await db;
    List listMap = await database.rawQuery("SELECT * FROM task");
    List<Task> stuffList = listMap.map((x) => Task.fromMap(x)).toList();
    return stuffList;
  }


}
