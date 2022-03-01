import 'package:flutter/widgets.dart';

class Constants {
  static int pageIndex = 1;
  static List<int> pageStack = [];
  static bool didUpdateHistory = false;
  static bool didSetWeightRecord = false;
  static bool didUpdateWorkout = false;
  static bool firstAppRun = false;

  static void unfocusTextFields(BuildContext context){
    FocusScopeNode currentFocus = FocusScope.of(context);
    if(!currentFocus.hasPrimaryFocus){
      currentFocus.unfocus();
    }
  }

}
