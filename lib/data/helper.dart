import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/localizations.dart';

import '../ui/workoutlist/workoutlist.dart';

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

class PagesNotifier extends StateNotifier<List<Widget>> {
  PagesNotifier() : super([SizedBox(), WorkoutList(), SizedBox()]);

  void addPage(Widget page, int index) {
    var temp = <Widget>[];
    temp.addAll(state);
    temp[index] = page;
    state = temp;
  }
}

class WorkoutsNotifier extends StateNotifier<List<Workout>> {
  WorkoutsNotifier() : super([]);

  void addWorkouts(List<Workout> workouts) {
    state = [...state, ...workouts];
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

class WorkoutsOffsetNotifier extends StateNotifier<int> {
  WorkoutsOffsetNotifier() : super(0);

  void incrementOffset() {
    state = state + 1;
  }
}

class WorkoutRecordsOffsetNotifier extends StateNotifier<int> {
  WorkoutRecordsOffsetNotifier() : super(0);

  void incrementOffset() {
    state = state + 1;
  }
}

class Helper {
  static final instance = Helper._init();

  Helper._init();
  // Providers

  // Provides the index that indicates the current displayed page
  // among History, Workouts or Exercises
  static final pageIndexProvider =
      StateNotifierProvider<IndexNotifier, int>(((ref) {
    return IndexNotifier();
  }));

  // Provides the History, Workouts and Exercises pages
  // in order to keep their states
  static final pagesProvider =
      StateNotifierProvider<PagesNotifier, List<Widget>>((ref) {
    return PagesNotifier();
  });

  // Provides the future of the saved workouts. This future will be
  // resolved in the Workouts page's FutureBuilder
  static final workoutsProvider =
      StateNotifierProvider<WorkoutsNotifier, List<Workout>>(((ref) {
    return WorkoutsNotifier();
  }));

  // Provides the future of the saved workout records. this future will be
  // resolved in the History page's future builder
  static final workoutRecordsProvider =
      StateNotifierProvider<WorkoutRecordsNotifier, List<WorkoutRecord>>((ref) {
    return WorkoutRecordsNotifier();
  });

  static final workoutsOffsetProvider =
      StateNotifierProvider<WorkoutsOffsetNotifier, int>((ref) {
    return WorkoutsOffsetNotifier();
  });

  static final workoutRecordsOffsetProvider =
      StateNotifierProvider<WorkoutRecordsOffsetNotifier, int>((ref) {
    return WorkoutRecordsOffsetNotifier();
  });

  static final searchLimitProvider = Provider<int>((ref) {
    return 3;
  });

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
  static List<ExerciseData> exerciseDataGlobal = [];
  int workoutsOffset = 0;
  int workoutRecordsOffset = 0;
  final int searchLimit = 10;

  static void unfocusTextFields(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static String loadTranslation(BuildContext context, String key) {
    return Localization.of(context).getString(key);
  }

  static Future addDebugWorkouts() async {
    List<Exercise> pushExercises = [];
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData:
            ExerciseData(id: 4, name: 'chestPressIncline', type: 'machine')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData:
            ExerciseData(id: 38, name: 'cableCrossover', type: 'machine')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 3,
        reps: 10,
        exerciseData: ExerciseData(id: 40, name: 'legPress', type: 'machine')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 3,
        reps: 10,
        exerciseData:
            ExerciseData(id: 28, name: 'legExtensions', type: 'machine')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 3,
        reps: 10,
        exerciseData:
            ExerciseData(id: 39, name: 'shoulderPress', type: 'machine')));
    pushExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
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
    await CustomDatabase.instance.createWorkout('Push', pushExercises);
    List<Exercise> pullExercises = [];
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData:
            ExerciseData(id: 36, name: 'latPulldown', type: 'machine')));
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData:
            ExerciseData(id: 10, name: 'lowPulley', type: 'machine')));
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 4,
        reps: 10,
        exerciseData: ExerciseData(
            id: 27, name: 'stiffLegsDeadliftDumbbell', type: 'dumbbell')));
    pullExercises.add(Exercise(
        workoutId: 1,
        id: 1,
        sets: 5,
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
        sets: 4,
        reps: 10,
        exerciseData:
            ExerciseData(id: 17, name: 'hammerCurl', type: 'dumbbell')));
    await CustomDatabase.instance.createWorkout('Pull', pullExercises);
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
