import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/workout.dart';

import '../ui/workoutlist/workoutlist.dart';

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

  void popPage() {
    state.removeLast();
    state = state;
  }
}

class WorkoutProvider extends StateNotifier<Future<List<Workout>>> {
  WorkoutProvider() : super(CustomDatabase.instance.readWorkouts());

  void refreshWorkouts() {
    state = CustomDatabase.instance.readWorkouts();
  }
}

class Helper {
  static final pageIndexProvider =
      StateNotifierProvider<IndexNotifier, int>(((ref) {
    return IndexNotifier();
  }));
  static final pagesProvider =
      StateNotifierProvider<PagesNotifier, List<Widget>>((ref) {
    return PagesNotifier();
  });
  static List<int> pageStack = [];
  static bool didUpdateHistory = false;
  static bool didSetWeightRecord = false;
  static bool didUpdateWorkout = false;
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
