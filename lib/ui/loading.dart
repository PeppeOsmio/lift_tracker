import 'package:flutter/material.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/ui/app/app.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
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
