import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/newsession/exerciserecorditem.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/old_ui/app/app.dart';
import 'package:lift_tracker/android_ui/widgets/materialpopupmenu.dart';

class NewSession extends ConsumerStatefulWidget {
  const NewSession({Key? key, required this.workout, this.resumedSession})
      : super(key: key);
  final Workout workout;
  final WorkoutRecord? resumedSession;

  @override
  ConsumerState<NewSession> createState() => _NewSessionState();
}

enum ExerciseRecordMenuOptions { edit, add_set, reset, move_up, move_down }

class _NewSessionState extends ConsumerState<NewSession>
    with WidgetsBindingObserver {
  List<Exercise> exercises = [];
  List<List<TextEditingController>> repsControllersList = [];
  List<List<TextEditingController>> weightControllersList = [];
  List<List<TextEditingController>> rpeControllersList = [];
  List<GlobalKey<AnimatedListState>> animatedListKeys = [];
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  bool canSave = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    exercises = [...widget.workout.exercises];
    for (int i = 0; i < exercises.length; i++) {
      repsControllersList.add([]);
      weightControllersList.add([]);
      rpeControllersList.add([]);
      animatedListKeys.add(GlobalKey<AnimatedListState>());
      for (int j = 0; j < exercises[i].sets; j++) {
        repsControllersList[i].add(TextEditingController());
        weightControllersList[i].add(TextEditingController());
        rpeControllersList[i].add(TextEditingController());
        repsControllersList[i].last.addListener(() {
          updateCanSave();
        });
        weightControllersList[i].last.addListener(() {
          updateCanSave();
        });
        rpeControllersList[i].last.addListener(() {
          updateCanSave();
        });
      }
    }
  }

  void updateCanSave() {
    var tmp = getCanSave();
    if (tmp != canSave) {
      setState(() {
        canSave = tmp;
      });
    }
  }

  bool getCanSave() {
    for (int i = 0; i < exercises.length; i++) {
      Exercise exercise = exercises[i];
      for (int j = 0; j < exercise.sets; j++) {
        try {
          int reps = int.parse(repsControllersList[i][j].text);
          double weight = double.parse(weightControllersList[i][j].text);
          int? rpe = int.tryParse(rpeControllersList[i][j].text);
          if (reps < 0 || weight < 0 || (rpe != null && rpe <= 0)) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = body();
    for (int i = 0; i < items.length; i++) {
      items[i] = Padding(
        padding: const EdgeInsets.only(left: 16),
        child: items[i],
      );
    }
    return GestureDetector(
      onTap: () {
        UIUtilities.unfocusTextFields(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(UIUtilities.loadTranslation(context, 'newSessionOf') +
              ' ${widget.workout.name}'),
          actions: [
            AnimatedSize(
                duration: Duration(milliseconds: 150),
                child: Row(
                  children: [
                    canSave
                        ? IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () async {
                              await createWorkoutRecord();
                              Navigator.pop(context);
                            },
                          )
                        : SizedBox()
                  ],
                ))
          ],
        ),
        body: AnimatedList(
            key: animatedListKey,
            initialItemCount: items.length,
            itemBuilder: (context, index, animation) {
              return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                      sizeFactor: animation, child: items[index]));
            }),
      ),
    );
  }

  List<Widget> body() {
    return [
      ...exercises.asMap().entries.map((mapEntry) {
        int index = mapEntry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ExerciseRecordItem(
            animatedListKey: animatedListKeys[index],
            exercise: exercises[index],
            repsControllers: repsControllersList[index],
            weightControllers: weightControllersList[index],
            rpeControllers: rpeControllersList[index],
            popupMenuButton: MaterialPopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: UIUtilities.getPrimaryColor(context),
              ),
              itemBuilder: (context) {
                return menuItems(index);
              },
              onSelected: (item) {
                switch (item) {
                  case ExerciseRecordMenuOptions.add_set:
                    repsControllersList[index].add(TextEditingController());
                    weightControllersList[index].add(TextEditingController());
                    rpeControllersList[index].add(TextEditingController());
                    repsControllersList[index].last.addListener(() {
                      updateCanSave();
                    });
                    weightControllersList[index].last.addListener(() {
                      updateCanSave();
                    });
                    rpeControllersList[index].last.addListener(() {
                      updateCanSave();
                    });
                    animatedListKeys[index].currentState!.insertItem(
                        repsControllersList[index].length - 1,
                        duration: Duration(milliseconds: 150));
                    break;
                  case ExerciseRecordMenuOptions.move_down:
                    swapExerciseRecordCards(index, index + 1);
                    break;
                  case ExerciseRecordMenuOptions.move_up:
                    swapExerciseRecordCards(index, index - 1);
                    break;
                  default:
                }
              },
            ),
          ),
        );
      }).toList(),
    ];
  }

  void swapExerciseRecordCards(int index1, int index2) {
    var tmpEx = exercises[index1];
    exercises[index1] = exercises[index2];
    exercises[index2] = tmpEx;
    var tmpReps = repsControllersList[index1];
    repsControllersList[index1] = repsControllersList[index2];
    repsControllersList[index2] = tmpReps;
    var tmpWeights = weightControllersList[index1];
    weightControllersList[index1] = weightControllersList[index2];
    weightControllersList[index2] = tmpWeights;
    var tmpRpes = rpeControllersList[index1];
    rpeControllersList[index1] = rpeControllersList[index2];
    rpeControllersList[index2] = tmpRpes;
    var tmpKey = animatedListKeys[index1];
    animatedListKeys[index1] = animatedListKeys[index2];
    animatedListKeys[index2] = tmpKey;
    setState(() {});
  }

  List<PopupMenuItem<ExerciseRecordMenuOptions>> menuItems(int index) {
    List<PopupMenuItem<ExerciseRecordMenuOptions>> menuItems = [];
    menuItems.add(PopupMenuItem<ExerciseRecordMenuOptions>(
      value: ExerciseRecordMenuOptions.add_set,
      child: Text(UIUtilities.loadTranslation(context, 'addSet')),
    ));
    menuItems.add(PopupMenuItem<ExerciseRecordMenuOptions>(
      value: ExerciseRecordMenuOptions.reset,
      child: Text(UIUtilities.loadTranslation(context, 'reset')),
    ));
    if (index > 0) {
      menuItems.add(PopupMenuItem<ExerciseRecordMenuOptions>(
        value: ExerciseRecordMenuOptions.move_up,
        child: Text(UIUtilities.loadTranslation(context, 'moveUp')),
      ));
    }
    if (index < exercises.length - 1) {
      menuItems.add(PopupMenuItem<ExerciseRecordMenuOptions>(
        value: ExerciseRecordMenuOptions.move_down,
        child: Text(UIUtilities.loadTranslation(context, 'moveDown')),
      ));
    }
    return menuItems;
  }

  Future createWorkoutRecord({bool cacheMode = false}) async {
    WorkoutRecord workoutRecord;
    List<ExerciseRecord> exerciseRecords = [];
    for (int i = 0; i < exercises.length; i++) {
      Exercise exercise = exercises[i];
      List<ExerciseSet> exerciseSets = [];
      for (int j = 0; j < repsControllersList[i].length; j++) {
        int reps = int.tryParse(repsControllersList[i][j].text) ?? -1;
        if (reps == -1 && !cacheMode) {
          throw Exception();
        }
        double weight = double.tryParse(weightControllersList[i][j].text) ?? -1;
        if ((reps > 0 && weight > 0) || cacheMode) {
          int? rpe = int.tryParse(rpeControllersList[i][j].text);
          exerciseSets.add(ExerciseSet(reps: reps, weight: weight, rpe: rpe));
        }
      }
      if (exerciseSets.isNotEmpty) {
        exerciseRecords.add(ExerciseRecord(
            exerciseData: exercise.exerciseData,
            sets: exerciseSets,
            exerciseId: exercise.id,
            type: exercise.exerciseData.type,
            temp: cacheMode));
      }
    }
    workoutRecord = WorkoutRecord(
        0, DateTime.now(), widget.workout.name, exerciseRecords,
        workoutId: widget.workout.id);
    try {
      var newWorkoutRecordInfo = await CustomDatabase.instance
          .addWorkoutRecord(workoutRecord, cacheMode: cacheMode)
          .catchError((error) {
        UIUtilities.showSnackBar(
            context: context, msg: 'newsession: ' + error.toString());
      });
      if (cacheMode) {
        return;
      }
      bool didSetRecord = newWorkoutRecordInfo['didSetRecord'] == 1;
      int newId = newWorkoutRecordInfo['workoutRecordId']!;
      // if a record was set, read the new workout and replace the old one
      if (didSetRecord && newId > 0) {
        await CustomDatabase.instance
            .readWorkouts(workoutId: workoutRecord.workoutId)
            .then((workouts) {
          ref
              .read(Helper.instance.workoutsProvider.notifier)
              .replaceWorkout(workouts[0]);
        }).catchError((error) {
          UIUtilities.showSnackBar(
              context: context, msg: 'newsession: ' + error.toString());
        });
      }
      widget.workout.hasCache = 0;
      // if the workout sessions list was never loaded from the DB,
      // don't add the new session to the Provider
      if (CustomDatabase.instance.didReadWorkoutRecords) {
        log('Adding newly created workout record to list');
        await CustomDatabase.instance
            .readWorkoutRecords(
                workoutRecordId: newWorkoutRecordInfo['workoutRecordId'])
            .then((workoutRecords) {
          ref
              .read(Helper.instance.workoutRecordsProvider.notifier)
              .addWorkoutRecord(workoutRecords.first);
        }).catchError((error) {
          UIUtilities.showSnackBar(
              context: context, msg: 'newsession: ' + error.toString());
        });
      }
      if (newId > 0) {
        await CustomDatabase.instance.removeCachedSession(newId);
      }
    } catch (error) {
      UIUtilities.showSnackBar(
          context: context, msg: 'newsession: ' + error.toString());
      Navigator.maybePop(context);
      return;
    }
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      //create a cached session
      await createWorkoutRecord(cacheMode: true);
    }
  }
}
