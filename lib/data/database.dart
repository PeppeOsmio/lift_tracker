import 'package:lift_tracker/data/constants.dart';
import 'package:lift_tracker/data/excerciserecord.dart';
import 'package:lift_tracker/data/workoutrecord.dart';
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
    Constants.firstAppRun = true;
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
      weight_record DOUBLE(5,2),
      fk_workoutId INTEGER NOT NULL,
      FOREIGN KEY (fk_workoutId) REFERENCES workout(id)
    );
    ''';
    await db.execute(sql);

    sql = '''
    CREATE TABLE workout_record(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      day DATE NOT NULL,
      workout_name VARCHAR(33) NOT NULL
    );
    ''';
    await db.execute(sql);

    sql = '''
    CREATE TABLE excercise_record(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fk_workout_recordId INTEGER NOT NULL,
      excercise_name VARCHAR(33) NOT NULL
    );
    ''';
    await db.execute(sql);

    sql = '''
    CREATE TABLE excercise_set(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      set_number INTEGER NOT NULL,
      reps INTEGER NOT NULL,
      weight DOUBLE(5,2) NOT NULL,
      rpe INTEGER NOT NULL,
      fk_excercise_recordId INTEGER NOT NULL,
      record BIT NOT NULL,
      FOREIGN KEY (fk_excercise_recordId) REFERENCES excercise_record(id)
    );
    ''';
    await db.execute(sql);
  }

  Future editWorkout(Workout workout) async {
    final db = await instance.database;
    await db.update('workout', {'name': workout.name},
        where: 'id=?', whereArgs: [workout.id]);
    await db
        .delete('excercise', where: 'fk_workoutId=?', whereArgs: [workout.id]);
    for (int i = 0; i < workout.excercises.length; i++) {
      Excercise excercise = workout.excercises[i];
      String name = excercise.name;
      int reps = excercise.reps;
      int sets = excercise.sets;
      double? weightRecord = excercise.weightRecord;
      await db.insert('excercise', {
        'name': name,
        'reps': reps,
        'sets': sets,
        'weight_record': weightRecord,
        'fk_workoutId': workout.id
      });
    }
  }

  Future removeWorkoutRecord(int workoutRecordId) async {
    final db = await instance.database;
    List<Map<String, Object?>> query = await db.query('excercise_record',
        columns: ['id'],
        where: "fk_workout_recordId=?",
        whereArgs: [workoutRecordId]);
    List<int> excerciseRecordIds = [];
    for (int i = 0; i < query.length; i++) {
      excerciseRecordIds.add(query[i]['id'] as int);
    }
    for (int i = 0; i < excerciseRecordIds.length; i++) {
      await db.delete('excercise_set',
          where: "fk_excercise_recordId=?", whereArgs: [excerciseRecordIds[i]]);
    }
    for (int i = 0; i < query.length; i++) {
      await db.delete('excercise_record',
          where: "fk_workout_recordId=?", whereArgs: [workoutRecordId]);
    }
    await db
        .delete('workout_record', where: "id=?", whereArgs: [workoutRecordId]);
  }

  Future<List<WorkoutRecord>> readWorkoutRecords() async {
    final db = await instance.database;

    var query = await db.rawQuery("PRAGMA table_info(excercise_set);");
    bool containsHasRecord = false;
    for (int i = 0; i < query.length; i++) {
      var column = query[i];
      if (column['name'] == 'record') {
        containsHasRecord = true;
        i = query.length;
      }
    }
    if (!containsHasRecord) {
      await db.execute(
          "ALTER TABLE excercise_set ADD COLUMN record BIT NOT NULL DEFAULT 0;");
    }

    List<WorkoutRecord> workoutRecords = [];

    //we get all the workout records
    List<Map<String, Object?>> queryWorkoutRecords = await db
        .query('workout_record', columns: ['id', 'day', 'workout_name']);

    //we get all the excercise records
    for (int i = 0; i < queryWorkoutRecords.length; i++) {
      List<ExcerciseRecord> excerciseRecords = [];
      int workoutRecordId = queryWorkoutRecords[i]['id'] as int;
      List<Map<String, Object?>> queryExcerciseRecords = await db.query(
          'excercise_record',
          columns: ['id', 'excercise_name'],
          where: "fk_workout_recordId=?",
          whereArgs: [workoutRecordId]);

      //we get all the excercise sets
      for (int j = 0; j < queryExcerciseRecords.length; j++) {
        int excerciseRecordId = queryExcerciseRecords[j]['id'] as int;
        List<Map<String, Object?>> queryExcerciseSets = await db.query(
            'excercise_set',
            columns: ['id', 'reps', 'weight', 'rpe', 'record'],
            where: "fk_excercise_recordId=?",
            whereArgs: [excerciseRecordId],
            orderBy: "set_number");
        //we get the information about every excercise set
        List<Map<String, dynamic>> repsWeightRpeMap = [];
        for (int k = 0; k < queryExcerciseSets.length; k++) {
          int reps = queryExcerciseSets[k]['reps'] as int;
          double weight = queryExcerciseSets[k]['weight'] as double;
          int rpe = queryExcerciseSets[k]['rpe'] as int;
          int hasRecord = queryExcerciseSets[k]['record'] as int;
          Map<String, dynamic> value = {
            "reps": reps,
            "weight": weight,
            "rpe": rpe,
            "hasRecord": hasRecord
          };
          repsWeightRpeMap.add(value);
        }
        //we create the excercise record and add it to the list
        String excerciseName =
            queryExcerciseRecords[j]['excercise_name'] as String;
        ExcerciseRecord excerciseRecord =
            ExcerciseRecord(excerciseName, repsWeightRpeMap);
        excerciseRecords.add(excerciseRecord);
      }
      //we get the information about the workout
      String workoutName = queryWorkoutRecords[i]['workout_name'] as String;
      String dayString = queryWorkoutRecords[i]['day'] as String;
      DateTime day = DateTime.parse(sqlToDartDate(dayString));
      workoutRecords.add(
          WorkoutRecord(workoutRecordId, day, workoutName, excerciseRecords));
    }
    return workoutRecords;
  }

  String sqlToDartDate(String sqlDate) {
    String year = "";
    String month = "";
    String day = "";
    int j;
    for (j = 0; sqlDate[j] != "-"; j++) {
      year += sqlDate[j];
    }
    for (j = j + 1; sqlDate[j] != "-"; j++) {
      month += sqlDate[j];
    }
    for (j = j + 1; j < sqlDate.length; j++) {
      day += sqlDate[j];
    }
    String dartDate = "";
    dartDate += year + "-";
    if (month.length < 2) {
      dartDate += "0" + month + "-";
    } else {
      dartDate += month + "-";
    }
    if (day.length < 2) {
      dartDate += "0" + day;
    } else {
      dartDate += day;
    }
    return dartDate;
  }

  Future<double?> getWeightRecord(int excerciseId) async {
    final db = await CustomDatabase.instance.database;
    double? previousWeightRecord = (await db.query('excercise',
        columns: ['weight_record'],
        where: 'id=?',
        whereArgs: [excerciseId]))[0]['weight_record'] as double?;
    return previousWeightRecord;
  }

  Future setWeightRecord(int excerciseId, double weightRecord) async {
    final db = await instance.database;
    await db.update('excercise', {"weight_record": weightRecord},
        where: 'id=?', whereArgs: [excerciseId]);
  }

  Future addWorkoutRecord(WorkoutRecord workoutRecord) async {
    final db = await instance.database;

    DateTime now = DateTime.now();
    String day = "${now.year}-${now.month}-${now.day}";
    Map<String, Object> values = {
      "day": day,
      "workout_name": workoutRecord.workoutName
    };
    int workoutRecordId = await db.insert('workout_record', values);
    values.clear();

    for (int i = 0; i < workoutRecord.excerciseRecords.length; i++) {
      ExcerciseRecord excerciseRecord = workoutRecord.excerciseRecords[i];

      values = {
        "fk_workout_recordId": workoutRecordId,
        "excercise_name": workoutRecord.excerciseRecords[i].excerciseName
      };
      int excerciseRecordId = await db.insert('excercise_record', values);
      values.clear();

      for (int j = 0; j < excerciseRecord.reps_weight_rpe.length; j++) {
        var repsWeightRpe = excerciseRecord.reps_weight_rpe[j];
        int reps = repsWeightRpe["reps"] as int;
        double weight = repsWeightRpe["weight"] as double;
        int rpe = repsWeightRpe["rpe"] as int;
        int hasRecord = repsWeightRpe["hasRecord"] as int;
        values = {
          "set_number": i,
          "reps": reps,
          "weight": weight,
          "rpe": rpe,
          "record": hasRecord,
          "fk_excercise_recordId": excerciseRecordId
        };
        await db.insert('excercise_set', values);
      }
    }
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
          columns: ['id', 'name', 'sets', 'reps', 'weight_record'],
          where: "fk_workoutId=?",
          whereArgs: [id]);
      for (int j = 0; j < queryExcercise.length; j++) {
        int exid = queryExcercise[j]['id'] as int;
        String exname = queryExcercise[j]['name'] as String;
        int sets = queryExcercise[j]['sets'] as int;
        int reps = queryExcercise[j]['reps'] as int;
        double? weightRecord = queryExcercise[j]['weight_record'] as double?;

        excerciseList.add(Excercise(
            id: exid,
            name: exname,
            sets: sets,
            reps: reps,
            weightRecord: weightRecord));
      }
      workoutList.add(Workout(id, name, excerciseList));
    }
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

  Future clearWorkouts() async {
    final db = await instance.database;
    await db.delete('excercise');
    await db.delete('workout');
  }

  Future close() async {
    final db = await instance.database;
    _database = null;
    db.close();
  }
}
