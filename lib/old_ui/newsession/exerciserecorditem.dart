import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/old_ui/newsession/setrow.dart';
import 'package:lift_tracker/old_ui/styles.dart';

class ExerciseRecordItem extends StatefulWidget {
  const ExerciseRecordItem(this.exercise,
      {required this.repsControllers,
      required this.weightControllers,
      required this.rpeControllers,
      required this.exerciseData,
      required this.onExerciseChange,
      required this.onAddSet,
      this.temp = false,
      Key? key})
      : super(key: key);
  final Exercise exercise;
  final Function onExerciseChange;
  final ExerciseData exerciseData;
  final List<TextEditingController> repsControllers;
  final List<TextEditingController> weightControllers;
  final List<TextEditingController> rpeControllers;
  final Function() onAddSet;
  final bool temp;
  ExerciseRecord? get exerciseRecord {
    List<ExerciseSet> setList = [];
    for (int i = 0; i < repsControllers.length; i++) {
      String reps = repsControllers[i].text;
      String weight = weightControllers[i].text;
      String rpe = rpeControllers[i].text;
      String name = exerciseData.name;
      if (name.isEmpty) {
        throw Exception('missing_name');
      }
      if (exerciseData.type == 'free') {
        weight = '0';
      }
      if (reps.isEmpty) {
        return null;
      } else if (reps != '0' && weight.isEmpty) {
        return null;
      }
      if (reps != '0') {
        double numWeight = double.parse(weight);
        int numReps = int.parse(reps);
        int? numRpe = rpe.isNotEmpty ? int.parse(rpe) : null;
        setList.add(ExerciseSet(weight: numWeight, reps: numReps, rpe: numRpe));
      }
    }
    return ExerciseRecord(exerciseData.id, setList,
        exerciseId: exercise.id, type: exerciseData.type);
  }

  ExerciseRecord get cacheExerciseRecord {
    List<ExerciseSet> setList = [];
    String name = exerciseData.name;
    for (int i = 0; i < repsControllers.length; i++) {
      String reps = repsControllers[i].text;
      String weight = weightControllers[i].text;
      String rpe = rpeControllers[i].text;
      if (reps.isEmpty) {
        reps = '-1';
      }
      if (weight.isEmpty) {
        weight = '-1';
      }
      if (rpe.isEmpty) {
        rpe = '-1';
      } else if (int.parse(rpe) > 10) {
        rpe = '10';
      }
      setList.add(ExerciseSet(
          weight: double.parse(weight),
          reps: int.parse(reps),
          rpe: int.parse(rpe)));
    }
    if (name.isEmpty) {
      name = exercise.exerciseData.name;
    }
    return ExerciseRecord(exerciseData.id, setList,
        exerciseId: exercise.id, type: exerciseData.type);
  }

  @override
  _ExerciseRecordItemState createState() => _ExerciseRecordItemState();
}

class _ExerciseRecordItemState extends State<ExerciseRecordItem> {
  ExerciseRecord? startingRecord;
  late bool tempBool;

  Widget buildAddSetButton() {
    return IntrinsicWidth(
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.resolveWith(
              (states) => EdgeInsets.only(left: 8, right: 14)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
          elevation: MaterialStateProperty.resolveWith<double>((states) => 0),
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return Palette.elementsDark;
            },
          ),
        ),
        onPressed: () {
          widget.onAddSet();
          setState(() {});
        },
        child: Row(
          children: const [
            Icon(
              Icons.add_outlined,
              color: Colors.white,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              'Add set',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExercise() {
    List<Widget> temp = [];
    for (int i = 0; i < widget.repsControllers.length; i++) {
      temp.add(SetRow(
        i + 1,
        repsController: widget.repsControllers[i],
        weightController: widget.weightControllers[i],
        rpeController: widget.rpeControllers[i],
        exerciseType: widget.exerciseData.type,
      ));
    }
    temp.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildAddSetButton(),
      ],
    ));
    Column tempColumn = Column(children: temp);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                widget.onExerciseChange();
              },
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                UIUtilities.loadTranslation(context, widget.exerciseData.name),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            GestureDetector(
              onTap: () {
                for (var e in widget.repsControllers) {
                  e.text = '0';
                }
                for (var e in widget.weightControllers) {
                  e.text = '0';
                }
              },
              child: SizedBox(
                width: 32,
                child: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 24),
                  child: Text(
                    UIUtilities.loadTranslation(context, 'set'),
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  child: Text(
                    '${UIUtilities.loadTranslation(context, 'repsGoal')}: ${widget.exercise.reps}',
                    style: const TextStyle(color: Colors.white),
                  )),
            ),
            Expanded(
              flex: 10,
              child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24, left: 8),
                  child: tempBool
                      ? SizedBox()
                      : Text(
                          widget.exerciseData.type != 'free'
                              ? widget.exercise.bestWeight != null
                                  ? '${UIUtilities.loadTranslation(context, 'bestWeight')}: ${widget.exercise.bestWeight} kg'
                                  : ''
                              : widget.exercise.bestReps != null
                                  ? '${UIUtilities.loadTranslation(context, 'bestReps')}: ${widget.exercise.bestReps}'
                                  : '',
                          style: const TextStyle(color: Colors.white))),
            ),
          ],
        ),
        tempColumn
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tempBool = widget.temp;
  }

  @override
  Widget build(BuildContext context) {
    return buildExercise();
  }

  @override
  void didUpdateWidget(covariant ExerciseRecordItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    tempBool = widget.temp;
  }
}
