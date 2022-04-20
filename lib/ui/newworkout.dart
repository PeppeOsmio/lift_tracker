import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/exerciselistitem.dart';
import 'package:lift_tracker/ui/widgets.dart';

import '../data/helper.dart';

class NewWorkout extends ConsumerStatefulWidget {
  const NewWorkout({Key? key}) : super(key: key);

  @override
  _NewWorkoutState createState() => _NewWorkoutState();
}

class _NewWorkoutState extends ConsumerState<NewWorkout> {
  List<ExerciseListItem> exerciseWidgets = [];
  List<Exercise> data = [];
  TextEditingController workoutName = TextEditingController();

  @override
  void initState() {
    super.initState();
    exerciseWidgets.add(ExerciseListItem(
      1,
      onDelete: (index) => onDelete(index),
      onMoveDown: (index) => onMoveDown(index),
      onMoveUp: (index) => onMoveUp(index),
    ));
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
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          Helper.unfocusTextFields(context);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Palette.backgroundDark,
            body: Column(
              children: [
                CustomAppBar(
                    middleText: 'New workout',
                    onBack: () => Navigator.pop(context),
                    onSubmit: () => createWorkout(),
                    backButton: true,
                    submitButton: true),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 48, left: 24, bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Workout name',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 24, bottom: 24, right: 48),
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 31, 31, 31),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                controller: workoutName,
                                decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: 'Chest, Legs...',
                                    border: InputBorder.none),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Exercises',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          Column(
                              mainAxisSize: MainAxisSize.min, children: temp),
                          addExerciseButton()
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void createWorkout() async {
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

      if (name.isEmpty ||
          sets.isEmpty ||
          reps.isEmpty ||
          type.isEmpty ||
          jsonId.isEmpty) {
        log('A');
        log('name' + name);
        log('sets' + sets);
        log('reps' + reps);
        log('jsonId' + jsonId);
        log('type' + type);
        return;
      }
      exercises.add(Exercise(
          id: i,
          jsonId: int.parse(jsonId),
          name: name,
          type: type,
          sets: int.parse(sets),
          reps: int.parse(reps),
          workoutId: 0));
    }
    await CustomDatabase.instance.createWorkout(workoutName.text, exercises);
    ref.read(Helper.workoutsProvider.notifier).refreshWorkouts();
    Navigator.pop(context);
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
                    onMoveDown: (index) => onMoveDown(index),
                    onMoveUp: (index) => onMoveUp(index),
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
