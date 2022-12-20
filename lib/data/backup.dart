import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/old_ui/app/app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'classes/workout.dart';

class Backup {
  static Future<String?> createBackup() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        throw Exception('permission_denied');
      }
      File file;
      String? path;
      try {
        String date = DateTime.now().toString().replaceAll(' ', '');
        date = date.replaceAll(':', '');
        path = await FilePicker.platform.getDirectoryPath();
        if (path == null) {
          return null;
        }
        file = File('$path/${date}.ltbackup');
      } catch (e) {
        Fluttertoast.showToast(msg: 'backup: ' + e.toString());
        log(e.toString());
        return null;
      }
      try {
        List<Workout> workouts =
            await CustomDatabase.instance.readWorkouts(readAll: true);
        List<WorkoutRecord> workoutRecords =
            await CustomDatabase.instance.readWorkoutRecords(readAll: true);
        var workoutsJson = workouts.map((workout) => workout.toMap()).toList();
        var workoutRecordsJson = workoutRecords
            .map((workoutRecord) => workoutRecord.toMap())
            .toList();
        Map backupJson = {
          'workouts': workoutsJson,
          'workoutRecords': workoutRecordsJson
        };
        await file.writeAsBytes(utf8.encode(jsonEncode(backupJson)));
      } catch (e) {
        Fluttertoast.showToast(msg: 'backup: ' + e.toString());
        log(e.toString());
        return null;
      }
      return path;
    }
    return null;
  }

  static bool validateBackup(
      List<Workout> workouts, List<WorkoutRecord> workoutRecords) {
    for (Workout workout in workouts) {
      if (workout.hasCache == 1) {
        bool found = false;
        for (var workoutRecord in workoutRecords) {
          if (workoutRecord.workoutId == workout.id &&
              workoutRecord.isCache == 1) {
            found = true;
            break;
          }
        }
        if (!found) {
          return false;
        }
      }
    }
    return true;
  }

  static Future<void> readBackup() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        throw Exception('permission_denied');
      }
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      File file;
      if (result != null) {
        file = File(result.files.single.path!);
      } else {
        // User canceled the picker
        throw Exception('backup_canceled');
      }
      String backupContent = utf8.decode(await file.readAsBytes());
      List<Workout> workouts = [];
      List<WorkoutRecord> workoutRecords = [];
      var decode = json.decode(backupContent);
      for (var workoutJson in decode['workouts']) {
        List<Exercise> exercises = [];
        // parse exercises
        for (var exerciseJson in workoutJson['exercises']) {
          var execiseDataJson = exerciseJson['exerciseData'];
          ExerciseData exerciseData = ExerciseData(
              id: execiseDataJson['id'],
              name: execiseDataJson['name'],
              type: execiseDataJson['type']);
          exercises.add(Exercise(
              id: exerciseJson['id'],
              exerciseData: exerciseData,
              workoutId: 0,
              sets: exerciseJson['sets'],
              reps: exerciseJson['reps'],
              bestWeight: exerciseJson['bestWeight'],
              bestReps: exerciseJson['bestReps'],
              best1RM: exerciseJson['best1RM'],
              notes: exerciseJson['notes']));
        }

        workouts.add(Workout(workoutJson['id'], workoutJson['name'], exercises,
            hasCache: workoutJson['hasCache']));
      }

      for (var workoutRecordJson in decode['workoutRecords']) {
        List<ExerciseRecord> exerciseRecords = [];
        for (var exerciseRecordJson in workoutRecordJson['exerciseRecords']) {
          List<ExerciseSet> sets = [];
          for (var setJson in exerciseRecordJson['sets']) {
            sets.add(ExerciseSet(
                weight: double.parse(setJson['weight']),
                reps: int.parse(setJson['reps']),
                rpe: int.tryParse(setJson['rpe']),
                hasRepsRecord: setJson['hasRepsRecord'],
                has1RMRecord: setJson['has1RMRecord'],
                hasWeightRecord: setJson['hasWeightRecord']));
          }
          log(exerciseRecordJson.toString());
          exerciseRecords.add(ExerciseRecord(
              exerciseData: Helper.instance.exerciseDataGlobal.firstWhere(
                  (element) => element.id == exerciseRecordJson['jsonId']),
              sets: sets,
              exerciseId: exerciseRecordJson['exerciseId'],
              type: exerciseRecordJson['type']));
          log('aa');
        }
        workoutRecords.add(WorkoutRecord(
            0,
            DateTime.parse(workoutRecordJson['day']),
            workoutRecordJson['workoutName'],
            exerciseRecords,
            workoutId: workoutRecordJson['workoutId'],
            isCache: workoutRecordJson['isCache']));
      }

      bool isValid = validateBackup(workouts, workoutRecords);
      if (!isValid) {
        throw Exception('Invalid backup');
      }
      await CustomDatabase.instance.clearAll();
      for (var workout in workouts) {
        await CustomDatabase.instance.saveWorkout(workout,
            backupMode: true,
            workoutId: workout.id,
            hasCache: workout.hasCache);
      }
      for (var workoutRecord in workoutRecords) {
        await CustomDatabase.instance
            .addWorkoutRecord(workoutRecord, backupMode: true);
      }
      //  var decode = jsonDecode(await file.readAsString());
      //  List<Workout> workouts = [];
      //  List<WorkoutRecord> workoutRecords = [];

      //  for (var workout in decode['workouts']) {
      //    List<Exercise> exercises = [];
      //    for (var exercise in workout['ex']) {
      //      var exerciseData = exercise['exD'];
      //      ExerciseData exData = ExerciseData(
      //          id: exerciseData['id'],
      //          name: exerciseData['n'],
      //          type: exerciseData['type']);
      //      exercises.add(Exercise(
      //          id: exercise['id'],
      //          exerciseData: exData,
      //          workoutId: 0,
      //          sets: exercise['sets'],
      //          reps: exercise['reps'],
      //          bestWeight: exercise['bestW'],
      //          bestReps: exercise['bestR'],
      //          bestVolume: exercise['bestV'],
      //          notes: exercise['notes']));
      //    }
      //    workouts.add(Workout(workout['id'], workout['n'], exercises,
      //        hasCache: workout['has_cache']));
      //  }

      //  for (var workoutRecord in decode['workoutRecords']) {
      //    List<ExerciseRecord> exerciseRecords = [];
      //    for (var exerciseRecord in workoutRecord['exRecs']) {
      //      List<ExerciseSet> sets = [];
      //      for (var set in exerciseRecord['sets']) {
      //        sets.add(ExerciseSet(
      //            weight: double.parse(set['w']),
      //            reps: int.parse(set['reps']),
      //            rpe: int.tryParse(set['rpe']),
      //            hasRepsRecord: set['hasRR'],
      //            hasVolumeRecord: set['hasVR'],
      //            hasWeightRecord: set['hasWR']));
      //      }
      //      exerciseRecords.add(ExerciseRecord(
      //          exerciseData: Helper.instance.exerciseDataGlobal.firstWhere(
      //              (element) => element.id == exerciseRecord['jsonId']),
      //          sets: sets,
      //          exerciseId: exerciseRecord['exId'],
      //          type: exerciseRecord['type']));
      //    }

      //    workoutRecords.add(WorkoutRecord(
      //        0,
      //        DateTime.parse(workoutRecord['day']),
      //        workoutRecord['woN'],
      //        exerciseRecords,
      //        workoutId: workoutRecord['woId'],
      //        isCache: workoutRecord['is_cache']));
      //  }

      //  bool isValid = validateBackup(workouts, workoutRecords);
      //  if (!isValid) {
      //    throw Exception('Invalid backup');
      //  }
      //  await CustomDatabase.instance.clearAll();

      //  for (var workout in workouts) {
      //    await CustomDatabase.instance.saveWorkout(workout,
      //        backupMode: true,
      //        workoutId: workout.id,
      //        hasCache: workout.hasCache);
      //  }

      //  for (var workoutRecord in workoutRecords) {
      //    await CustomDatabase.instance
      //        .addWorkoutRecord(workoutRecord, backupMode: true);
      //  }
      //  return decode;
      //}
      //return {};
    }
  }
}
