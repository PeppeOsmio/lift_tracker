import 'package:flutter/widgets.dart';

class Helper {
  static int pageIndex = 1;
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
