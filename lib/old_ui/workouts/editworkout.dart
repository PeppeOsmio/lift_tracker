import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/old_ui/styles.dart';
import 'package:lift_tracker/old_ui/workouts/exerciselistitem.dart';
import 'package:lift_tracker/old_ui/selectexercise.dart';
import 'package:lift_tracker/old_ui/widgets.dart';

import '../../data/classes/exercisedata.dart';

class EditWorkout extends ConsumerStatefulWidget {
  const EditWorkout(this.workout, {Key? key}) : super(key: key);
  final Workout workout;

  @override
  _EditWorkoutState createState() => _EditWorkoutState();
}

class _EditWorkoutState extends ConsumerState<EditWorkout> {
  List<Exercise?> exerciseList = [];
  TextEditingController workoutNameController = TextEditingController();
  List<Exercise?> initialExercises = [];
  List<TextEditingController> repsControllers = [];
  List<TextEditingController> setsControllers = [];
  List<TextEditingController> nameControllers = [];

  @override
  void initState() {
    super.initState();
    workoutNameController.text = widget.workout.name;
    initialExercises.addAll(widget.workout.exercises);
    for (int i = 0; i < initialExercises.length; i++) {
      var exercise = initialExercises[i];
      exerciseList.add(exercise);
      repsControllers.add(TextEditingController());
      setsControllers.add(TextEditingController());
      nameControllers.add(TextEditingController());
      repsControllers[i].text = exercise!.reps.toString();
      setsControllers[i].text = exercise.sets.toString();
      Future.delayed(Duration.zero, () {
        nameControllers[i].text =
            UIUtilities.loadTranslation(context, exercise.exerciseData.name);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ExerciseListItem> exerciseWidgets = [];
    for (int i = 0; i < exerciseList.length; i++) {
      bool resetIcon = true;
      if (exerciseList[i] == null) {
        resetIcon = false;
      } else if (exerciseList[i]!.bestReps == null &&
          exerciseList[i]!.bestWeight == null &&
          exerciseList[i]!.best1RM == null) {
        resetIcon = false;
      }
      exerciseWidgets.add(ExerciseListItem(
        resetIcon: resetIcon,
        onDelete: () => onDelete(i),
        onNameFieldPress: () async {
          var result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return SelectExercise();
          }));
          if (result != null) {
            if (exerciseList[i] != null &&
                result == initialExercises[i]!.exerciseData) {
              exerciseList[i] = initialExercises[i]!;
              nameControllers[i].text =
                  UIUtilities.loadTranslation(context, result.name);
              setState(() {});
              return;
            }
            exerciseList[i] = Exercise(
                exerciseData: result,
                id: 0,
                workoutId: widget.workout.id,
                sets: -1,
                reps: -1);
            nameControllers[i].text =
                UIUtilities.loadTranslation(context, result.name);
            setState(() {});
          }
        },
        onReset: resetIcon
            ? () async {
                Exercise exercise = exerciseList[i]!;
                String best1RM;
                String bestReps;
                String bestWeight;
                String content;
                if (exercise.bestReps == null) {
                  bestReps = 'no record';
                } else {
                  bestReps = exercise.bestReps.toString();
                }
                if (exercise.bestWeight == null) {
                  bestWeight = 'no record';
                } else {
                  bestWeight = exercise.bestWeight.toString();
                }
                if (exercise.best1RM == null) {
                  best1RM = 'no record';
                } else {
                  best1RM = exercise.best1RM.toString();
                }

                if (exercise.exerciseData.type == 'free') {
                  content =
                      '${UIUtilities.loadTranslation(context, 'bestReps')}: $bestReps';
                } else {
                  content =
                      '${UIUtilities.loadTranslation(context, 'bestWeight')}: $bestWeight kg\n${UIUtilities.loadTranslation(context, 'best1RM')}: $best1RM kg';
                }

                await showDimmedBackgroundDialog(context,
                    title: UIUtilities.loadTranslation(context, 'resetStats'),
                    content: content,
                    rightText: UIUtilities.loadTranslation(context, 'cancel'),
                    leftText: UIUtilities.loadTranslation(context, 'yes'),
                    rightOnPressed: () => Navigator.pop(context),
                    leftOnPressed: () async {
                      await CustomDatabase.instance
                          .resetStats(exerciseList[i]!.id);
                      Fluttertoast.showToast(
                          msg: UIUtilities.loadTranslation(
                              context, 'resetSuccessful'));
                      ref.refresh(Helper.instance.workoutsProvider);
                      exerciseList[i]!.bestReps = null;
                      exerciseList[i]!.bestWeight = null;
                      exerciseList[i]!.best1RM = null;
                      Navigator.pop(context);
                    });
              }
            : () {},
        repsController: repsControllers[i],
        nameController: nameControllers[i],
        setsController: setsControllers[i],
        onMoveDown: () => onMoveDown(i),
        onMoveUp: () => onMoveUp(i),
      ));
    }
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
        await showDimmedBackgroundDialog(context,
            title: UIUtilities.loadTranslation(context, 'loseChanges'),
            rightText: UIUtilities.loadTranslation(context, 'cancel'),
            leftText: UIUtilities.loadTranslation(context, 'yes'),
            rightOnPressed: () => Navigator.pop(context),
            leftOnPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            });
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
                          UIUtilities.loadTranslation(context, 'editWorkout'),
                      onBack: () {
                        Navigator.maybePop(context);
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
                                UIUtilities.loadTranslation(
                                    context, 'workoutName'),
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
                                    controller: workoutNameController,
                                    decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        hintText: UIUtilities.loadTranslation(
                                            context,
                                            'workoutNameControllerControllerExample'),
                                        border: InputBorder.none),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                UIUtilities.loadTranslation(
                                    context, 'exercises'),
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
    if (workoutNameController.text.isEmpty) {
      return;
    }

