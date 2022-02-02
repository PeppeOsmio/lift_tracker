import 'package:sqflite/sqflite.dart';
import 'excercise.dart';
import 'workout.dart';

class CustomDatabase {
  static final instance = CustomDatabase._init();

  static Database? _database;

  CustomDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('database.db');
    return _database!;
  }

  Future<Database> _initDB(String filename) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + "/" + filename;
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    String sql = '''
    CREATE TABLE workout(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(33) NOT NULL
    );
    ''';
    await db.execute(sql);

    sql = '''
    CREATE TABLE excercise(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(33) NOT NULL,
      sets INTEGER NOT NULL,
      reps INTEGER NOT NULL,
      fk_workoutId INTEGER NOT NULL,
      FOREIGN KEY (fk_workoutId) REFERENCES workout(id)
    );
    ''';
    await db.execute(sql);
  }

  Future removeWorkout(int id) async {
    final db = await instance.database;
    await db.delete("excercise", where: "fk_workoutId=?", whereArgs: [id]);
    await db.delete("workout", where: "id=?", whereArgs: [id]);
  }

  Future<List<Workout>> readWorkouts() async {
    List<Workout> workoutList = [];
    final db = await instance.database;
    final queryWorkouts = await db.query('workout', columns: ['id', 'name']);
    for (int i = 0; i < queryWorkouts.length; i++) {
      int id = queryWorkouts[i]['id'] as int;
      String name = queryWorkouts[i]['name'] as String;
      List<Excercise> excerciseList = [];
      final queryExcercise = await db.query('excercise',
          columns: ['id', 'name', 'sets', 'reps'],
          where: "fk_workoutId=?",
          whereArgs: [id]);
      for (int j = 0; j < queryExcercise.length; j++) {
        int exid = queryExcercise[j]['id'] as int;
        String exname = queryExcercise[j]['name'] as String;
        int sets = queryExcercise[j]['sets'] as int;
        int reps = queryExcercise[j]['reps'] as int;

        excerciseList.add(Excercise(exid, exname, sets, reps));
      }
      workoutList.add(Workout(id, name, excerciseList));
    }
    for (int i = 0; i < workoutList.length; i++) {}
    return workoutList;
  }

  Future createWorkout(String name, List<Excercise> excercises) async {
    final db = await instance.database;
    final id = await db.insert('workout', {"name": name});
    for (int i = 0; i < excercises.length; i++) {
      var excercise = excercises[i];
      db.insert('excercise', {
        "name": excercise.name,
        "sets": excercise.sets,
        "reps": excercise.reps,
        "fk_workoutId": id
      });
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
