import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/ui/colors.dart';
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
  List<Exercise> data = [];
  late SharedPreferences pref;
  List<ExerciseData> exerciseDataList = [];
  List<ExerciseData> originalExerciseDataList = [];
  List<bool> tempList = [];
  List<List<TextEditingController>> repsControllersLists = [];
  List<List<TextEditingController>> weightControllersLists = [];
  List<List<TextEditingController>> rpeControllersLists = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    //remove cached sessions
    SharedPreferences.getInstance().then((value) async {
      pref = value;
      CustomDatabase.instance.removeCachedSession();
    });
    if (widget.resumedSession == null) {
      for (int i = 0; i < widget.workout.exercises.length; i++) {
        tempList.add(false);
        Exercise exercise = widget.workout.exercises[i];
        exerciseDataList.add(exercise.exerciseData);
      }
    } else {
      for (int i = 0; i < widget.resumedSession!.exerciseRecords.length; i++) {
        tempList.add(false);
        Exercise exercise = Exercise(
          workoutId: widget.workout.id,
          exerciseData: ExerciseData(
              id: i,
              type: widget.resumedSession!.exerciseRecords[i].type,
              name: ''),
          id: widget.resumedSession!.exerciseRecords[i].exerciseId,
          name: widget.resumedSession!.exerciseRecords[i].exerciseName,
          sets: widget.resumedSession!.exerciseRecords[i].sets.length,
          reps: widget.workout.exercises[i].reps,
        );
        exerciseDataList.add(exercise.exerciseData);
      }
    }
    originalExerciseDataList = exerciseDataList;
    for (int i = 0; i < widget.workout.exercises.length; i++) {
      repsControllersLists.add([]);
      weightControllersLists.add([]);
      rpeControllersLists.add([]);
      int limit;
      if (widget.resumedSession != null) {
        limit = widget.resumedSession!.exerciseRecords[i].sets.length;
      } else {
        limit = widget.workout.exercises[i].sets;
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
    for (int i = 0; i < widget.workout.exercises.length; i++) {
      records.add(ExerciseRecordItem(
        widget.workout.exercises[i],
        onExerciseChange: () async {
          var result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return SelectExercise();
          }));
          if (result != null) {
            if (originalExerciseDataList[i].id != result.id) {
              tempList[i] = true;
            } else {
              tempList[i] = false;
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
            ? widget.resumedSession!.exerciseRecords[i]
            : null,
      ));

      items.add(Padding(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: records[i],
      ));
    }
    items.add(const SizedBox(height: 24));

    return GestureDetector(
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
                      onBack: () {
                        CustomDatabase.instance.removeCachedSession();
                        Navigator.pop(context);
                      },
                      onSubmit: () => createWorkoutSession(),
                      backButton: true,
                      submitButton: true),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8, left: 0, right: 0, bottom: 0),
                      child: ListView.builder(
                          cacheExtent: 0,
                          itemCount: items.length,
                          itemBuilder: ((context, index) {
                            log('rendering $index');
                            return items[index];
                          })),
                    ),
                  ),
                ],
              ),
            )),
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
          .addWorkoutRecord(workoutRecord!, widget.workout, cacheMode: true);
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
      await showDimmedBackgroundDialog(context,
          rightText: Helper.loadTranslation(context, 'cancel'),
          leftText: Helper.loadTranslation(context, 'yes'),
          rightOnPressed: () => Navigator.maybePop(context),
          leftOnPressed: () {
            Navigator.pop(context);
            Navigator.maybePop(context);
            Fluttertoast.showToast(
                msg: Helper.loadTranslation(context, 'sessionCanceled'));
          },
          title: Helper.loadTranslation(context, 'cancelSession'),
          content: Helper.loadTranslation(context, 'cancelSessionBody'));
      return;
    }
    try {
      //inform the addWorkoutRecord function that the cache has been deleted already
      await pref.setBool('didCacheSession', false);
      bool didSetRecord = await CustomDatabase.instance
          .addWorkoutRecord(workoutRecord, widget.workout);
      if (didSetRecord) {
        ref.read(Helper.workoutsProvider.notifier).refreshWorkouts();
      }
    } catch (e) {
      log(e.toString());
      await showDimmedBackgroundDialog(context,
          leftText: Helper.loadTranslation(context, 'yes'),
          rightText: Helper.loadTranslation(context, 'cancel'),
          leftOnPressed: () {
        ref
            .read(Helper.workoutRecordsProvider.notifier)
            .refreshWorkoutRecords();

        Navigator.pop(context);
        Navigator.maybePop(context);
        Fluttertoast.showToast(msg: 'Session canceled');
      }, rightOnPressed: () {
        Navigator.maybePop(context);
      },
          title: Helper.loadTranslation(context, 'cancelSession'),
          content: Helper.loadTranslation(context, 'cancelSessionBody'));
      return;
    }
    Navigator.pop(context);
    ref.read(Helper.workoutRecordsProvider.notifier).refreshWorkoutRecords();
  }

  WorkoutRecord? getWorkoutRecord({bool cacheMode = false}) {
    if (cacheMode) {
      List<ExerciseRecord> exerciseRecords = [];
      for (int i = 0; i < widget.workout.exercises.length; i++) {
        ExerciseRecord exerciseRecord;
        exerciseRecord = records[i].cacheExerciseRecord;

        exerciseRecords.add(exerciseRecord);
      }
      List<ExerciseRecord> temp = [];
      for (int j = 0; j < exerciseRecords.length; j++) {
        ExerciseRecord record = exerciseRecords[j];
        temp.add(record);
      }
      return WorkoutRecord(0, DateTime.now(), widget.workout.name, temp,
          workoutId: widget.workout.id);
    }
    List<ExerciseRecord?> exerciseRecords = [];
    for (int i = 0; i < widget.workout.exercises.length; i++) {
      ExerciseRecord? exerciseRecord;
      try {
        exerciseRecord = records[i].exerciseRecord;
      } catch (e) {
        throw Exception();
      }
      if (exerciseRecord == null) {
        return null;
      }
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
    WidgetsBinding.instance!.removeObserver(this);
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
}

class SetRow extends StatefulWidget {
  const SetRow(this.rowIndex,
      {required this.repsController,
      required this.weightController,
      required this.rpeController,
      required this.exerciseType,
      Key? key})
      : super(key: key);
  final int rowIndex;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final TextEditingController rpeController;
  final String exerciseType;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 24,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${widget.rowIndex}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 31, 31),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    keyboardType: TextInputType.number,
                    controller: widget.repsController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: 'Reps',
                      border: InputBorder.none,
                    ),
                  )),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 31, 31),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    controller: widget.weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    readOnly: widget.exerciseType == 'free' ? true : false,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        decoration: widget.exerciseType == 'free'
                            ? TextDecoration.lineThrough
                            : null,
                        decorationThickness: 2,
                      ),
                      hintText: 'Kg',
                      border: InputBorder.none,
                    ),
                  )),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 31, 31),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      onEditingComplete: () {
                        String text = widget.rpeController.text;
                        if (text != '' && int.parse(text) > 10) {
                          widget.rpeController.text = '10';
                        }
                        var currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      controller: widget.rpeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Rpe',
                        border: InputBorder.none,
                      ))),
            ),
          )
        ],
      ),
    );
  }
}

