import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/localizations.dart';

import '../old_ui/workoutlist/workoutlist.dart';

class BlurNotifier extends StateNotifier<double> {
  BlurNotifier() : super(0);

  void setBlur(double sigma) {
    state = 3 * sigma;
  }
}

class IndexNotifier extends StateNotifier<int> {
  IndexNotifier() : super(1);
  void setIndex(int index) {
    state = index;
  }
}

class WorkoutsNotifier extends StateNotifier<List<Workout>> {
  WorkoutsNotifier() : super([]);

  void addWorkouts(List<Workout> workouts) {
    state = [...state, ...workouts];
  }

  Workout? getWorkoutdById(int workoutId) {
    try {
      return state.firstWhere((workout) => workout.id == workoutId);
    } catch (e) {
      return null;
    }
  }

  void addWorkout(Workout workout) {
    state = [workout, ...state];
  }

  void removeWorkout(int workoutId) {
    List<Workout> newState = [...state];
    newState.removeWhere((workout) => workout.id == workoutId);
    state = newState;
  }

  void replaceWorkout(Workout newWorkout) {
    var newState = [...state];
    int index = newState.indexWhere((workout) {
      return newWorkout.id == workout.id;
    });
    log(index.toString());
    newState[index] = newWorkout;
    state = newState;
  }
}

class WorkoutRecordsNotifier extends StateNotifier<List<WorkoutRecord>> {
  WorkoutRecordsNotifier() : super([]);

  void addWorkoutRecords(List<WorkoutRecord> workoutRecords) {
    state = [...state, ...workoutRecords];
  }

  void addWorkoutRecord(WorkoutRecord workoutRecord) {
    state = [workoutRecord, ...state];
  }

  void removeWorkoutRecord(int workoutRecordId) {
    List<WorkoutRecord> newState = [...state];
    newState
        .removeWhere((workoutRecord) => workoutRecord.id == workoutRecordId);
    state = newState;
  }

  void replaceWorkoutRecord(WorkoutRecord newWorkoutRecord) {
    var newState = [...state];
    int index = newState.indexWhere((workoutRecord) {
      return newWorkoutRecord.id == workoutRecord.id;
    });
    newState[index] = newWorkoutRecord;
    state = newState;
  }
}

class Helper {
  static final instance = Helper._init();

  Helper._init();
  // Providers

  // Provides the index that indicates the current displayed page
  // among History, Workouts or Exercises
  final pageIndexProvider = StateNotifierProvider<IndexNotifier, int>(((ref) {
    return IndexNotifier();
  }));

  // Provides the future of the saved workouts. This future will be
  // resolved in the Workouts page's FutureBuilder
  final workoutsProvider =
      StateNotifierProvider<WorkoutsNotifier, List<Workout>>(((ref) {
    return WorkoutsNotifier();
  }));

  // Provides the future of the saved workout records. this future will be
  // resolved in the History page's future builder
  final workoutRecordsProvider =
      StateNotifierProvider<WorkoutRecordsNotifier, List<WorkoutRecord>>((ref) {
    return WorkoutRecordsNotifier();
  });

  static bool isAppLoaded = false;
  ColorScheme colorSchemeLight = ColorScheme.fromSeed(
      seedColor: Colors.orange, brightness: Brightness.light);
  ColorScheme colorSchemeDark = ColorScheme.fromSeed(
      seedColor: Colors.orange, brightness: Brightness.dark);

  static Future<List<ExerciseData>> getExerciseData() async {
    String exerciseDataJson =
        await rootBundle.loadString('assets/exercise_data.json');
    var mapData = jsonDecode(exerciseDataJson);
    List<ExerciseData> exerciseDataList = [];
    for (var item in mapData) {
      int id = item['id'] as int;
      String name = item['name'] as String;
      String type = item['type'] as String;
      String firstMuscle = item['firstMuscle'] as String;
      String secondMuscle = item['secondMuscle'] as String;
      String thirdMuscle = item['thirdMuscle'] as String;
      exerciseDataList.add(ExerciseData(
          id: id,
          name: name,
          firstMuscle: firstMuscle,
          secondMuscle: secondMuscle,
          thirdMuscle: thirdMuscle,
          type: type));
    }
    return exerciseDataList;
  }

  static List<int> pageStack = [];
  List<ExerciseData> exerciseDataGlobal = [];

  static Future<List<int>> addDebugWorkouts() async {
    List<int> returns = [];
    List<Exercise> pushExercises = [];
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 8,
        exerciseData:
            ExerciseData(id: 1, name: 'benchPressBarebell', type: 'barebell')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 3,
        reps: 10,
        exerciseData:
            ExerciseData(id: 4, name: 'chestPressIncline', type: 'machine')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 3,
        reps: 10,
        exerciseData:
            ExerciseData(id: 38, name: 'cableCrossover', type: 'machine')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 8,
        exerciseData:
            ExerciseData(id: 39, name: 'shoulderPress', type: 'machine')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 5,
        reps: 10,
        exerciseData: ExerciseData(
            id: 30, name: 'lateralRaisesDumbbell', type: 'dumbbell')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData:
            ExerciseData(id: 18, name: 'pushdownRope', type: 'machine')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData:
            ExerciseData(id: 19, name: 'pushdownBar', type: 'machine')));
    returns.add(await CustomDatabase.instance
        .saveWorkout(Workout(0, 'Push', pushExercises)));
    List<Exercise> pullExercises = [];
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData: ExerciseData(id: 9, name: 'chinUps', type: 'free')));
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData: ExerciseData(
            id: 7, name: 'bentOverRowDumbbell', type: 'dumbbell')));
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData:
            ExerciseData(id: 43, name: 'ropePulldown', type: 'machine')));
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 6,
        reps: 10,
        exerciseData:
            ExerciseData(id: 32, name: 'rearRaises', type: 'dumbbell')));
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData:
            ExerciseData(id: 15, name: 'dumbbellCurl', type: 'dumbbell')));
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 3,
        reps: 10,
        exerciseData:
            ExerciseData(id: 17, name: 'hammerCurl', type: 'dumbbell')));
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 3,
        reps: 10,
        exerciseData:
            ExerciseData(id: 37, name: 'inclineBenchCurl', type: 'dumbbell')));
    returns.add(await CustomDatabase.instance
        .saveWorkout(Workout(0, 'Pull', pullExercises)));
    return returns;
  }

  static Map<String, String> dateToString(DateTime date) {
    String month;
    String year;
    String day;
    year = date.year.toString();
    List<String> months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december'
    ];
    List<String> days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    month = months[date.month - 1];
    day = date.day.toString();
    return {'month': month, 'day': day, 'year': year};
  }
}
