import 'dart:math';
import 'dart:developer' as dev;
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';
import 'package:lift_tracker/data/classes/workouthistory.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:sqflite/sqflite.dart';
import '../classes/exercise.dart';
import '../classes/workout.dart';
import 'structure.dart';

class CustomDatabase {
  static final instance = CustomDatabase._init();

  static Database? _database;

  int workoutsOffset = 0;
  int workoutRecordsCount = 0;
  bool didReadWorkoutRecords = false;
  bool didReadAllWorkoutRecords = false;
  bool didReadWorkouts = false;
  String? dbPath = null;

  final int searchLimit = 2;

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
    this.dbPath = dbPath;
    return await openDatabase(path, version: 1, onCreate: createDB);
  }

  Future<bool> editWorkout(Workout workout) async {
    final db = await instance.database;
    int count = -1;
    await db.transaction((txn) async {
      List<int> idsToSpare = [];
      count = await txn.update('workout', {'name': workout.name},
          where: 'id=?', whereArgs: [workout.id]);
      var currentExercisesQuery = await txn.query('exercise',
          columns: ['id', 'json_id'],
          where: 'fk_workout_id=?',
          whereArgs: [workout.id]);
      for (int i = 0; i < workout.exercises.length; i++) {
        Exercise exercise = workout.exercises[i];
        if (currentExercisesQuery.any((element) =>
            element['id'] as int == exercise.id &&
            element['json_id'] == exercise.exerciseData.id)) {
          await txn.update(
              'exercise',
              {
                'reps': exercise.reps,
                'sets': exercise.sets,
                'notes': exercise.notes,
                'order_number': i
              },
              where: 'id=?',
              whereArgs: [exercise.id]);
          idsToSpare.add(exercise.id);
        } else {
          int id = await txn.insert('exercise', {
            'json_id': exercise.exerciseData.id,
            'reps': exercise.reps,
            'sets': exercise.sets,
            'fk_workout_id': workout.id,
            'type': exercise.exerciseData.type,
            'notes': exercise.notes,
            'order_number': i
          });
          idsToSpare.add(id);
        }
      }
      for (var e in currentExercisesQuery) {
        if (!idsToSpare.any((element) => element == e['id'] as int)) {
          await txn
              .delete('exercise', where: 'id=?', whereArgs: [e['id'] as int]);
        }
      }
    });
    return count > 0;
  }

  Future<bool> removeWorkoutRecord(int workoutRecordId) async {
    final db = await instance.database;
    int id = -1;
    await db.transaction((txn) async {
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
    if (id > 0) {
      workoutRecordsCount -= 1;
    }
    return id > 0;
  }

  Future<List<WorkoutRecord>> readWorkoutRecords(
      {bool cacheMode = false,
      int? workoutRecordId,
      bool readAll = false,
      int? workoutId}) async {
    dev.log('Reading workout records from db...');
    final db = await instance.database;

    List<WorkoutRecord> workoutRecords = [];
    List<Map<String, Object?>> queryWorkoutRecords;

    await db.transaction((txn) async {
      int? limit = searchLimit;
      bool shouldContinue = true;
      if (readAll) {
        queryWorkoutRecords = await txn.query('workout_record',
            columns: ['id', 'day', 'workout_name', 'fk_workout_id', 'is_cache'],
            orderBy: 'day DESC');
      } else if (cacheMode) {
        queryWorkoutRecords = await txn.query('workout_record',
            columns: ['id', 'day', 'workout_name', 'fk_workout_id'],
            orderBy: 'day DESC',
            where: 'is_cache=? AND fk_workout_id=?',
            whereArgs: [1, workoutId],
            limit: 1);
        if (queryWorkoutRecords.isEmpty) {
          await txn.update('workout', {'has_cache': 0},
              where: 'id=?', whereArgs: [workoutId]);
          shouldContinue = false;
        }
      } else {
        if (workoutRecordId == null) {
          queryWorkoutRecords = await txn.query('workout_record',
              columns: ['id', 'day', 'workout_name', 'fk_workout_id'],
              offset: limit != null ? workoutRecordsCount : null,
              orderBy: 'day DESC',
              where: 'is_cache=?',
              whereArgs: [0],
              limit: limit);
          workoutRecordsCount += queryWorkoutRecords.length;
          didReadWorkoutRecords = true;
          if (queryWorkoutRecords.isEmpty) {
            didReadAllWorkoutRecords = true;
          }
        } else {
          queryWorkoutRecords = await txn.query('workout_record',
              columns: ['id', 'day', 'workout_name', 'fk_workout_id'],
              offset: 0,
              orderBy: 'day DESC',
              where: 'id=? AND is_cache=?',
              whereArgs: [workoutRecordId, 0],
              limit: 1);
        }
      }

      if (shouldContinue) {
        //we get all the exercise records
        for (int i = 0; i < queryWorkoutRecords.length; i++) {
          List<ExerciseRecord> exerciseRecords = [];
          int woRecordId = queryWorkoutRecords[i]['id'] as int;
          List<Map<String, Object?>> queryExerciseRecords = await txn.query(
              'exercise_record',
              columns: ['id', 'json_id', 'fk_exercise_id', 'type'],
              where: 'fk_workout_record_id=?',
              whereArgs: [woRecordId],
              orderBy: 'position_in_workout_record');

          //we get all the exercise sets
          for (int j = 0; j < queryExerciseRecords.length; j++) {
            int exerciseRecordId = queryExerciseRecords[j]['id'] as int;
            List<Map<String, Object?>> queryExerciseSets = await txn.query(
              'exercise_set',
              columns: [
                'id',
                'reps',
                'weight',
                'rpe',
                'has_volume_record',
                'has_weight_record',
                'has_reps_record'
              ],
              where: 'fk_exercise_record_id=?',
              whereArgs: [exerciseRecordId],
            );
            //we get the information about every exercise set
            List<ExerciseSet> repsWeightRpes = [];
            for (int k = 0; k < queryExerciseSets.length; k++) {
              int reps = queryExerciseSets[k]['reps'] as int;
              double weight = queryExerciseSets[k]['weight'] as double;
              int? rpe = queryExerciseSets[k]['rpe'] as int?;
              int hasVolumeRecord =
                  queryExerciseSets[k]['has_volume_record'] as int;
              int hasWeightRecord =
                  queryExerciseSets[k]['has_weight_record'] as int;
              int hasRepsRecord =
                  queryExerciseSets[k]['has_reps_record'] as int;
              repsWeightRpes.add(ExerciseSet(
                  weight: weight,
                  reps: reps,
                  rpe: rpe,
                  hasVolumeRecord: hasVolumeRecord,
                  hasWeightRecord: hasWeightRecord,
                  hasRepsRecord: hasRepsRecord));
            }
            //we create the exercise record and add it to the list
            int jsonId = queryExerciseRecords[j]['json_id'] as int;
            int exerciseId = queryExerciseRecords[j]['fk_exercise_id'] as int;
            String type = queryExerciseRecords[j]['type'] as String;
            var exerciseQuery = await txn.query('exercise',
                columns: ['id', 'sets', 'reps'],
                where: 'id=?',
                whereArgs: [exerciseId]);
            ExerciseData exerciseData = Helper.instance.exerciseDataGlobal
                .firstWhere((element) => element.id == jsonId);
            Exercise? exercise = exerciseQuery.isEmpty
                ? null
                : Exercise(
                    workoutId: queryWorkoutRecords[i]['fk_workout_id'] as int,
                    id: exerciseQuery.first['id'] as int,
                    sets: exerciseQuery.first['sets'] as int,
                    reps: exerciseQuery.first['reps'] as int,
                    exerciseData: exerciseData);
            ExerciseRecord exerciseRecord = ExerciseRecord(
                exerciseId: exerciseId,
                exerciseData: exerciseData,
                sets: repsWeightRpes,
                exercise: exercise,
                type: type);
            exerciseRecords.add(exerciseRecord);
          }
          //we get the information about the workout
          String workoutName = queryWorkoutRecords[i]['workout_name'] as String;
          DateTime day = DateTime.fromMillisecondsSinceEpoch(
              queryWorkoutRecords[i]['day'] as int);
          int workoutId = queryWorkoutRecords[i]['fk_workout_id'] as int;
          int? isCache;
          if (readAll) {
            isCache = queryWorkoutRecords[i]['is_cache'] as int;
          }
          workoutRecords.add(WorkoutRecord(
              woRecordId, day, workoutName, exerciseRecords,
              workoutId: workoutId, isCache: isCache ?? 0));
        }
      }
    });
    for (var workoutRecord in workoutRecords) {
      for (var exerciseRecord in workoutRecord.exerciseRecords) {
        if (exerciseRecord.exerciseId == 0) {
          dev.log(
              'DB: ${exerciseRecord.exerciseData.name} from workout ${workoutRecord.workoutName} has exerciseId == 0');
        }
      }
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
      int exerciseId, Transaction txn) async {
    var queryRecords = await txn.query('exercise',
        columns: ['best_weight', 'best_volume', 'best_reps'],
        where: 'id=?',
        whereArgs: [exerciseId]);

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
      int exerciseId, Map<String, dynamic> data, Transaction txn) async {
    double? bestWeight = data['best_weight'];
    int? bestVolume = data['best_volume'];
    int? bestReps = data['best_reps'];

    await txn.update(
        'exercise',
        {
          'best_weight': bestWeight,
          'best_volume': bestVolume,
          'best_reps': bestReps
        },
        where: 'id=?',
        whereArgs: [exerciseId]);
  }

  Future setWeightRecord(
      int exerciseId, double weightRecord, Transaction txn) async {
    await txn.update('exercise', {'weight_record': weightRecord},
        where: 'id=?', whereArgs: [exerciseId]);
  }

  Future<bool> hasHistory(int workoutId) async {
    final db = await instance.database;
    var query = await db.query('workout_record',
        where: 'fk_workout_id=? AND is_cache=?',
        whereArgs: [workoutId, 0],
        limit: 1);
    return query.isNotEmpty;
  }

  Future<WorkoutHistory> getWorkoutHistory(Workout workout) async {
    final db = await instance.database;
    List<WorkoutRecord> workoutRecords = [];
    await db.transaction((txn) async {
      var queryWorkoutRecord = await txn.query('workout_record',
          columns: ['id', 'day'],
          where: 'fk_workout_id=? AND is_cache=?',
          whereArgs: [workout.id, 0]);

      for (int i = 0; i < queryWorkoutRecord.length; i++) {
        int workoutRecordId = queryWorkoutRecord[i]['id'] as int;
        var queryExerciseRecord = await txn.query('exercise_record',
            columns: ['id', 'fk_exercise_id', 'json_id', 'type'],
            where: 'fk_workout_record_id=?',
            whereArgs: [workoutRecordId],
            limit: 15);
        List<ExerciseRecord> exerciseRecords = [];
        for (int j = 0; j < queryExerciseRecord.length; j++) {
          int exerciseRecordId = queryExerciseRecord[j]['id'] as int;
          var queryExerciseSet = await txn.query('exercise_set',
              columns: [
                'weight',
                'reps',
                'rpe',
                'has_weight_record',
                'has_volume_record',
                'has_reps_record'
              ],
              where: 'fk_exercise_record_id=?',
              whereArgs: [exerciseRecordId]);
          List<ExerciseSet> sets = [];
          for (int k = 0; k < queryExerciseSet.length; k++) {
            int reps = queryExerciseSet[k]['reps'] as int;
            double weight = queryExerciseSet[k]['weight'] as double;
            int? rpe = queryExerciseSet[k]['rpe'] as int?;
            int hasRepsRecord = queryExerciseSet[k]['has_reps_record'] as int;
            int hasWeightRecord =
                queryExerciseSet[k]['has_weight_record'] as int;
            int hasVolumeRecord =
                queryExerciseSet[k]['has_volume_record'] as int;
            sets.add(ExerciseSet(
                reps: reps,
                rpe: rpe,
                weight: weight,
                hasRepsRecord: hasRepsRecord,
                hasVolumeRecord: hasVolumeRecord,
                hasWeightRecord: hasWeightRecord));
          }
          int jsonId = queryExerciseRecord[j]['json_id'] as int;
          int exerciseId = queryExerciseRecord[j]['fk_exercise_id'] as int;
          var exerciseQuery = await txn.query('exercise',
              columns: ['id', 'sets', 'reps'],
              where: 'id=?',
              whereArgs: [exerciseId]);
          ExerciseData exerciseData = Helper.instance.exerciseDataGlobal
              .firstWhere((element) => element.id == jsonId);
          Exercise? exercise = exerciseQuery.isEmpty
              ? null
              : Exercise(
                  workoutId: workout.id,
                  id: exerciseQuery.first['id'] as int,
                  sets: exerciseQuery.first['sets'] as int,
                  reps: exerciseQuery.first['reps'] as int,
                  exerciseData: exerciseData);
          String type = queryExerciseRecord[j]['type'] as String;
          ExerciseRecord exerciseRecord = ExerciseRecord(
              exerciseId: exerciseId,
              exerciseData: exerciseData,
              sets: sets,
              exercise: exercise,
              type: type);
          exerciseRecords.add(exerciseRecord);

          exerciseRecords.add(exerciseRecord);
        }
        DateTime day = DateTime.fromMillisecondsSinceEpoch(
            queryWorkoutRecord[i]['day'] as int);
        String workoutName = workout.name;
        workoutRecords.add(WorkoutRecord(
            workoutRecordId, day, workoutName, exerciseRecords,
            workoutId: workout.id));
      }
    });
    return WorkoutHistory(workout: workout, workoutRecords: workoutRecords);
  }

  Future<WorkoutRecord?> getCachedSession({required int workoutId}) async {
    WorkoutRecord? cachedSession;
    await CustomDatabase.instance
        .readWorkoutRecords(cacheMode: true, workoutId: workoutId)
        .then((workoutRecords) {
      if (workoutRecords.isEmpty) {
        return;
      }
      cachedSession = workoutRecords.first;
    });
    return cachedSession;
  }

  Future<Map<String, int>> addWorkoutRecord(WorkoutRecord workoutRecord,
      {bool cacheMode = false, bool backupMode = false}) async {
    // delete all exercise records with empty sets
    // and track their indexes
    //await removeCachedSession();
    final db = await instance.database;
    int workoutRecordId = -1;
    bool didSetWeightRecord = false;
    await db.transaction((txn) async {
      var hasCacheQuery = await txn.query('workout',
          columns: ['id', 'has_cache'],
          where: 'id=?',
          limit: 1,
          whereArgs: [workoutRecord.workoutId]);
      bool cached = (hasCacheQuery[0]['has_cache'] as int) == 1;
      if (cached) {
        var idQuery = await txn.query('workout_record',
            columns: ['id'],
            orderBy: 'day DESC',
            limit: 1,
            where: 'is_cache=? AND fk_workout_id=?',
            whereArgs: [1, hasCacheQuery[0]['id'] as int]);
        if (idQuery.isNotEmpty) {
          int? id = idQuery[0]['id'] as int?;
          if (id != null) {
            List<Map<String, Object?>> query = await txn.query(
                'exercise_record',
                columns: ['id'],
                where: 'fk_workout_record_id=?',
                whereArgs: [id],
                orderBy: 'id DESC');
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
                  where: 'fk_workout_record_id=?', whereArgs: [id]);
            }
            id = await txn
                .delete('workout_record', where: 'id=?', whereArgs: [id]);
          }
        }
      }

      // don't save any weight records if in cache mode
      if (!cacheMode) {
        workoutRecord.exerciseRecords
            .removeWhere((element) => element.sets.isEmpty);
        // if every exercise record has been deleted, the session is not valid
        // and will not be saved
        if (workoutRecord.exerciseRecords.isEmpty) {
          throw Exception('empty_exercises');
        }
        // check if there were weight records in this session
        // among all the exercises that were excecuted

        for (int i = 0; i < workoutRecord.exerciseRecords.length; i++) {
          ExerciseRecord exerciseRecord = workoutRecord.exerciseRecords[i];
          if (exerciseRecord.exerciseId == 0) {
            throw Exception('Exercise record has exerciseId = 0');
          }
          if (!workoutRecord.exerciseRecords[i].temp) {
            var sets = workoutRecord.exerciseRecords[i].sets;
            var previousRecords =
                await getBestWeightVolumeReps(exerciseRecord.exerciseId, txn);
            if (exerciseRecord.type == 'free') {
              int recordIndex = 0;
              int currentMaxReps = sets[0].reps;
              for (int j = 0; j < sets.length - 1; j++) {
                int maxReps = max(currentMaxReps, sets[j + 1].reps);
                if (maxReps > currentMaxReps) {}
                currentMaxReps = maxReps;
              }
              int prevReps = -1;
              if (previousRecords['best_reps'] != null) {
                prevReps = previousRecords['best_reps'] as int;
              }
              recordIndex =
                  sets.indexWhere((element) => element.reps == currentMaxReps);
              if (currentMaxReps > prevReps) {
                didSetWeightRecord = true;
                sets[recordIndex].hasRepsRecord = 1;
                await setBestWeightVolumeReps(
                    exerciseRecord.exerciseId,
                    {
                      'best_weight': null,
                      'best_volume': null,
                      'best_reps': currentMaxReps
                    },
                    txn);
              }
            } else {
              double currentMaxWeight = sets[0].weight;
              int recordIndex = 0;
              for (int j = 0; j < sets.length - 1; j++) {
                double maxWeight = max(currentMaxWeight, sets[j + 1].weight);
                if (maxWeight > currentMaxWeight) {
                  recordIndex = j;
                }
                currentMaxWeight = maxWeight;
              }
              int currentMaxVolume = (sets[0].weight * sets[0].reps).round();
              for (int j = 0; j < sets.length - 1; j++) {
                int nextVolume =
                    (sets[j + 1].weight * sets[j + 1].reps).round();
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
              recordIndex = sets
                  .indexWhere((element) => element.weight == currentMaxWeight);
              if (currentMaxWeight > maxWeight) {
                didSetWeightRecord = true;
                maxWeight = currentMaxWeight;
                sets[recordIndex].hasWeightRecord = 1;
              }
              recordIndex = sets.indexWhere((element) {
                return (element.reps * element.weight).round() ==
                    currentMaxVolume;
              });
              if (currentMaxVolume > maxVolume) {
                didSetWeightRecord = true;
                maxVolume = currentMaxVolume;
                sets[recordIndex].hasVolumeRecord = 1;
              }
              if (didSetWeightRecord) {
                await setBestWeightVolumeReps(
                    exerciseRecord.exerciseId,
                    {
                      'best_weight': maxWeight,
                      'best_volume': maxVolume,
                      'best_reps': null
                    },
                    txn);
              }
            }
          }
        }
      }
      DateTime date = workoutRecord.day;
      int day = date.millisecondsSinceEpoch;
      Map<String, Object?> values = {
        'day': day,
        'workout_name': workoutRecord.workoutName,
        'fk_workout_id': workoutRecord.workoutId,
        'is_cache': cacheMode ? 1 : 0
      };
      if (backupMode) {
        values['is_cache'] = workoutRecord.isCache;
      }
      workoutRecordId = await txn.insert('workout_record', values);
      await txn.query('workout_record', columns: ['workout_name', 'is_cache']);
      if (!backupMode) {
        if (cacheMode) {
          await txn.update('workout', {'has_cache': 1},
              where: 'id=?', whereArgs: [workoutRecord.workoutId]);
        } else if (cached) {
          await txn.update('workout', {'has_cache': 0},
              where: 'id=?', whereArgs: [workoutRecord.workoutId]);
        }
      }
      values.clear();

      for (int i = 0; i < workoutRecord.exerciseRecords.length; i++) {
        ExerciseRecord exerciseRecord = workoutRecord.exerciseRecords[i];

        values = {
          'fk_workout_record_id': workoutRecordId,
          'json_id': workoutRecord.exerciseRecords[i].exerciseData.id,
          'fk_exercise_id': workoutRecord.exerciseRecords[i].exerciseId,
          'type': workoutRecord.exerciseRecords[i].type,
          'position_in_workout_record': i
        };

        int exerciseRecordId = await txn.insert('exercise_record', values);
        values.clear();

        for (int j = 0; j < exerciseRecord.sets.length; j++) {
          var repsWeightRpe = exerciseRecord.sets[j];
          int reps = repsWeightRpe.reps;
          double weight = repsWeightRpe.weight;
          int? rpe = repsWeightRpe.rpe;
          if (rpe != null && rpe > 10) {
            rpe = 10;
          }
          int hasRepsRecord = repsWeightRpe.hasRepsRecord;
          int hasWeightRecord = repsWeightRpe.hasWeightRecord;
          int hasVolumeRecord = repsWeightRpe.hasVolumeRecord;
          values = {
            'reps': reps,
            'weight': weight,
            'rpe': rpe,
            'has_weight_record': hasWeightRecord,
            'has_reps_record': hasRepsRecord,
            'has_volume_record': hasVolumeRecord,
            'fk_exercise_record_id': exerciseRecordId
          };
          await txn.insert('exercise_set', values);
        }
      }
    });
    // if we did not read yet the workout records, don't increment the count here. It will
    // be incremented in the readWorkoutRecords function
    if (!backupMode && !cacheMode && didReadWorkoutRecords) {
      workoutRecordsCount += 1;
    }
    return {
      'workoutRecordId': workoutRecordId,
      'didSetRecord': didSetWeightRecord ? 1 : 0
    };
  }

  Future<bool> removeCachedSession(int workoutId) async {
    final db = await instance.database;
    int deleted = 0;
    await db.transaction((txn) async {
      var workoutRecordIdQuery = await txn.query('workout_record',
          columns: ['id'],
          where: 'fk_workout_id=? AND is_cache=?',
          whereArgs: [workoutId, 1]);
      if (workoutRecordIdQuery.isEmpty) {
        return;
      }
      int workoutRecordId = workoutRecordIdQuery[0]['id'] as int;

      deleted = await txn.delete('workout_record',
          where: 'fk_workout_id=? AND is_cache=?', whereArgs: [workoutId, 1]);
      var exRecordsQuery = await txn.query('exercise_record',
          columns: ['id'],
          where: 'fk_workout_record_id=?',
          whereArgs: [workoutRecordId]);
      for (int i = 0; i < exRecordsQuery.length; i++) {
        int exerciseRecordId = exRecordsQuery[i]['id'] as int;
        await txn.delete('exercise_set',
            where: 'fk_exercise_record_id=?', whereArgs: [exerciseRecordId]);
        await txn.delete('exercise_record',
            where: 'id=?', whereArgs: [exerciseRecordId]);
      }
      await txn.update('workout', {'has_cache': 0},
          where: 'id=?', whereArgs: [workoutId]);
    });
    return deleted >= 1;
  }

  Future<bool> removeWorkout(int workoutId) async {
    final db = await instance.database;
    int id = -1;
    await db.transaction((txn) async {
      await txn
          .delete('exercise', where: 'fk_workout_id=?', whereArgs: [workoutId]);
      id = await txn.delete('workout', where: 'id=?', whereArgs: [workoutId]);
    });
    return id > 0;
  }

  Future<List<Workout>> readWorkouts(
      {int? workoutId, bool readAll = false}) async {
    dev.log('Reading workouts from db...');
    List<Workout> workoutList = [];
    final db = await instance.database;
    var queryWorkouts;

    int? limit = searchLimit;

    if (readAll) {
      limit = null;
      workoutsOffset = 0;
    }

    if (workoutId == null) {
      int? offset = limit != null ? workoutsOffset * limit : null;
      queryWorkouts = await db.query('workout',
          columns: ['id', 'name', 'has_cache'],
          orderBy: 'id DESC',
          offset: offset,
          limit: limit);
      workoutsOffset += 1;
    } else {
      queryWorkouts = await db.query('workout',
          columns: ['id', 'name', 'has_cache'],
          orderBy: 'id DESC',
          offset: 0,
          limit: 1,
          where: 'id=?',
          whereArgs: [workoutId]);
    }
    for (int i = 0; i < queryWorkouts.length; i++) {
      int id = queryWorkouts[i]['id'] as int;
      String name = queryWorkouts[i]['name'] as String;
      int hasCache = queryWorkouts[i]['has_cache'] as int;
      List<Exercise> exerciseList = [];
      final queryExercise = await db.query('exercise',
          columns: [
            'id',
            'json_id',
            'sets',
            'type',
            'reps',
            'best_weight',
            'best_volume',
            'best_reps',
            'fk_workout_id'
          ],
          where: 'fk_workout_id=?',
          whereArgs: [id],
          orderBy: 'order_number');
      for (int j = 0; j < queryExercise.length; j++) {
        int exid = queryExercise[j]['id'] as int;
        int sets = queryExercise[j]['sets'] as int;
        int reps = queryExercise[j]['reps'] as int;
        int workoutId = queryExercise[j]['fk_workout_id'] as int;
        int jsonId = queryExercise[j]['json_id'] as int;
        var exerciseDataList = Helper.instance.exerciseDataGlobal;
        double? bestWeight = queryExercise[j]['best_weight'] as double?;
        int? bestVolume = queryExercise[j]['best_volume'] as int?;
        int? bestReps = queryExercise[j]['best_reps'] as int?;
        ExerciseData exerciseData =
            exerciseDataList.where((element) => element.id == jsonId).first;
        exerciseList.add(Exercise(
            id: exid,
            exerciseData: exerciseData,
            sets: sets,
            reps: reps,
            bestReps: bestReps,
            bestWeight: bestWeight,
            bestVolume: bestVolume,
            workoutId: workoutId));
      }
      workoutList.add(Workout(id, name, exerciseList, hasCache: hasCache));
    }
    didReadWorkouts = true;
    for (Workout workout in workoutList) {
      workout.hasHistory = await hasHistory(workout.id);
      for (var exercise in workout.exercises) {
        if (exercise.id == 0) {
          dev.log(
              'DB: Exercise ${exercise.exerciseData.name} from workout ${workout.name} has id == 0');
        }
      }
    }
    return workoutList;
  }

  Future printBuggedExerciseRecords() async {
    final db = await instance.database;
    var result = await db.query('exercise_record',
        columns: ['fk_exercise_id, json_id'], where: 'fk_exercise_id <= 0');
    result.forEach((element) {
      dev.log(element.toString());
      dev.log(Helper.instance.exerciseDataGlobal
          .firstWhere((a) => a.id == element['json_id'] as int)
          .name);
    });
  }

  Future<int> saveWorkout(Workout workout,
      {backupMode = false, workoutId = 0, int hasCache = 0}) async {
    final db = await instance.database;
    int id = -1;
    List exIds = [];
    await db.transaction((txn) async {
      Map<String, dynamic> woMap = {'name': workout.name};
      if (backupMode) {
        woMap.putIfAbsent('id', () => workoutId);
        woMap.putIfAbsent('has_cache', () => hasCache);
      }
      id = await txn.insert('workout', woMap);
      for (int i = 0; i < workout.exercises.length; i++) {
        var exercise = workout.exercises[i];
        var map = {
          'json_id': exercise.exerciseData.id,
          'sets': exercise.sets,
          'reps': exercise.reps,
          'order_number': i,
          'fk_workout_id': id,
          'type': exercise.exerciseData.type
        };
        if (backupMode) {
          map.putIfAbsent('id', () => exercise.id);
        }
        int exId = await txn.insert('exercise', map);
        exIds.add(exId);
      }
    });
    return id;
  }

  Future resetStats(int exerciseId) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.update('exercise',
          {'best_weight': null, 'best_reps': null, 'best_volume': null},
          where: 'id=?', whereArgs: [exerciseId]);
    });
  }

  Future clearAll() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('workout');
      await txn.delete('exercise');
      await txn.delete('workout_record');
      await txn.delete('exercise_record');
      await txn.delete('exercise_set');
      await txn.delete('best_weight_volume_reps');
    });
    await db.execute('vacuum');
  }

  Future close() async {
    final db = await instance.database;
    _database = null;
    db.close();
  }
}
