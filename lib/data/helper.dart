import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/data/workoutrecord.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class WorkoutsNotifier extends StateNotifier<Future<List<Workout>>> {
  WorkoutsNotifier() : super(CustomDatabase.instance.readWorkouts());

  void refreshWorkouts() {
    state = CustomDatabase.instance.readWorkouts();
  }
}

class WorkoutRecordsNotifier
    extends StateNotifier<Future<List<WorkoutRecord>>> {
  WorkoutRecordsNotifier()
      : super(CustomDatabase.instance.readWorkoutRecords());

  void refreshWorkoutRecords() {
    state = CustomDatabase.instance.readWorkoutRecords();
  }
}

class Helper {
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
      StateNotifierProvider<WorkoutsNotifier, Future<List<Workout>>>(((ref) {
    return WorkoutsNotifier();
  }));

  // Provides the future of the saved workout records. this future will be
  // resolved in the History page's future builder
  static final workoutRecordsProvider = StateNotifierProvider<
      WorkoutRecordsNotifier, Future<List<WorkoutRecord>>>((ref) {
    return WorkoutRecordsNotifier();
  });

  static final blurProvider =
      StateNotifierProvider<BlurNotifier, double>(((ref) {
    return BlurNotifier();
  }));

  static final sharedPreferencesProvider = Provider(((ref) {
    return SharedPreferences.getInstance();
  }));

  static List<int> pageStack = [];
  static bool firstAppRun = false;

  static void unfocusTextFields(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static String dateToString(DateTime date) {
    String month;
    String year;
    String day;
    year = date.year.toString();
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    month = months[date.month - 1];
    day = date.day.toString();
    String output = "";
    output += month + " " + day + ", " + year;
    return output;
  }
}
