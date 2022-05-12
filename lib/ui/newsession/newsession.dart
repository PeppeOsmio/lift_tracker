import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/ui/newsession/exerciserecorditem.dart';
import 'package:lift_tracker/ui/styles.dart';
import 'package:lift_tracker/ui/selectexercise.dart';
import 'package:lift_tracker/ui/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewSession extends ConsumerStatefulWidget {
  const NewSession(this.workout, {this.resumedSession, Key? key})
      : super(key: key);
  final Workout workout;
  final WorkoutRecord? resumedSession;

  @override
  _NewSessionState createState() => _NewSessionState();
}

class _NewSessionState extends ConsumerState<NewSession>
    with WidgetsBindingObserver {
  List<ExerciseRecordItem> records = [];
  late SharedPreferences pref;
  List<ExerciseData> exerciseDataList = [];
  List<ExerciseData> originalExerciseDataList = [];
  List<bool> tempList = [];
  List<List<TextEditingController>> repsControllersLists = [];
  List<List<TextEditingController>> weightControllersLists = [];
  List<List<TextEditingController>> rpeControllersLists = [];
  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //remove cached sessions
    SharedPreferences.getInstance().then((value) async {
      pref = value;
      CustomDatabase.instance.removeCachedSession();
    });
    if (widget.resumedSession == null) {
      exercises.addAll(widget.workout.exercises);
      for (int i = 0; i < exercises.length; i++) {
        tempList.add(false);
        Exercise exercise = exercises[i];
        exerciseDataList.add(exercise.exerciseData);
      }
    } else {
      for (int i = 0; i < widget.resumedSession!.exerciseRecords.length; i++) {
        if (i < widget.workout.exercises.length) {
          tempList.add(false);
        } else {
          tempList.add(true);
        }
        log('exlenbefore: ' +
            widget.resumedSession!.exerciseRecords.length.toString());
        Exercise exercise = Exercise(
          workoutId: widget.workout.id,
          exerciseData: Helper.exerciseDataGlobal.firstWhere((element) =>
              element.name ==
              widget.resumedSession!.exerciseRecords[i].exerciseName),
          id: widget.resumedSession!.exerciseRecords[i].exerciseId,
          sets: widget.resumedSession!.exerciseRecords[i].sets.length,
          reps: i < widget.workout.exercises.length
              ? widget.workout.exercises[i].reps
              : 10,
        );
        exercises.add(exercise);
        exerciseDataList.add(exercise.exerciseData);
      }
    }
    originalExerciseDataList
        .addAll(exerciseDataList.getRange(0, widget.workout.exercises.length));
    for (int i = 0; i < exercises.length; i++) {
      repsControllersLists.add([]);
      weightControllersLists.add([]);
      rpeControllersLists.add([]);
      int limit;
      if (widget.resumedSession != null) {
        limit = widget.resumedSession!.exerciseRecords[i].sets.length;
      } else {
        limit = exercises[i].sets;
      }
      for (int j = 0; j < limit; j++) {
        repsControllersLists[i].add(TextEditingController());
        weightControllersLists[i].add(TextEditingController());
        rpeControllersLists[i].add(TextEditingController());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    records.clear();
    for (int i = 0; i < exercises.length; i++) {
      records.add(ExerciseRecordItem(
        exercises[i],
        temp: tempList[i],
        onExerciseChange: () async {
          var result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return SelectExercise();
          }));
          if (result != null) {
            if (i < originalExerciseDataList.length) {
              if (originalExerciseDataList[i].id != result.id) {
                tempList[i] = true;
              } else {
                tempList[i] = false;
              }
            }
            exerciseDataList[i] = result;
            setState(() {});
          }
        },
        onAddSet: () {
          repsControllersLists[i].add(TextEditingController());
          weightControllersLists[i].add(TextEditingController());
          rpeControllersLists[i].add(TextEditingController());
        },
        repsControllers: repsControllersLists[i],
        weightControllers: weightControllersLists[i],
        rpeControllers: rpeControllersLists[i],
        exerciseData: exerciseDataList[i],
        startingRecord: widget.resumedSession != null
            ? i < widget.resumedSession!.exerciseRecords.length
                ? widget.resumedSession!.exerciseRecords[i]
                : null
            : null,
      ));

      items.add(Padding(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: records[i],
      ));
    }
    items.add(const SizedBox(
      height: 16,
    ));
    return WillPopScope(
      onWillPop: () async {
        bool willPop = false;
        await showDimmedBackgroundDialog(context,
            rightText: Helper.loadTranslation(context, 'cancel'),
            leftText: Helper.loadTranslation(context, 'yes'),
            rightOnPressed: () => Navigator.maybePop(context),
            leftOnPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context);
              await CustomDatabase.instance.removeCachedSession();
              willPop = true;
              Fluttertoast.showToast(
                  msg: Helper.loadTranslation(context, 'sessionCanceled'));
            },
            title: Helper.loadTranslation(context, 'cancelSession'),
            content: Helper.loadTranslation(context, 'cancelSessionBody'));
        return willPop;
      },
      child: GestureDetector(
        onTap: () {
          var currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SafeArea(
          child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Palette.backgroundDark,
              body: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    CustomAppBar(
                        middleText:
                            Helper.loadTranslation(context, 'newSessionOf') +
                                ' ' +
                                widget.workout.name,
                        onBack: () => Navigator.maybePop(context),
                        onSubmit: () => createWorkoutSession(),
                        backButton: true,
                        submitButton: true),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8, left: 0, right: 0, bottom: 0),
                        child: ListView.builder(
                            cacheExtent: 0,
                            itemCount: items.length + 1,
                            itemBuilder: ((context, index) {
                              if (index == items.length) {
                                return addExerciseButton();
                              }
                              return items[index];
                            })),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Future createWorkoutSession({bool cacheMode = false}) async {
    WorkoutRecord? workoutRecord;
    // remove cached sessions
    int id = await CustomDatabase.instance.removeCachedSession();
    if (id != -1) {
      log('createWorkoutSession: removed cached session.');
    }
    // create cached session
    if (cacheMode) {
      workoutRecord = getWorkoutRecord(cacheMode: true);
      await CustomDatabase.instance
          .addWorkoutRecord(workoutRecord!, cacheMode: true);
      return;
    }

    // create regular session
    try {
      workoutRecord = getWorkoutRecord();
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: Helper.loadTranslation(context, 'fillAllFields'));
      return;
    }
    if (workoutRecord == null) {
      log('Null workout record');
      Navigator.maybePop(context);
      return;
    }
    try {
      //inform the addWorkoutRecord function that the cache has been deleted already
      await pref.setBool('didCacheSession', false);

      bool didSetRecord =
          await CustomDatabase.instance.addWorkoutRecord(workoutRecord);
      if (didSetRecord) {
        ref.read(Helper.workoutsProvider.notifier).refreshWorkouts();
      }
    } catch (e) {
      log(e.toString());
      Navigator.maybePop(context);
      return;
    }
    Navigator.pop(context);
    ref.read(Helper.workoutRecordsProvider.notifier).refreshWorkoutRecords();
  }

  WorkoutRecord? getWorkoutRecord({bool cacheMode = false}) {
    if (cacheMode) {
      List<ExerciseRecord> exerciseRecords = [];
      for (int i = 0; i < exercises.length; i++) {
        ExerciseRecord exerciseRecord;
        exerciseRecord = records[i].cacheExerciseRecord;
        exerciseRecord.temp = true;
        exerciseRecords.add(exerciseRecord);
      }
      return WorkoutRecord(
          0, DateTime.now(), widget.workout.name, exerciseRecords,
          workoutId: widget.workout.id);
    }
    List<ExerciseRecord?> exerciseRecords = [];
    for (int i = 0; i < exercises.length; i++) {
      ExerciseRecord? exerciseRecord;
      try {
        exerciseRecord = records[i].exerciseRecord;
      } catch (e) {
        throw Exception();
      }
      if (exerciseRecord == null) {
        return null;
      }
      exerciseRecord.temp = tempList[i];
      exerciseRecords.add(exerciseRecord);
    }
    List<ExerciseRecord> temp = [];
    for (int j = 0; j < exerciseRecords.length; j++) {
      ExerciseRecord? record = exerciseRecords[j];
      temp.add(record!);
    }
    return WorkoutRecord(0, DateTime.now(), widget.workout.name, temp,
        workoutId: widget.workout.id);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      //create a cached session
      await createWorkoutSession(cacheMode: true);
    }
  }

  Widget addExerciseButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
          child: SizedBox(
              height: 65,
              width: 65,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return SelectExercise();
                  }));
                  if (result == null) {
                    return;
                  }
                  tempList.add(true);
                  exercises.add(Exercise(
                      exerciseData: result,
                      id: 0,
                      workoutId: widget.workout.id,
                      sets: 1,
                      reps: 10));
                  exerciseDataList.add(result);
                  repsControllersLists.add([TextEditingController()]);
                  weightControllersLists.add([TextEditingController()]);
                  rpeControllersLists.add([TextEditingController()]);

                  setState(() {});
                },
                backgroundColor: const Color.fromARGB(255, 31, 31, 31),
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: const FittedBox(
                  child: Icon(Icons.add_outlined),
                ),
              ))),
    );
  }
}
