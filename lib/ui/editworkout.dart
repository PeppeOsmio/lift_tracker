import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/exerciselistitem.dart';
import 'package:lift_tracker/ui/widgets.dart';

class EditWorkout extends ConsumerStatefulWidget {
  const EditWorkout(this.workout, {Key? key}) : super(key: key);
  final Workout workout;

  @override
  _EditWorkoutState createState() => _EditWorkoutState();
}

class _EditWorkoutState extends ConsumerState<EditWorkout> {
  List<ExerciseListItem> exerciseWidgets = [];
  List<Exercise> data = [];
  TextEditingController workoutName = TextEditingController();
  List<Exercise> initialExercises = [];

  @override
  void initState() {
    super.initState();
    initialExercises.addAll(widget.workout.exercises);
    workoutName.text = widget.workout.name;
    for (int i = 0; i < widget.workout.exercises.length; i++) {
      exerciseWidgets.add(ExerciseListItem(
        i + 1,
        onDelete: (index) => onDelete(index),
        initialExercise: initialExercises[i],
        onMoveDown: onMoveDown,
        onMoveUp: onMoveUp,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> temp = [];
    for (int i = 0; i < exerciseWidgets.length; i++) {
      temp.add(Padding(
        padding:
            EdgeInsets.only(bottom: i == exerciseWidgets.length - 1 ? 0 : 24),
        child: exerciseWidgets[i],
      ));
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: SafeArea(
          child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Palette.backgroundDark,
              body: Column(
                children: [
                  CustomAppBar(
                      middleText:
                          Helper.loadTranslation(context, 'editWorkout'),
                      onBack: () {
                        Navigator.pop(context);
                      },
                      onSubmit: () => editWorkout(),
                      backButton: true,
                      submitButton: true),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 40, left: 24, bottom: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Helper.loadTranslation(context, 'workoutName'),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 24, bottom: 24, right: 48),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 31, 31, 31),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: TextField(
                                    controller: workoutName,
                                    decoration: const InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        hintText: 'Chest, Legs...',
                                        border: InputBorder.none),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                Helper.loadTranslation(context, 'exercises'),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              const SizedBox(height: 24),
                              Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: temp),
                              addExerciseButton()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }

  void editWorkout() async {
    if (workoutName.text.isEmpty) {
      return;
    }

    List<Exercise> exercises = [];
    for (int i = 0; i < exerciseWidgets.length; i++) {
      var exerciseWidget = exerciseWidgets[i];
      String name = exerciseWidget.name;
      String sets = exerciseWidget.sets;
      String reps = exerciseWidget.reps;
      String type = exerciseWidget.type;
      String jsonId = exerciseWidget.jsonId;

      log('name: ' + name);
      log('sets: ' + sets);
      log('reps: ' + reps);
      log('type: ' + type);
      log('jsonId: ' + jsonId);

      if (name.isEmpty ||
          sets.isEmpty ||
          reps.isEmpty ||
          type.isEmpty ||
          jsonId.isEmpty) {
        return;
      }

      exercises.add(Exercise(
          id: i,
          jsonId: int.parse(jsonId),
          name: name,
          type: type,
          sets: int.parse(sets),
          reps: int.parse(reps),
          workoutId: widget.workout.id));
    }
    await CustomDatabase.instance
        .editWorkout(Workout(widget.workout.id, workoutName.text, exercises));
    Navigator.pop(context);
    ref.read(Helper.workoutsProvider.notifier).refreshWorkouts();
  }

  void onDelete(index) {
    if (exerciseWidgets.length > 1) {
      setState(() {
        exerciseWidgets.removeAt(index);
        for (int i = 0; i < exerciseWidgets.length; i++) {
          exerciseWidgets[i].exNumber = i + 1;
        }
      });
    }
  }

  void onMoveDown(index) {
    if (index == exerciseWidgets.length - 1) {
      return;
    }
    var temp = exerciseWidgets[index + 1];
    temp.exNumber = temp.exerciseNumber - 1;
    exerciseWidgets[index].exNumber = exerciseWidgets[index].exerciseNumber + 1;
    exerciseWidgets[index + 1] = exerciseWidgets[index];
    exerciseWidgets[index] = temp;
    setState(() {});
  }

  void onMoveUp(index) {
    if (index == 0) {
      return;
    }
    var temp = exerciseWidgets[index - 1];
    temp.exNumber = temp.exerciseNumber + 1;
    exerciseWidgets[index].exNumber = exerciseWidgets[index].exerciseNumber - 1;
    exerciseWidgets[index - 1] = exerciseWidgets[index];
    exerciseWidgets[index] = temp;
    setState(() {});
  }

  Widget addExerciseButton() {
    return Center(
        child: SizedBox(
            height: 65,
            width: 65,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                var exerciseElement =
                    exerciseWidgets[exerciseWidgets.length - 1];
                if (exerciseElement.name != '' &&
                    exerciseElement.sets != '' &&
                    exerciseElement.reps != '') {
                  exerciseWidgets.add(ExerciseListItem(
                    exerciseWidgets.length + 1,
                    onDelete: (index) => onDelete(index),
                    onMoveDown: onMoveDown,
                    onMoveUp: onMoveUp,
                  ));
                  setState(() {});
                }
              },
              backgroundColor: const Color.fromARGB(255, 31, 31, 31),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: const FittedBox(
                child: Icon(Icons.add_outlined),
              ),
            )));
  }
}