class ExerciseRecordItem extends StatefulWidget {
  const ExerciseRecordItem(this.exercise,
      {required this.repsControllers,
      required this.weightControllers,
      required this.rpeControllers,
      required this.exerciseData,
      required this.onExerciseChange,
      required this.onAddSet,
      this.startingRecord,
      Key? key})
      : super(key: key);
  final Exercise exercise;
  final ExerciseRecord? startingRecord;
  final Function onExerciseChange;
  final ExerciseData exerciseData;
  final List<TextEditingController> repsControllers;
  final List<TextEditingController> weightControllers;
  final List<TextEditingController> rpeControllers;
  final Function() onAddSet;
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
    return ExerciseRecord(exerciseData.name, setList,
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
      name = exercise.name;
    }
    return ExerciseRecord(name, setList,
        exerciseId: exercise.id, type: exerciseData.type);
  }

  @override
  _ExerciseRecordItemState createState() => _ExerciseRecordItemState();
}

class _ExerciseRecordItemState extends State<ExerciseRecordItem> {
  ExerciseRecord? startingRecord;

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
    double width = MediaQuery.of(context).size.width;
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
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Spacer(),
              const SizedBox(
                width: 24,
              ),
              GestureDetector(
                onTap: () {
                  widget.onExerciseChange();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    IntrinsicWidth(
                      child: Text(
                        Helper.loadTranslation(
                            context, widget.exerciseData.name),
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
                      Helper.loadTranslation(context, 'set'),
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: FittedBox(
                      child: Text(
                        '${Helper.loadTranslation(context, 'repsGoal')}: ${widget.exercise.reps}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
              ),
              Expanded(
                flex: 10,
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 24, bottom: 24, left: 8),
                    child: Text(
                        widget.exerciseData.type != 'free'
                            ? widget.exercise.bestWeight != null
                                ? '${Helper.loadTranslation(context, 'bestWeight')}: ${widget.exercise.bestWeight} kg'
                                : ''
                            : widget.exercise.bestReps != null
                                ? '${Helper.loadTranslation(context, 'bestReps')}: ${widget.exercise.bestReps}'
                                : '',
                        style: const TextStyle(color: Colors.white))),
              ),
            ],
          ),
          tempColumn
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startingRecord = widget.startingRecord;
    if (startingRecord != null) {
      var rwr = startingRecord!.sets;
      log(rwr.length.toString());
      for (int i = 0; i < rwr.length; i++) {
        String initialReps = rwr[i].reps.toString();
        String initialWeight = rwr[i].weight.toString();
        String initialRpe = rwr[i].rpe.toString();
        if (initialReps == '-1') {
          initialReps = '';
        }
        if (initialWeight == '-1.0') {
          initialWeight = '';
        }
        if (initialRpe == '-1') {
          initialRpe = '';
        }
        widget.repsControllers[i].text = initialReps;
        widget.weightControllers[i].text = initialWeight;
        widget.rpeControllers[i].text = initialRpe;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildExercise();
  }
}
