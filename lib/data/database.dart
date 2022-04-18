import 'dart:io';
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
    final path = dbPath + '/' + filename;
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
      json_id INTEGER NOT NULL,
      type VARCHAR(20) NOT NULL,
      sets INTEGER NOT NULL,
      reps INTEGER NOT NULL,
      notes VARCHAR(300),
      fk_workout_id INTEGER NOT NULL,
      FOREIGN KEY (fk_workout_id) REFERENCES workout(id)
    );
    ''';
    await db.execute(sql);

    sql = '''
    CREATE TABLE best_weight_volume_reps(
      json_id INTEGER PRIMARY KEY,
      best_weight DOUBLE(5,2),
      best_volume INTEGER,
      best_reps INTEGER
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
      reps INTEGER NOT NULL,
      weight DOUBLE(5,2) NOT NULL,
      rpe INTEGER NOT NULL,
      fk_exercise_record_id INTEGER NOT NULL,
      record BIT NOT NULL DEFAULT 0,
      FOREIGN KEY (fk_exercise_record_id) REFERENCES exercise_record(id)
    );
    ''';
    await db.execute(sql);
  }

  Future editWorkout(Workout workout) async {
    final db = await instance.database;
    db.transaction((txn) async {
      await txn.update('workout', {'name': workout.name},
          where: 'id=?', whereArgs: [workout.id]);
      await txn.delete('exercise',
          where: 'fk_workout_id=?', whereArgs: [workout.id]);
      for (int i = 0; i < workout.exercises.length; i++) {
        Exercise exercise = workout.exercises[i];
        int reps = exercise.reps;
        int sets = exercise.sets;
        await txn.insert('exercise', {
          'json_id': exercise.jsonId,
          'reps': reps,
          'sets': sets,
          'fk_workout_id': workout.id,
          'type': exercise.type
        });
      }
    });
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
      var idQuery = await db.query('workout_record',
          columns: ['id'], orderBy: 'id DESC', limit: 1);
      if (idQuery.isNotEmpty) {
        int? id = idQuery[0]['id'] as int?;
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
    int? id;
    db.transaction((txn) async {
      List<Map<String, Object?>> query = await txn.query('exercise_record',
          columns: ['id'],
          where: 'fk_workout_record_id=?',
          whereArgs: [workoutRecordId],
          orderBy: 'id');
      List<int> exerciseRecordIds = [];
      for (int i = 0; i < query.length; i++) {
        exerciseRecordIds.add(query[i]['id'] as int);
      }
      for (int i = 0; i < exerciseRecordIds.length; i++) {
        await txn.delete('exercise_set',
            where: 'fk_exercise_record_id=?',
            whereArgs: [exerciseRecordIds[i]]);
      }
      for (int i = 0; i < query.length; i++) {
        await txn.delete('exercise_record',
            where: 'fk_workout_record_id=?', whereArgs: [workoutRecordId]);
      }
      id = await txn.delete('workout_record',
          where: 'id=?', whereArgs: [workoutRecordId]);
    });
    if (id == null) {
      return -1;
    } else {
      return id!;
    }
  }

  Future<WorkoutRecord> getCachedSession() async {
    final db = await instance.database;
    List<ExerciseRecord> cachedExerciseRecords = [];
    List<Map<String, Object?>> queryCachedWorkoutRecord = await db.query(
        'workout_record',
        columns: ['id', 'day', 'workout_name', 'fk_workout_id'],
        orderBy: 'id DESC',
        limit: 1);
    int cachedWorkoutRecordId = queryCachedWorkoutRecord[0]['id'] as int;

    List<Map<String, Object?>> queryCachedExerciseRecords = await db.query(
        'exercise_record',
        columns: ['id', 'exercise_name', 'fk_exercise_id'],
        where: 'fk_workout_record_id=?',
        whereArgs: [cachedWorkoutRecordId],
        orderBy: 'id');
    for (int i = 0; i < queryCachedExerciseRecords.length; i++) {
      List<Map<String, dynamic>> cachedSets = [];

      int id = queryCachedExerciseRecords[i]['id'] as int;
      String exerciseName =
          queryCachedExerciseRecords[i]['exercise_name'] as String;
      int exerciseId = queryCachedExerciseRecords[i]['fk_exercise_id'] as int;

      List<Map<String, Object?>> queryCachedExerciseSets = await db.query(
          'exercise_set',
          columns: ['reps', 'weight', 'rpe'],
          where: 'fk_exercise_record_id=?',
          whereArgs: [id],
          orderBy: 'id');

      for (int j = 0; j < queryCachedExerciseSets.length; j++) {
        int reps = queryCachedExerciseSets[j]['reps'] as int;
        double weight = queryCachedExerciseSets[j]['weight'] as double;
        int rpe = queryCachedExerciseSets[j]['rpe'] as int;
        cachedSets.add({'reps': reps, 'weight': weight, 'rpe': rpe});
      }

      cachedExerciseRecords.add(
          ExerciseRecord(exerciseName, cachedSets, exerciseId: exerciseId));
    }

    DateTime day = DateTime.parse(
        sqlToDartDate(queryCachedWorkoutRecord[0]['day'] as String));
    String workoutName = queryCachedWorkoutRecord[0]['workout_name'] as String;
    int workoutId = queryCachedWorkoutRecord[0]['fk_workout_id'] as int;
    return WorkoutRecord(
        cachedWorkoutRecordId, day, workoutName, cachedExerciseRecords,
        workoutId: workoutId);
  }

  Future<List<WorkoutRecord>> readWorkoutRecords(
      {bool cacheMode = false}) async {
    bool cached = false;

    final db = await instance.database;

    if (cacheMode) {}

    var pref = await SharedPreferences.getInstance();
    if (!cacheMode) {
      bool? temp = await pref.getBool('didCacheSession');
      if (temp != null) {
        cached = temp;
      }
    }

    List<WorkoutRecord> workoutRecords = [];

    //we get all the workout records
    List<Map<String, Object?>> queryWorkoutRecords = await db.query(
        'workout_record',
        columns: ['id', 'day', 'workout_name', 'fk_workout_id'],
        orderBy: 'id');

    //we get all the exercise records
    for (int i = 0; i < queryWorkoutRecords.length; i++) {
      List<ExerciseRecord> exerciseRecords = [];
      int workoutRecordId = queryWorkoutRecords[i]['id'] as int;
      List<Map<String, Object?>> queryExerciseRecords = await db.query(
          'exercise_record',
          columns: ['id', 'exercise_name', 'fk_exercise_id'],
          where: 'fk_workout_record_id=?',
          whereArgs: [workoutRecordId],
          orderBy: 'id');

      //we get all the exercise sets
      for (int j = 0; j < queryExerciseRecords.length; j++) {
        int exerciseRecordId = queryExerciseRecords[j]['id'] as int;
        List<Map<String, Object?>> queryExerciseSets = await db.query(
            'exercise_set',
            columns: ['id', 'reps', 'weight', 'rpe', 'record'],
            where: 'fk_exercise_record_id=?',
            whereArgs: [exerciseRecordId],
            orderBy: 'id');
        //we get the information about every exercise set
        List<Map<String, dynamic>> repsWeightRpeMap = [];
        for (int k = 0; k < queryExerciseSets.length; k++) {
          int reps = queryExerciseSets[k]['reps'] as int;
          double weight = queryExerciseSets[k]['weight'] as double;
          int rpe = queryExerciseSets[k]['rpe'] as int;
          int hasRecord = queryExerciseSets[k]['record'] as int;
          Map<String, dynamic> value = {
            'reps': reps,
            'weight': weight,
            'rpe': rpe,
            'hasRecord': hasRecord
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

    //if didFailCache is true, the caching process was started but not finished
    //and it is necessary to remove the corrupted cache
    bool? temp = await pref.getBool('didFailCache');
    if (temp != null) {
      if (temp) {
        int id = workoutRecords.removeLast().id;
        await removeWorkoutRecord(id);
        pref.setBool('didFailCache', false);
      }
    }
    if (!cacheMode && cached && workoutRecords.length > 0) {
      workoutRecords.removeLast();
    }
    return workoutRecords;
  }

  String sqlToDartDate(String sqlDate) {
    String year = '';
    String month = '';
    String day = '';
    int j;
    for (j = 0; sqlDate[j] != '-'; j++) {
      year += sqlDate[j];
    }
    for (j = j + 1; sqlDate[j] != '-'; j++) {
      month += sqlDate[j];
    }
    for (j = j + 1; j < sqlDate.length; j++) {
      day += sqlDate[j];
    }
    String dartDate = '';
    dartDate += year + '-';
    if (month.length < 2) {
      dartDate += '0' + month + '-';
    } else {
      dartDate += month + '-';
    }
    if (day.length < 2) {
      dartDate += '0' + day;
    } else {
      dartDate += day;
    }
    return dartDate;
  }

  Future<Map<String, dynamic>> getBestWeightVolumeReps(
      int exerciseJsonId, Transaction txn) async {
    var queryRecords = await txn.query('best_weight_volume_reps',
        columns: ['best_weight', 'best_volume', 'best_reps'],
        where: 'json_id=?',
        whereArgs: [exerciseJsonId]);

    if (queryRecords.isEmpty) {
      return {'best_weight': null, 'best_volume': null, 'best_reps': null};
    }

    return {
      'best_weight': queryRecords[0]['best_weight'],
      'best_volume': queryRecords[0]['best_volume'],
      'best_reps': queryRecords[0]['best_reps']
    };
  }

  Future setBestWeightVolumeReps(
      int exerciseJsonId, Map<String, dynamic> data, Transaction txn) async {
    double? bestWeight = data['best_weight'];
    int? bestVolume = data['best_volume'];
    int? bestReps = data['best_reps'];

    var query = await txn.query('best_weight_volume_reps',
        columns: ['json_id'], where: 'json_id=?', whereArgs: [exerciseJsonId]);
    if (query.isEmpty) {
      txn.insert('best_weight_volume_reps', {
        'json_id': exerciseJsonId,
        'best_weight': bestWeight,
        'best_volume': bestVolume,
        'best_reps': bestReps
      });
    } else {
      txn.update(
          'best_weight_volume_reps',
          {
            'best_weight': bestWeight,
            'best_volume': bestVolume,
            'best_reps': bestReps
          },
          where: 'json_id=?',
          whereArgs: [exerciseJsonId]);
    }
  }

  Future setWeightRecord(
      int exerciseId, double weightRecord, Transaction txn) async {
    await txn.update('exercise', {'weight_record': weightRecord},
        where: 'id=?', whereArgs: [exerciseId]);
  }

  Future<bool> addWorkoutRecord(WorkoutRecord workoutRecord, Workout workout,
      {bool cacheMode = false}) async {
    // delete all exercise records with empty sets
    // and track their indexes
    //await removeCachedSession();
    final db = await instance.database;
    bool didSetWeightRecord = false;
    await db.transaction((txn) async {
      List<Exercise> tempExercises = [];
      // addAll to prevent exercises disappearing in Workouts page

      tempExercises.addAll(workout.exercises);

      List<int> indexes = [];

      workoutRecord.exerciseRecords.removeWhere((element) {
        print(element.reps_weight_rpe);
        if (element.reps_weight_rpe.isEmpty) {
          indexes.add(workoutRecord.exerciseRecords.indexOf(element));
          return true;
        }
        return false;
      });

      var pref = await SharedPreferences.getInstance();

      // if every exercise record has been deleted, the session is not valid
      // and will not be saved
      if (workoutRecord.exerciseRecords.isEmpty) {
        throw Exception('empty_exercises');
      }

      // from the workout schedule, delete all the exercises that were
      // not excecuted in this session
      for (int i = 0; i < indexes.length; i++) {
        tempExercises.removeAt(i);
      }

      // don't save any weight records if in cache mode
      if (!cacheMode) {
        // check if there were weight records in this session
        // among all the exercises that were excecuted
        for (int i = 0; i < tempExercises.length; i++) {
          Exercise exercise = tempExercises[i];
          var reps_weight_rpe =
              workoutRecord.exerciseRecords[i].reps_weight_rpe;
          var previousRecords =
              await getBestWeightVolumeReps(exercise.jsonId, txn);
          if (exercise.type == 'free') {
            int recordIndex = 0;
            int currentMaxReps = reps_weight_rpe[0]['reps'];
            for (int j = 0; j < reps_weight_rpe.length - 1; j++) {
              int maxReps = max(currentMaxReps, reps_weight_rpe[j + 1]['reps']);
              if (maxReps > currentMaxReps) {
                recordIndex = j;
              }
              currentMaxReps = maxReps;
            }
            int prevReps = -1;
            if (previousRecords['best_reps'] != null) {
              prevReps = previousRecords['best_reps'] as int;
            }
            if (currentMaxReps > prevReps) {
              didSetWeightRecord = true;
              reps_weight_rpe[recordIndex]['hasRecord'] = 1;
              await setBestWeightVolumeReps(
                  exercise.jsonId,
                  {'best_weight': null, 'best_volume': null, 'best_reps': null},
                  txn);
            }
          } else {
            double currentMaxWeight = reps_weight_rpe[0]['weight'];
            int recordIndex = 0;
            for (int j = 0; j < reps_weight_rpe.length - 1; j++) {
              double maxWeight =
                  max(currentMaxWeight, reps_weight_rpe[j + 1]['weight']);
              if (maxWeight > currentMaxWeight) {
                recordIndex = j;
              }
              currentMaxWeight = maxWeight;
            }
            int currentMaxVolume =
                (reps_weight_rpe[0]['weight'] * reps_weight_rpe[0]['reps'])
                    .round();
            for (int j = 0; j < reps_weight_rpe.length - 1; j++) {
              int nextVolume = reps_weight_rpe[j + 1]['weight'] *
                  reps_weight_rpe[j + 1]['reps'];
              int maxVolume = max(currentMaxVolume, nextVolume);
              if (maxVolume > currentMaxVolume) {
                recordIndex = j;
              }
              currentMaxVolume = maxVolume;
            }
            double maxWeight = -1;
            if (previousRecords['best_weight'] != null) {
              maxWeight = previousRecords['best_weight'] as double;
            }
            int maxVolume = -1;
            if (previousRecords['best_volume'] != null) {
              maxVolume = previousRecords['best_volume'] as int;
            }
            if (currentMaxWeight > maxWeight) {
              didSetWeightRecord = true;
              maxWeight = currentMaxWeight;
            }
            if (currentMaxVolume > maxVolume) {
              didSetWeightRecord = true;
              maxVolume = currentMaxVolume;
            }
            if (didSetWeightRecord) {
              reps_weight_rpe[recordIndex]['hasRecord'] = 1;
              setBestWeightVolumeReps(
                  exercise.jsonId,
                  {
                    'best_weight': maxWeight,
                    'best_volume': maxVolume,
                    'best_reps': null
                  },
                  txn);
            }
          }

          DateTime now = DateTime.now();
          String day = '${now.year}-${now.month}-${now.day}';
          Map<String, Object> values = {
            'day': day,
            'workout_name': workoutRecord.workoutName,
            'fk_workout_id': workoutRecord.workoutId
          };
          int workoutRecordId = await txn.insert('workout_record', values);
          values.clear();

          // save that we saved a cache session right after saving the workout_record row

          for (int i = 0; i < workoutRecord.exerciseRecords.length; i++) {
            ExerciseRecord exerciseRecord = workoutRecord.exerciseRecords[i];

            values = {
              'fk_workout_record_id': workoutRecordId,
              'exercise_name': workoutRecord.exerciseRecords[i].exerciseName,
              'fk_exercise_id': workoutRecord.exerciseRecords[i].exerciseId
            };
            int exerciseRecordId = await txn.insert('exercise_record', values);
            values.clear();

            for (int j = 0; j < exerciseRecord.reps_weight_rpe.length; j++) {
              var repsWeightRpe = exerciseRecord.reps_weight_rpe[j];
              int reps = repsWeightRpe['reps'] as int;
              double weight = repsWeightRpe['weight'] as double;
              int rpe = repsWeightRpe['rpe'] as int;
              int hasRecord = repsWeightRpe['hasRecord'] as int;
              print(hasRecord);
              values = {
                'reps': reps,
                'weight': weight,
                'rpe': rpe,
                'record': hasRecord,
                'fk_exercise_record_id': exerciseRecordId
              };
              await txn.insert('exercise_set', values);
            }
          }
        }
      }
      if (cacheMode) {
        await pref.setBool('didCacheSession', true);
      }
    });
    return didSetWeightRecord;
  }

  Future removeWorkout(int id) async {
    final db = await instance.database;
    db.transaction((txn) async {
      await txn.delete('exercise', where: 'fk_workout_id=?', whereArgs: [id]);
      await txn.delete('workout', where: 'id=?', whereArgs: [id]);
    });
  }

  Future<List<Workout>> readWorkouts() async {
    List<Workout> workoutList = [];
    final db = await instance.database;
    final queryWorkouts =
        await db.query('workout', columns: ['id', 'name'], orderBy: 'id');
    for (int i = 0; i < queryWorkouts.length; i++) {
      int id = queryWorkouts[i]['id'] as int;
      String name = queryWorkouts[i]['name'] as String;
      List<Exercise> exerciseList = [];
      final queryExercise = await db.query('exercise',
          columns: ['id', 'json_id', 'sets', 'type', 'reps', 'fk_workout_id'],
          where: 'fk_workout_id=?',
          whereArgs: [id],
          orderBy: 'id');
      for (int j = 0; j < queryExercise.length; j++) {
        int exid = queryExercise[j]['id'] as int;
        int sets = queryExercise[j]['sets'] as int;
        int reps = queryExercise[j]['reps'] as int;
        int workoutId = queryExercise[j]['fk_workout_id'] as int;
        int jsonId = queryExercise[j]['json_id'] as int;
        var exerciseData = await Helper.getExerciseData();
        String exname =
            exerciseData.where((element) => element.id == jsonId).first.name;
        String type = queryExercise[j]['type'] as String;

        exerciseList.add(Exercise(
            id: exid,
            jsonId: jsonId,
            name: exname,
            sets: sets,
            reps: reps,
            type: type,
            workoutId: workoutId));
      }
      workoutList.add(Workout(id, name, exerciseList));
    }
    return workoutList;
  }

  Future createWorkout(String name, List<Exercise> exercises) async {
    final db = await instance.database;
    db.transaction((txn) async {
      final id = await txn.insert('workout', {'name': name});
      for (int i = 0; i < exercises.length; i++) {
        var exercise = exercises[i];
        txn.insert('exercise', {
          'json_id': exercise.jsonId,
          'sets': exercise.sets,
          'reps': exercise.reps,
          'fk_workout_id': id,
          'type': exercise.type
        });
      }
    });
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
