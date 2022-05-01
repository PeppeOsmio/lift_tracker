import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/ui/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends ConsumerStatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  ConsumerState<Loading> createState() => _LoadingState();
}

class _LoadingState extends ConsumerState<Loading> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Helper.getExerciseData().then((value) async {
        Helper.exerciseDataGlobal = value;
        List<String> tempNames = [];
        for (var e in Helper.exerciseDataGlobal) {
          tempNames.add(Helper.loadTranslation(context, e.name));
        }
        tempNames.sort();
        List<ExerciseData> temp = [];
        for (var name in tempNames) {
          temp.add(Helper.exerciseDataGlobal.firstWhere((element) =>
              Helper.loadTranslation(context, element.name) == name));
        }
        Helper.exerciseDataGlobal.clear();
        Helper.exerciseDataGlobal.addAll(temp);
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        if (sharedPreferences.getBool('firstAppRun') == null) {
          await Helper.addDebugWorkouts();
          sharedPreferences.setBool('firstAppRun', true);
        }
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return App();
        }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
    );
  }
}
