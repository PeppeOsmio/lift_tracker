import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'classes/workout.dart';

class Backup {
  static Future<bool> createBackup() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      File file;
      try {
        String date = DateTime.now().toString().replaceAll(' ', '');
        date = date.replaceAll(':', '');
        String? path = await FilePicker.platform.getDirectoryPath();
        if (path == null) {
          return false;
        }
        file = File('$path/${date}.ltbackup');
      } catch (e) {
        Fluttertoast.showToast(msg: 'backup: ' + e.toString());
        log(e.toString());
        return false;
      }

      List<Workout> workouts =
          await CustomDatabase.instance.readWorkouts(readAll: true);
      List<WorkoutRecord> workoutRecords =
          await CustomDatabase.instance.readWorkoutRecords(readAll: true);
      Map<String, dynamic> map = {
        'workouts': workouts.map((e) => e.toMap()).toList(),
        'workoutRecords': workoutRecords.map((e) => e.toMap()).toList()
      };
      try {
        await file.writeAsString(jsonEncode(map), flush: true);
      } catch (e) {
        Fluttertoast.showToast(msg: 'backup: ' + e.toString());
        log(e.toString());
        return false;
      }
      return true;
    }
    return false;
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

  static Future<Map<String, dynamic>> readBackup() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      File file;
      if (result != null) {
        file = File(result.files.single.path!);
      } else {
        // User canceled the picker
        return {};
      }
      var decode = jsonDecode(await file.readAsString());
      List<Workout> workouts = [];
      List<WorkoutRecord> workoutRecords = [];

      for (var workout in decode['workouts']) {
        List<Exercise> exercises = [];
        for (var exercise in workout['ex']) {
          var exerciseData = exercise['exD'];
          ExerciseData exData = ExerciseData(
              id: exerciseData['id'],
              name: exerciseData['n'],
              type: exerciseData['type']);
          exercises.add(Exercise(
              id: exercise['id'],
              exerciseData: exData,
              workoutId: 0,
              sets: exercise['sets'],
              reps: exercise['reps'],
              bestWeight: exercise['bestW'],
              bestReps: exercise['bestR'],
              bestVolume: exercise['bestV'],
              notes: exercise['notes']));
        }
        workouts.add(Workout(workout['id'], workout['n'], exercises,
            hasCache: workout['has_cache']));
      }

      for (var workoutRecord in decode['workoutRecords']) {
        List<ExerciseRecord> exerciseRecords = [];
        for (var exerciseRecord in workoutRecord['exRecs']) {
          List<ExerciseSet> sets = [];
          for (var set in exerciseRecord['sets']) {
            sets.add(ExerciseSet(
                weight: double.parse(set['w']),
                reps: int.parse(set['reps']),
                rpe: int.tryParse(set['rpe']),
                hasRepsRecord: set['hasRR'],
                hasVolumeRecord: set['hasVR'],
                hasWeightRecord: set['hasWR']));
          }
          exerciseRecords.add(ExerciseRecord(
              exerciseData: Helper.instance.exerciseDataGlobal.firstWhere(
                  (element) => element.id == exerciseRecord['jsonId']),
              sets: sets,
              exerciseId: exerciseRecord['exId'],
              type: exerciseRecord['type']));
        }

        workoutRecords.add(WorkoutRecord(
            0,
            DateTime.parse(workoutRecord['day']),
            workoutRecord['woN'],
            exerciseRecords,
            workoutId: workoutRecord['woId'],
            isCache: workoutRecord['is_cache']));
      }

      bool isValid = validateBackup(workouts, workoutRecords);
      if (!isValid) {
        return Future.error('Invalid backup.');
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
      return decode;
    }
    return {};
  }
}
