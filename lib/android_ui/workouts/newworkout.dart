import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/workouts/newexercisecard.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/android_ui/widgets/appbardata.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/android_ui//exercises/selectexercise.dart';

class NewWorkout extends ConsumerStatefulWidget {
  const NewWorkout({Key? key}) : super(key: key);

  @override
  ConsumerState<NewWorkout> createState() => _NewWorkoutState();
}

class _NewWorkoutState extends ConsumerState<NewWorkout> {
  TextEditingController workoutNameController = TextEditingController();
  List<ExerciseData?> exerciseDataList = [];
  List<TextEditingController> setsControllers = [];
  List<TextEditingController> repsControllers = [];
  bool canSave = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyWidgets = body();
    return WillPopScope(
      onWillPop: () async {
        UIUtilities.showDimmedBackgroundDialog(context,
            title: UIUtilities.loadTranslation(context, 'discard'),
            content: UIUtilities.loadTranslation(context, 'discardContent'),
            leftText: UIUtilities.loadTranslation(context, 'discardNo'),
            rightText: UIUtilities.loadTranslation(context, 'discardYes'),
            leftOnPressed: () {
          Navigator.maybePop(context);
        }, rightOnPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: UIUtilities.getScaffoldBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: UIUtilities.getAppBarColor(context),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.maybePop(context);
              /*showDialog(
                  useRootNavigator: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title:
                          Text(UIUtilities.loadTranslation(context, 'discard')),
                      content: Text(
                          UIUtilities.loadTranslation(context, 'discardContent')),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(UIUtilities.loadTranslation(
                                context, 'keepThem'))),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(UIUtilities.loadTranslation(
                                context, 'yesDiscard')))
                      ],
                    );
                  });*/
            },
          ),
          title: Text("${UIUtilities.loadTranslation(context, 'newWorkout')}"),
          actions: [
            AnimatedSize(
              duration: Duration(milliseconds: 150),
              curve: Curves.decelerate,
              child: Row(children: [
                canSave
                    ? IconButton(
                        tooltip: 'Save',
                        onPressed: () {
                          saveWorkout().then((value) {
                            Navigator.pop(context);
                          }).catchError((error) {
                            UIUtilities.showSnackBar(
                                context: context,
                                msg: UIUtilities.loadTranslation(
                                        context, 'error') +
                                    ': $error');
                          });
                        },
                        icon: Icon(Icons.done))
                    : SizedBox()
              ]),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            UIUtilities.unfocusTextFields(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
                cacheExtent: 0,
                itemCount: bodyWidgets.length,
                itemBuilder: (context, index) {
                  return bodyWidgets[index];
                }),
          ),
        ),
      ),
    );
  }

  List<Widget> body() {
    InputDecorationTheme inputDecorationTheme =
        Theme.of(context).inputDecorationTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).primaryTextTheme;
    return [
      TextFormField(
        controller: workoutNameController,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.onBackground)),
            floatingLabelBehavior: inputDecorationTheme.floatingLabelBehavior,
            label: Text(UIUtilities.loadTranslation(context, 'workoutName'))),
      ),
      SizedBox(
        height: 32,
      ),
      Text(
        UIUtilities.loadTranslation(context, 'exercises'),
        style: textTheme.titleMedium,
      ),
      ...exerciseDataList.asMap().entries.map<Widget>((mapEntry) {
        int i = mapEntry.key;
        var items = menuItems(i);
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: NewExerciseCard(
              exerciseName: mapEntry.value?.name,
              setsController: setsControllers[i],
              repsController: repsControllers[i],
              popupMenuButton: items.isEmpty
                  ? null
                  : PopupMenuButton<MoveOrRemoveMenuOption>(
                      onSelected: (option) {
                        switch (option) {
                          case MoveOrRemoveMenuOption.move_up:
                            moveUp(i);
                            break;
                          case MoveOrRemoveMenuOption.move_down:
                            moveDown(i);
                            break;
                          case MoveOrRemoveMenuOption.remove:
                            remove(i);
                            break;
                        }
                      },
                      itemBuilder: ((context) => menuItems(i))),
              exerciseNumber: i + 1,
              onSelectExercise: () async {
                ExerciseData? newExerciseData = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return SelectExercise();
                }));
                if (newExerciseData != null) {
                  setState(() {
                    exerciseDataList[i] = newExerciseData;
                  });
                }
              }),
        );
      }).toList(),
      const SizedBox(height: 16),
      IconButton(
        icon: ListTile(
          contentPadding: EdgeInsets.only(left: 0),
          leading: Icon(Icons.add),
          title: Text(UIUtilities.loadTranslation(context, 'addExercise')),
        ),
        onPressed: () {
          if (exerciseDataList.last != null &&
              setsControllers.last.text.isNotEmpty &&
              repsControllers.last.text.isNotEmpty) {
            setState(() {
              exerciseDataList.add(null);
              setsControllers.add(TextEditingController());
              setsControllers.last.addListener(() {
                setState(() {
                  canSave = getCanSave();
                });
              });
              repsControllers.add(TextEditingController());
              repsControllers.last.addListener(() {
                setState(() {
                  canSave = getCanSave();
                });
              });
              canSave = false;
            });
          }
        },
      )
    ];
  }

  @override
  void initState() {
    super.initState();
    setsControllers.add(TextEditingController());
    setsControllers.first.addListener(() {
      setState(() {
        canSave = getCanSave();
      });
    });
    repsControllers.add(TextEditingController());
    repsControllers.first.addListener(() {
      setState(() {
        canSave = getCanSave();
      });
    });
    workoutNameController.addListener(() {
      setState(() {
        canSave = getCanSave();
      });
    });
    exerciseDataList.add(null);
  }

  List<PopupMenuItem<MoveOrRemoveMenuOption>> menuItems(int index) {
    List<PopupMenuItem<MoveOrRemoveMenuOption>> menuItems = [];
    if (exerciseDataList.length == 1 && exerciseDataList.first == null) {
      return menuItems;
    }
    if (index > 0) {
      menuItems.add(PopupMenuItem<MoveOrRemoveMenuOption>(
        value: MoveOrRemoveMenuOption.move_up,
        child: Text(UIUtilities.loadTranslation(context, 'moveUp')),
      ));
    }
    if (index < exerciseDataList.length - 1) {
      menuItems.add(PopupMenuItem<MoveOrRemoveMenuOption>(
        value: MoveOrRemoveMenuOption.move_down,
        child: Text(UIUtilities.loadTranslation(context, 'moveDown')),
      ));
    }
    // since the first element is always null
    if (exerciseDataList.isNotEmpty) {
      menuItems.add(PopupMenuItem<MoveOrRemoveMenuOption>(
        value: MoveOrRemoveMenuOption.remove,
        child: Text(UIUtilities.loadTranslation(context, 'remove')),
      ));
    }
    return menuItems;
  }

  bool getCanSave() {
    if (setsControllers.isEmpty ||
        repsControllers.isEmpty ||
        workoutNameController.text.isEmpty ||
        exerciseDataList.isEmpty) {
      return false;
    }
    for (int i = 0; i < setsControllers.length; i++) {
      if (setsControllers[i].text.isEmpty || repsControllers[i].text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void moveUp(int index) {
    if (index <= 0) {
      return;
    }
    TextEditingController tmpController = setsControllers[index];
    setsControllers[index] = setsControllers[index - 1];
    setsControllers[index - 1] = tmpController;
    tmpController = repsControllers[index];
    repsControllers[index] = repsControllers[index - 1];
    repsControllers[index - 1] = tmpController;
    ExerciseData? tmpExerciseData = exerciseDataList[index];
    exerciseDataList[index] = exerciseDataList[index - 1];
    exerciseDataList[index - 1] = tmpExerciseData;
    setState(() {});
  }

  void moveDown(int index) {
    if (index >= exerciseDataList.length - 1) {
      return;
    }
    TextEditingController tmpController = setsControllers[index];
    setsControllers[index] = setsControllers[index + 1];
    setsControllers[index + 1] = tmpController;
    tmpController = repsControllers[index];
    repsControllers[index] = repsControllers[index + 1];
    repsControllers[index + 1] = tmpController;
    ExerciseData? tmpExerciseData = exerciseDataList[index];
    exerciseDataList[index] = exerciseDataList[index + 1];
    exerciseDataList[index + 1] = tmpExerciseData;
    setState(() {});
  }

  void remove(int index) {
    if (exerciseDataList.length <= 1) {
      setState(() {
        setsControllers[index].text = '';
        repsControllers[index].text = '';
        exerciseDataList[index] = null;
      });
      return;
    }
    setsControllers.removeAt(index);
    repsControllers.removeAt(index);
    exerciseDataList.removeAt(index);
    setState(() {
      canSave = getCanSave();
    });
  }

  Future saveWorkout() async {
    if (!canSave) {
      return;
    }
    List<Exercise> exercises = [];
    Workout workout;
    for (int i = 0; i < exerciseDataList.length; i++) {
      int sets = int.parse(setsControllers[i].text);
      int reps = int.parse(repsControllers[i].text);
      exercises.add(Exercise(
          workoutId: 0,
          id: 0,
          sets: sets,
          reps: reps,
          exerciseData: exerciseDataList[i]!));
    }
    workout = Workout(0, workoutNameController.text, exercises);
    int id = await CustomDatabase.instance.saveWorkout(workout);
    workout.id = id;
    ref.read(Helper.instance.workoutsProvider.notifier).addWorkout(workout);
  }
}