    List<Exercise> exercises = [];
    for (int i = 0; i < exerciseList.length; i++) {
      String sets = setsControllers[i].text;
      String reps = repsControllers[i].text;
      String name = '';
      String type = '';
      String jsonId = '';
      if (exerciseList[i] != null) {
        name = exerciseList[i]!.exerciseData.name;
        type = exerciseList[i]!.exerciseData.type;
        jsonId = exerciseList[i]!.exerciseData.id.toString();
      }
      if (name.isEmpty ||
          sets.isEmpty ||
          reps.isEmpty ||
          type.isEmpty ||
          jsonId.isEmpty) {
        return;
      }

      exerciseList[i]!.reps = int.parse(reps);
      exerciseList[i]!.sets = int.parse(sets);

      exercises.add(exerciseList[i]!);
    }
    bool didEdit = false;
    Workout workout =
        Workout(widget.workout.id, workoutNameController.text, exercises);
    await CustomDatabase.instance.editWorkout(workout).then((response) {
      didEdit = response;
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'ediworkout: ' + error.toString());
    });
    if (didEdit) {
      ref
          .read(Helper.instance.workoutsProvider.notifier)
          .replaceWorkout(workout);
    }
    Navigator.pop(context);
  }

  void onDelete(index) {
    if (exerciseList.length > 1) {
      exerciseList.removeAt(index);
      repsControllers.removeAt(index);
      setsControllers.removeAt(index);
      nameControllers.removeAt(index);
      initialExercises.removeAt(index);
      setState(() {});
    }
  }

  void onMoveDown(index) {
    if (exerciseList[index] == exerciseList.last) {
      return;
    }
    var temp = exerciseList[index];
    exerciseList[index] = exerciseList[index + 1];
    exerciseList[index + 1] = temp;
    var temp1 = repsControllers[index];
    repsControllers[index] = repsControllers[index + 1];
    repsControllers[index + 1] = temp1;
    var temp2 = setsControllers[index];
    setsControllers[index] = setsControllers[index + 1];
    setsControllers[index + 1] = temp2;
    var temp3 = nameControllers[index];
    nameControllers[index] = nameControllers[index + 1];
    nameControllers[index + 1] = temp3;
    var temp4 = initialExercises[index];
    initialExercises[index] = initialExercises[index + 1];
    initialExercises[index + 1] = temp4;
    setState(() {});
  }

  void onMoveUp(index) {
    if (exerciseList[index] == exerciseList.first) {
      return;
    }
    var temp = exerciseList[index];
    exerciseList[index] = exerciseList[index - 1];
    exerciseList[index - 1] = temp;
    var temp1 = repsControllers[index];
    repsControllers[index] = repsControllers[index - 1];
    repsControllers[index - 1] = temp1;
    var temp2 = setsControllers[index];
    setsControllers[index] = setsControllers[index - 1];
    setsControllers[index - 1] = temp2;
    var temp3 = nameControllers[index];
    nameControllers[index] = nameControllers[index - 1];
    nameControllers[index - 1] = temp3;
    var temp4 = initialExercises[index];
    initialExercises[index] = initialExercises[index - 1];
    initialExercises[index - 1] = temp4;
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
                if (repsControllers.last.text != '' &&
                    setsControllers.last.text != '' &&
                    nameControllers.last.text != '') {
                  exerciseList.add(null);
                  initialExercises.add(null);
                  initialExercises.add(null);
                  repsControllers.add(TextEditingController());
                  setsControllers.add(TextEditingController());
                  nameControllers.add(TextEditingController());
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
