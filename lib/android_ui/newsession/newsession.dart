import 'dart:developer';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/exercises/selectexercise.dart';
import 'package:lift_tracker/android_ui/newsession/exerciserecorditem.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/old_ui/app/app.dart';

class NewSession extends ConsumerStatefulWidget {
  const NewSession({Key? key, required this.workout, this.resumedSession})
      : super(key: key);
  final Workout workout;
  final WorkoutRecord? resumedSession;

  @override
  ConsumerState<NewSession> createState() => _NewSessionState();
}

enum ExerciseRecordMenuOptions {
  edit,
  add_set,
  not_performed,
  move_up,
  move_down
}

bool shouldRunCacheLoop = true;

class _NewSessionState extends ConsumerState<NewSession>
    with WidgetsBindingObserver {
  List<Exercise> exercises = [];
  Map<int, bool> tmpList = {};
  List<List<TextEditingController>> repsControllersList = [];
  List<List<TextEditingController>> weightControllersList = [];
  List<List<TextEditingController>> rpeControllersList = [];
  List<GlobalKey<AnimatedListState>> animatedListKeys = [];
  List<Exercise> originalExercises = [];
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  bool canSave = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    originalExercises.addAll(widget.workout.exercises);
    bool shouldRunCacheLoop = true;

    if (widget.resumedSession == null) {
      exercises = [...widget.workout.exercises];
      for (int i = 0; i < widget.workout.exercises.length; i++) {
        repsControllersList.add([]);
        weightControllersList.add([]);
        rpeControllersList.add([]);
        animatedListKeys.add(GlobalKey<AnimatedListState>());
        for (int j = 0; j < widget.workout.exercises[i].sets; j++) {
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
    } else {
      exercises = widget.resumedSession!.exerciseRecords.map((exerciseRecord) {
        return Exercise(
            exerciseData: exerciseRecord.exerciseData,
            id: exerciseRecord.exerciseId,
            sets: exerciseRecord.exercise != null
                ? exerciseRecord.exercise!.sets
                : exerciseRecord.sets.length,
            reps: exerciseRecord.exercise != null
                ? exerciseRecord.exercise!.reps
                : 10,
            workoutId: widget.resumedSession!.workoutId);
      }).toList();
      for (int i = 0; i < exercises.length; i++) {
        repsControllersList.add([]);
        weightControllersList.add([]);
        rpeControllersList.add([]);
        animatedListKeys.add(GlobalKey<AnimatedListState>());
        ExerciseRecord exerciseRecord =
            widget.resumedSession!.exerciseRecords[i];
        int stop = Math.max(exercises[i].sets, exerciseRecord.sets.length);
        for (int j = 0; j < stop; j++) {
          String repsText = exerciseRecord.sets[j].reps > -1
              ? exerciseRecord.sets[j].reps.toString()
              : '';
          String weightText = exerciseRecord.sets[j].weight > -1
              ? exerciseRecord.sets[j].weight.toString()
              : '';
          String rpeText = exerciseRecord.sets[j].rpe != null
              ? exerciseRecord.sets[j].rpe.toString()
              : '';
          repsControllersList[i].add(TextEditingController());
          repsControllersList[i][j].text = repsText;
          weightControllersList[i].add(TextEditingController());
          weightControllersList[i][j].text = weightText;
          rpeControllersList[i].add(TextEditingController());
          rpeControllersList[i][j].text = rpeText;
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
    for (int i = 0; i < exercises.length; i++) {
      tmpList.addAll({exercises[i].id: false});
    }

    Future.delayed(Duration.zero, () async {
      if (widget.resumedSession != null) {
        setState(() {
          updateCanSave();
        });
      }
      while (shouldRunCacheLoop) {
        await Future.delayed(Duration(seconds: 30), () async {
          await createWorkoutRecord(cacheMode: true);
        });
      }
    });
  }

  void updateCanSave() {
    var tmp = getCanSave();
    if (tmp != canSave) {
      setState(() {
        canSave = tmp;
      });
    }
  }

  void addExercise() async {
    ExerciseData? newExerciseData =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SelectExercise();
    }));
    if (newExerciseData == null) {
      return;
    }
    int newId = -1;
    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i].id < 0) {
        if (exercises[i].id <= newId) {
          newId = exercises[i].id - 1;
        }
      }
    }
    exercises.add(Exercise(
        workoutId: widget.workout.id,
        id: newId,
        sets: 1,
        reps: 10,
        exerciseData: newExerciseData));
    tmpList.addAll({newId: true});
    repsControllersList.add([TextEditingController()]);
    repsControllersList.last.last.addListener(() {
      updateCanSave();
    });
    weightControllersList.add([TextEditingController()]);
    weightControllersList.last.last.addListener(() {
      updateCanSave();
    });
    rpeControllersList.add([TextEditingController()]);
    rpeControllersList.last.last.addListener(() {
      updateCanSave();
    });
    setState(() {
      canSave = false;
    });
    animatedListKeys.add(GlobalKey<AnimatedListState>());
    animatedListKey.currentState!
        .insertItem(exercises.length - 1, duration: Duration(milliseconds: 0));
  }

  bool getCanSave() {
    for (int i = 0; i < repsControllersList.length; i++) {
      for (int j = 0; j < repsControllersList[i].length; j++) {
        try {
          int? reps = int.tryParse(repsControllersList[i][j].text);
          double? weight = double.tryParse(weightControllersList[i][j].text);
          if (exercises[i].exerciseData.type == 'free') {
            weight = 1;
          }
          int? rpe = int.tryParse(rpeControllersList[i][j].text);
          if (reps == null ||
              reps < 0 ||
              weight == null ||
              weight < 0 ||
              (rpe != null && rpe <= 0)) {
            return false;
          }
        } catch (e) {
          log('getCanSave: ' + e.toString());
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = body();
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            useRootNavigator: false,
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(
                    UIUtilities.loadTranslation(context, 'sessionQuitTitle')),
                content: Text(
                    UIUtilities.loadTranslation(context, 'sessionQuitContent')),
                actions: [
                  TextButton(
                      onPressed: () async {
                        await CustomDatabase.instance
                            .removeCachedSession(widget.workout.id);
                        // this will update ui too
                        widget.workout.hasCache = 0;
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                          UIUtilities.loadTranslation(context, 'resumeNo'))),
                  TextButton(
                      onPressed: () async {
                        await createWorkoutRecord(cacheMode: true);
                        // this will update ui too
                        widget.workout.hasCache = 1;
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                          UIUtilities.loadTranslation(context, 'resumeYes')))
                ],
              );
            });
        return false;
      },
      child: GestureDetector(
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
                                try {
                                  await createWorkoutRecord();
                                  // this will update ui too
                                  widget.workout.hasHistory = true;
                                  Navigator.pop(context);
                                } catch (e) {}
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
      ),
    );
  }

  List<Widget> body() {
    return [
      ...exercises.asMap().entries.map((mapEntry) {
        int index = mapEntry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 16),
          child: ExerciseRecordItem(
            animatedListKey: animatedListKeys[index],
            exerciseData: exercises[index].exerciseData,
            repsControllers: repsControllersList[index],
            weightControllers: weightControllersList[index],
            rpeControllers: rpeControllersList[index],
            popupMenuButton: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: UIUtilities.getPrimaryColor(context),
              ),
              itemBuilder: (context) {
                return menuItems(index);
              },
              onSelected: (item) async {
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
                  case ExerciseRecordMenuOptions.not_performed:
                    repsControllersList[index].forEach((controller) {
                      controller.text = '0';
                    });
                    weightControllersList[index].forEach((controller) {
                      controller.text = '0';
                    });
                    break;
                  case ExerciseRecordMenuOptions.edit:
                    ExerciseData? newExerciseData = await Navigator.push(
                        context, MaterialPageRoute(builder: (context) {
                      return SelectExercise();
                    }));
                    if (newExerciseData != null) {
                      exercises[index].exerciseData = newExerciseData;
                      tmpList[exercises[index].id] = !originalExercises.any(
                          (originalExercise) =>
                              newExerciseData.id ==
                              originalExercise.exerciseData.id);
                      setState(() {});
                    }
                    break;
                  default:
                }
              },
            ),
          ),
        );
      }).toList(),
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(Theme.of(context).useMaterial3 ? 1000 : 0),
          onTap: () {
            addExercise();
          },
          child: ListTile(
              leading: Icon(
                Icons.add,
                color: UIUtilities.getPrimaryColor(context),
              ),
              title: Text(
                UIUtilities.loadTranslation(context, 'addExercise'),
                style: Theme.of(context)
                    .textTheme
                    .button!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              )),
        ),
      )
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
      value: ExerciseRecordMenuOptions.not_performed,
      child: Text(UIUtilities.loadTranslation(context, 'notPerformed')),
    ));
    menuItems.add(PopupMenuItem<ExerciseRecordMenuOptions>(
      value: ExerciseRecordMenuOptions.edit,
      child: Text(UIUtilities.loadTranslation(context, 'changeExercise')),
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
            exerciseData: exercises[i].exerciseData,
            sets: exerciseSets,
            exerciseId: exercise.id,
            type: exercises[i].exerciseData.type,
            temp: cacheMode));
      }
    }
    workoutRecord = WorkoutRecord(
        0, DateTime.now(), widget.workout.name, exerciseRecords,
        workoutId: widget.workout.id);
    try {
      var newWorkoutRecordInfo = await CustomDatabase.instance
          .addWorkoutRecord(workoutRecord, cacheMode: cacheMode);

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
      if (error.toString() == 'Exception: empty_exercises') {
        UIUtilities.showSnackBar(
            context: context,
            msg: UIUtilities.loadTranslation(context, 'emptySession'));
        throw error;
      }
      UIUtilities.showSnackBar(
          context: context, msg: 'newsession: ' + error.toString());
      return;
    }
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    shouldRunCacheLoop = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      shouldRunCacheLoop = false;
      //create a cached session
      await createWorkoutRecord(cacheMode: true);
    } else if (state == AppLifecycleState.resumed) {
      shouldRunCacheLoop = true;
    }
  }
}
