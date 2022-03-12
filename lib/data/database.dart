import 'dart:math';
import 'dart:developer' as dev;
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/exerciserecord.dart';
import 'package:lift_tracker/data/workoutrecord.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'exercise.dart';
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
    Helper.firstAppRun = true;
    String sql = '''
    CREATE TABLE workout(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(33) NOT NULL
    );
    ''';
    await db.execute(sql);

    sql = '''
    CREATE TABLE exercise(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(33) NOT NULL,
      sets INTEGER NOT NULL,
      reps INTEGER NOT NULL,
      weight_record DOUBLE(5,2),
      fk_workout_id INTEGER NOT NULL,
      FOREIGN KEY (fk_workout_id) REFERENCES workout(id)
    );
    ''';
    await db.execute(sql);

    sql = '''
    CREATE TABLE workout_record(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      day DATE NOT NULL,
      workout_name VARCHAR(33) NOT NULL,
      fk_workout_id INTEGER NOT NULL,
      FOREIGN KEY (fk_workout_id) REFERENCES workout(id)
    );
    ''';
    await db.execute(sql);

    sql = '''
    CREATE TABLE exercise_record(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exercise_name VARCHAR(33) NOT NULL,
      fk_workout_record_id INTEGER NOT NULL,
      fk_exercise_id INTEGER NOT NULL,
      FOREIGN KEY (fk_workout_record_id) REFERENCES workout_record(id),
      FOREIGN KEY (fk_exercise_id) REFERENCES exercise(id)
    );
    ''';
    await db.execute(sql);

    sql = '''
    CREATE TABLE exercise_set(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      set_number INTEGER NOT NULL,
      reps INTEGER NOT NULL,
      weight DOUBLE(5,2) NOT NULL,
      rpe INTEGER NOT NULL,
      fk_exercise_record_id INTEGER NOT NULL,
      record BIT NOT NULL,
      FOREIGN KEY (fk_exercise_record_id) REFERENCES exercise_record(id)
    );
    ''';
    await db.execute(sql);
  }

  Future editWorkout(Workout workout) async {
    final db = await instance.database;
    await db.update('workout', {'name': workout.name},
        where: 'id=?', whereArgs: [workout.id]);
    await db
        .delete('exercise', where: 'fk_workout_id=?', whereArgs: [workout.id]);
    for (int i = 0; i < workout.exercises.length; i++) {
      Exercise exercise = workout.exercises[i];
      String name = exercise.name;
      int reps = exercise.reps;
      int sets = exercise.sets;
      double? weightRecord = exercise.weightRecord;
      await db.insert('exercise', {
        'name': name,
        'reps': reps,
        'sets': sets,
        'weight_record': weightRecord,
        'fk_workout_id': workout.id
      });
    }
  }

  Future<WorkoutRecord> getCachedSession() async {
    return (await readWorkoutRecords(cacheMode: true)).last;
  }

  Future<Workout> getCachedWorkout(int workoutId) async {
    var list = await readWorkouts();
    Workout? workout;
    for (Workout wk in list) {
      if (wk.id == workoutId) {
        workout = wk;
        break;
      }
    }
    return workout!;
  }

  Future<int> removeCachedSession() async {
    var pref = await SharedPreferences.getInstance();
    bool? temp = await pref.getBool('didCacheSession');
    bool cached = false;
    if (temp != null) {
      await pref.setBool('didCacheSession', false);
      cached = temp;
    }
    if (cached) {
      final db = await instance.database;
      var idQuery = await db.query('workout_record', columns: ['id']);
      if (idQuery.isNotEmpty) {
        int? id = idQuery.last['id'] as int?;
        if (id != null) {
          int iid = await removeWorkoutRecord(id);
          return iid;
        }
      }
      return -1;
    }
    return -1;
  }

  Future<int> removeWorkoutRecord(int workoutRecordId) async {
    final db = await instance.database;
    List<Map<String, Object?>> query = await db.query('exercise_record',
        columns: ['id'],
        where: "fk_workout_record_id=?",
        whereArgs: [workoutRecordId]);
    List<int> exerciseRecordIds = [];
    for (int i = 0; i < query.length; i++) {
      exerciseRecordIds.add(query[i]['id'] as int);
    }
    for (int i = 0; i < exerciseRecordIds.length; i++) {
      await db.delete('exercise_set',
          where: "fk_exercise_record_id=?", whereArgs: [exerciseRecordIds[i]]);
    }
    for (int i = 0; i < query.length; i++) {
      await db.delete('exercise_record',
          where: "fk_workout_record_id=?", whereArgs: [workoutRecordId]);
    }
    int id = await db
        .delete('workout_record', where: "id=?", whereArgs: [workoutRecordId]);
    return id;
  }

  Future<List<WorkoutRecord>> readWorkoutRecords(
      {bool cacheMode = false}) async {
    bool cached = false;
    if (!cacheMode) {
      var pref = await SharedPreferences.getInstance();
      bool? temp = await pref.getBool('didCacheSession');
      if (temp != null) {
        cached = temp;
      }
    }

    var pref = await SharedPreferences.getInstance();
    bool? temp = await pref.getBool('didCacheSession');

    final db = await instance.database;

    /*var query = await db.rawQuery("PRAGMA table_info(exercise_set);");
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
          "ALTER TABLE exercise_set ADD COLUMN record BIT NOT NULL DEFAULT 0;");
    }*/

    List<WorkoutRecord> workoutRecords = [];

    //we get all the workout records
    List<Map<String, Object?>> queryWorkoutRecords = await db.query(
        'workout_record',
        columns: ['id', 'day', 'workout_name', 'fk_workout_id']);

    //we get all the exercise records
    for (int i = 0; i < queryWorkoutRecords.length; i++) {
      List<ExerciseRecord> exerciseRecords = [];
      int workoutRecordId = queryWorkoutRecords[i]['id'] as int;
      List<Map<String, Object?>> queryExerciseRecords = await db.query(
          'exercise_record',
          columns: ['id', 'exercise_name', 'fk_exercise_id'],
          where: "fk_workout_record_id=?",
          whereArgs: [workoutRecordId]);

      //we get all the exercise sets
      for (int j = 0; j < queryExerciseRecords.length; j++) {
        int exerciseRecordId = queryExerciseRecords[j]['id'] as int;
        List<Map<String, Object?>> queryExerciseSets = await db.query(
            'exercise_set',
            columns: ['id', 'reps', 'weight', 'rpe', 'record'],
            where: "fk_exercise_record_id=?",
            whereArgs: [exerciseRecordId],
            orderBy: "set_number");
        //we get the information about every exercise set
        List<Map<String, dynamic>> repsWeightRpeMap = [];
        for (int k = 0; k < queryExerciseSets.length; k++) {
          int reps = queryExerciseSets[k]['reps'] as int;
          double weight = queryExerciseSets[k]['weight'] as double;
          int rpe = queryExerciseSets[k]['rpe'] as int;
          int hasRecord = queryExerciseSets[k]['record'] as int;
          Map<String, dynamic> value = {
            "reps": reps,
            "weight": weight,
            "rpe": rpe,
            "hasRecord": hasRecord
          };
          repsWeightRpeMap.add(value);
        }
        //we create the exercise record and add it to the list
        String exerciseName =
            queryExerciseRecords[j]['exercise_name'] as String;
        int exerciseId = queryExerciseRecords[j]['fk_exercise_id'] as int;
        ExerciseRecord exerciseRecord = ExerciseRecord(
            exerciseName, repsWeightRpeMap,
            exerciseId: exerciseId);
        exerciseRecords.add(exerciseRecord);
      }
      //we get the information about the workout
      String workoutName = queryWorkoutRecords[i]['workout_name'] as String;
      String dayString = queryWorkoutRecords[i]['day'] as String;
      DateTime day = DateTime.parse(sqlToDartDate(dayString));
      int workoutId = queryWorkoutRecords[i]['fk_workout_id'] as int;
      workoutRecords.add(WorkoutRecord(
          workoutRecordId, day, workoutName, exerciseRecords,
          workoutId: workoutId));
    }
    for (int i = 0; i < workoutRecords.length; i++) {}
    if (!cacheMode && cached && workoutRecords.length > 0) {
      workoutRecords.removeLast();
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

  Future<double?> getWeightRecord(int exerciseId) async {
    final db = await CustomDatabase.instance.database;
    double? previousWeightRecord = (await db.query('exercise',
        columns: ['weight_record'],
        where: 'id=?',
        whereArgs: [exerciseId]))[0]['weight_record'] as double?;
    return previousWeightRecord;
  }

  Future setWeightRecord(int exerciseId, double weightRecord) async {
    final db = await instance.database;
    await db.update('exercise', {"weight_record": weightRecord},
        where: 'id=?', whereArgs: [exerciseId]);
  }

  Future<bool> addWorkoutRecord(WorkoutRecord workoutRecord, Workout workout,
      {bool cacheMode = false}) async {
    // delete all exercise records with empty sets
    // and track their indexes
    await removeCachedSession();
    List<int> indexes = [];
    bool didSetWeightRecord = false;
    workoutRecord.exerciseRecords.removeWhere((element) {
      if (element.reps_weight_rpe.isEmpty) {
        indexes.add(workoutRecord.exerciseRecords.indexOf(element));
        return true;
      }
      return false;
    });

    // if every exercise record has been deleted, the session is not valid
    // and will not be saved
    if (workoutRecord.exerciseRecords.isEmpty) {
      throw Exception('empty_exercises');
    }
    // from the workout schedule, delete all the exercises that were
    // not excecuted in this session
    List<Exercise> tempExercises = workout.exercises;
    for (int i = 0; i < indexes.length; i++) {
      tempExercises.removeAt(i);
    }

    // don't save any weight records if in cache mode
    if (!cacheMode) {
      // check if there were weight records in this session
      // among all the exercises that were excecuted
      for (int i = 0; i < tempExercises.length; i++) {
        Exercise exercise = tempExercises[i];
        double? previousWeightRecord = exercise.weightRecord;
        var reps_weight_rpe = workoutRecord.exerciseRecords[i].reps_weight_rpe;
        double currentMaxWeight = reps_weight_rpe[0]['weight'];
        int setRecordIndex = -1;
        //if there's only one set its weight is already the max weight among all sets
        for (int j = 0; j < reps_weight_rpe.length - 1; j++) {
          currentMaxWeight =
              max(currentMaxWeight, reps_weight_rpe[j + 1]['weight']);
        }
        if (previousWeightRecord != null) {
          if (currentMaxWeight > previousWeightRecord) {
            // if this weight is a record, mark the first set with this weight
            // as record
            setRecordIndex = workoutRecord.exerciseRecords[i].reps_weight_rpe
                .indexWhere((element) => element['weight'] == currentMaxWeight);
            workoutRecord.exerciseRecords[i].reps_weight_rpe[setRecordIndex]
                ['hasRecord'] = 1;
            await CustomDatabase.instance
                .setWeightRecord(exercise.id, currentMaxWeight);
            didSetWeightRecord = true;
          }
        } else {
          // if this weight is a record, mark the first set with this weight
          // as record
          if (currentMaxWeight > 0) {
            setRecordIndex = workoutRecord.exerciseRecords[i].reps_weight_rpe
                .indexWhere((element) => element['weight'] == currentMaxWeight);
            workoutRecord.exerciseRecords[i].reps_weight_rpe[setRecordIndex]
                ['hasRecord'] = 1;
            await CustomDatabase.instance
                .setWeightRecord(exercise.id, currentMaxWeight);
            didSetWeightRecord = true;
          }
        }
      }
    }

    final db = await instance.database;

    for (int i = 0; i < tempExercises.length; i++) {
      String oldName = tempExercises[i].name;
      String newName = workoutRecord.exerciseRecords[i].exerciseName;
      if (newName != oldName) {
        await db.update('exercise', {'name': newName},
            where: 'id=?', whereArgs: [tempExercises[i].id]);
        didSetWeightRecord = true;
      }
    }

    DateTime now = DateTime.now();
    String day = "${now.year}-${now.month}-${now.day}";
    Map<String, Object> values = {
      "day": day,
      "workout_name": workoutRecord.workoutName,
      'fk_workout_id': workoutRecord.workoutId
    };
    int workoutRecordId = await db.insert('workout_record', values);
    values.clear();

    for (int i = 0; i < workoutRecord.exerciseRecords.length; i++) {
      ExerciseRecord exerciseRecord = workoutRecord.exerciseRecords[i];

      values = {
        "fk_workout_record_id": workoutRecordId,
        "exercise_name": workoutRecord.exerciseRecords[i].exerciseName,
        'fk_exercise_id': workoutRecord.exerciseRecords[i].exerciseId
      };
      int exerciseRecordId = await db.insert('exercise_record', values);
      values.clear();

      for (int j = 0; j < exerciseRecord.reps_weight_rpe.length; j++) {
        var repsWeightRpe = exerciseRecord.reps_weight_rpe[j];
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
          "fk_exercise_record_id": exerciseRecordId
        };
        await db.insert('exercise_set', values);
      }
    }
    if (cacheMode) {
      var pref = await SharedPreferences.getInstance();
      pref.setBool('didCacheSession', true);
    }
    return didSetWeightRecord;
  }

  Future removeWorkout(int id) async {
    final db = await instance.database;
    await db.delete("exercise", where: "fk_workout_id=?", whereArgs: [id]);
    await db.delete("workout", where: "id=?", whereArgs: [id]);
  }

  Future<List<Workout>> readWorkouts() async {
    List<Workout> workoutList = [];
    final db = await instance.database;
    final queryWorkouts = await db.query('workout', columns: ['id', 'name']);
    for (int i = 0; i < queryWorkouts.length; i++) {
      int id = queryWorkouts[i]['id'] as int;
      String name = queryWorkouts[i]['name'] as String;
      List<Exercise> exerciseList = [];
      final queryExercise = await db.query('exercise',
          columns: [
            'id',
            'name',
            'sets',
            'reps',
            'weight_record',
            'fk_workout_id'
          ],
          where: "fk_workout_id=?",
          whereArgs: [id]);
      for (int j = 0; j < queryExercise.length; j++) {
        int exid = queryExercise[j]['id'] as int;
        String exname = queryExercise[j]['name'] as String;
        int sets = queryExercise[j]['sets'] as int;
        int reps = queryExercise[j]['reps'] as int;
        double? weightRecord = queryExercise[j]['weight_record'] as double?;
        int workoutId = queryExercise[j]['fk_workout_id'] as int;

        exerciseList.add(Exercise(
            id: exid,
            name: exname,
            sets: sets,
            reps: reps,
            weightRecord: weightRecord,
            workoutId: workoutId));
      }
      workoutList.add(Workout(id, name, exerciseList));
    }
    return workoutList;
  }

  Future createWorkout(String name, List<Exercise> exercises) async {
    final db = await instance.database;
    final id = await db.insert('workout', {"name": name});
    for (int i = 0; i < exercises.length; i++) {
      var exercise = exercises[i];
      db.insert('exercise', {
        "name": exercise.name,
        "sets": exercise.sets,
        "reps": exercise.reps,
        "fk_workout_id": id
      });
    }
  }

  Future clearWorkouts() async {
    final db = await instance.database;
    await db.delete('exercise');
    await db.delete('workout');
  }

  Future close() async {
    final db = await instance.database;
    _database = null;
    db.close();
  }
}
