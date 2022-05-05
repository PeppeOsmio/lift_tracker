import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:path_provider/path_provider.dart';
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
        file = File('/storage/emulated/0/Documents/${date}.ltbackup');
      } catch (_) {
        log(_.toString());
        return false;
      }

      List<Workout> workouts = await CustomDatabase.instance.readWorkouts();
      List<WorkoutRecord> workoutRecords =
          await CustomDatabase.instance.readWorkoutRecords();
      Map<String, dynamic> map = {
        'workouts': workouts.map((e) => e.toMap()).toList(),
        'workoutRecords': workoutRecords.map((e) => e.toMap()).toList()
      };
      try {
        await file.writeAsString(jsonEncode(map), flush: true);
      } catch (_) {
        log(_.toString());
        return false;
      }
      return true;
    }
    return false;
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
        // User ca nceled the picker
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
        workouts.add(Workout(workout['id'], workout['n'], exercises));
      }
      await CustomDatabase.instance.clearAll();
      for (var workout in workouts) {
        await CustomDatabase.instance.createWorkout(
            workout.name, workout.exercises,
            backupMode: true, workoutId: workout.id);
      }

      for (var workoutRecord in decode['workoutRecords']) {
        List<ExerciseRecord> exerciseRecords = [];
        for (var exerciseRecord in workoutRecord['exRecs']) {
          List<ExerciseSet> sets = [];
          for (var set in exerciseRecord['sets']) {
            sets.add(ExerciseSet(
                weight: set['w'],
                reps: set['reps'],
                rpe: set['rpe'],
                hasRepsRecord: set['hasRR'],
                hasVolumeRecord: set['hasVR'],
                hasWeightRecord: set['hasWR']));
          }
          exerciseRecords.add(ExerciseRecord(exerciseRecord['n'], sets,
              exerciseId: exerciseRecord['exId'],
              type: exerciseRecord['type']));
        }

        workoutRecords.add(WorkoutRecord(
            0,
            DateTime.parse(workoutRecord['day']),
            workoutRecord['woN'],
            exerciseRecords,
            workoutId: workoutRecord['woId']));
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
