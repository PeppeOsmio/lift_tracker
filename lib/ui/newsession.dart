import 'dart:developer' as dev;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/exercise.dart';
import 'package:lift_tracker/data/exerciserecord.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/data/workoutrecord.dart';
import 'package:lift_tracker/ui/colors.dart';
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
  List<Widget> items = [];
  late SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    //remove cached sessions
    SharedPreferences.getInstance().then((value) async {
      pref = value;
      CustomDatabase.instance.removeCachedSession();
    });

    for (int i = 0; i < widget.workout.exercises.length; i++) {
      List<TextEditingController> repsControllers = [];
      List<TextEditingController> weightControllers = [];
      List<TextEditingController> rpeControllers = [];

      for (int j = 0; j < widget.workout.exercises[i].sets; j++) {
        repsControllers.add(TextEditingController());
        weightControllers.add(TextEditingController());
        rpeControllers.add(TextEditingController());
      }

      records.add(ExerciseRecordItem(
        widget.workout.exercises[i],
        repsControllers: repsControllers,
        weightControllers: weightControllers,
        rpeControllers: rpeControllers,
        nameController: TextEditingController(),
        onEditItem: () {},
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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        home: SafeArea(
          child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Palette.backgroundDark,
              body: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    CustomAppBar(
                        middleText: "New ${widget.workout.name} session",
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
                          itemBuilder: (context, index) {
                            return items[index];
                          },
                          itemCount: items.length,
                        ),
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
          .addWorkoutRecord(workoutRecord!, widget.workout, cacheMode: true);
      return;
    }

    // create regular session
    try {
      workoutRecord = getWorkoutRecord();
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Fill all fields");
      return;
    }
    if (workoutRecord == null) {
      await showDimmedBackgroundDialog(context,
          rightText: 'Cancel',
          leftText: 'Yes',
          rightOnPressed: () => Navigator.maybePop(context),
          leftOnPressed: () {
            Navigator.pop(context);
            Navigator.maybePop(context);
            Fluttertoast.showToast(msg: "Session canceled");
          },
          title: 'Cancel this session?',
          content: 'Some sets are empty. Press Yes to cancel this session');
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
      await showDimmedBackgroundDialog(context,
          leftText: 'Yes', rightText: 'Cancel', leftOnPressed: () {
        Navigator.pop(context);
        Navigator.maybePop(context);
        Fluttertoast.showToast(msg: "Session canceled");
      }, rightOnPressed: () {
        Navigator.maybePop(context);
      },
          title: 'Cancel this session?',
          content: 'Some sets are empty. Press Yes to cancel this session');
    }

    ref.read(Helper.workoutRecordsProvider.notifier).refreshWorkoutRecords();
    Navigator.pop(context);
  }

  WorkoutRecord? getWorkoutRecord({bool cacheMode = false}) {
    if (cacheMode) {
      List<ExerciseRecord> worecords = [];
      for (int i = 0; i < widget.workout.exercises.length; i++) {
        ExerciseRecord exerciseRecord;
        exerciseRecord = records[i].cacheExerciseRecord;

        worecords.add(exerciseRecord);
      }
      List<ExerciseRecord> temp = [];
      for (int j = 0; j < worecords.length; j++) {
        ExerciseRecord record = worecords[j];
        temp.add(record);
      }
      return WorkoutRecord(0, DateTime.now(), widget.workout.name, temp,
          workoutId: widget.workout.id);
    }
    List<ExerciseRecord?> worecords = [];
    for (int i = 0; i < widget.workout.exercises.length; i++) {
      ExerciseRecord? exerciseRecord;
      try {
        exerciseRecord = records[i].exerciseRecord;
      } catch (e) {
        print(e);
        throw Exception();
      }
      if (exerciseRecord == null) {
        return null;
      }
      worecords.add(exerciseRecord);
    }
    List<ExerciseRecord> temp = [];
    for (int j = 0; j < worecords.length; j++) {
      ExerciseRecord? record = worecords[j];
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
      //then save didCacheSession as true
      await pref.setBool('didFailCache', false);
      await pref.setBool('didCacheSession', true);
    }
  }
}

class SetRow extends StatefulWidget {
  const SetRow(this.rowIndex,
      {required this.repsController,
      required this.weightController,
      required this.rpeController,
      Key? key})
      : super(key: key);
  final int rowIndex;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final TextEditingController rpeController;

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
                    "${widget.rowIndex}",
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
                      hintText: "Reps",
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
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: "Kg",
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
                        if (text != "" && int.parse(text) > 10) {
                          widget.rpeController.text = "10";
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
                        hintText: "Rpe",
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
  ExerciseRecordItem(this.exercise,
      {required this.repsControllers,
      required this.weightControllers,
      required this.rpeControllers,
      required this.nameController,
      required this.onEditItem,
      this.startingRecord,
      Key? key})
      : super(key: key);
  final void Function() onEditItem;
  final Exercise exercise;
  final ExerciseRecord? startingRecord;
  final TextEditingController nameController;
  List<TextEditingController> repsControllers;
  List<TextEditingController> weightControllers;
  List<TextEditingController> rpeControllers;
  ExerciseRecord? get exerciseRecord {
    List<Map<String, dynamic>> listMap = [];
    for (int i = 0; i < exercise.sets; i++) {
      String reps = repsControllers[i].text;
      String weight = weightControllers[i].text;
      String rpe = rpeControllers[i].text;
      String name = nameController.text;
      if (name.isEmpty) {
        throw Exception('missing_name');
      }
      if (reps.isEmpty || weight.isEmpty) {
        return null;
      }
      if (rpe.isEmpty || int.parse(rpe) > 10) {
        rpe = '10';
      }
      if (reps != "0") {
        listMap.add({
          "reps": int.parse(reps),
          "weight": double.parse(weight),
          "rpe": int.parse(rpe),
          "hasRecord": 0
        });
      }
    }
    return ExerciseRecord(nameController.text, listMap,
        exerciseId: exercise.id);
  }

  ExerciseRecord get cacheExerciseRecord {
    List<Map<String, dynamic>> listMap = [];
    String name = nameController.text;
    for (int i = 0; i < exercise.sets; i++) {
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
      listMap.add({
        "reps": int.parse(reps),
        "weight": double.parse(weight),
        "rpe": int.parse(rpe),
        "hasRecord": 0
      });
    }
    if (name.isEmpty) {
      name = exercise.name;
    }
    return ExerciseRecord(name, listMap, exerciseId: exercise.id);
  }

  @override
  _ExerciseRecordItemState createState() => _ExerciseRecordItemState();
}

class _ExerciseRecordItemState extends State<ExerciseRecordItem>
    with AutomaticKeepAliveClientMixin {
  FocusNode focusNode = FocusNode();
  ExerciseRecord? startingRecord;

  Widget buildAddSetButton() {
    return Center(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: const EdgeInsets.all(8),
      child: InkWell(
        child: Material(
          borderRadius: BorderRadius.circular(10),
          color: Palette.elementsDark,
          type: MaterialType.transparency,
          child: Row(
            children: const [
              Icon(
                Icons.add_outlined,
                color: Colors.white,
              ),
              Spacer(),
              Text(
                "Add set",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: Palette.elementsDark,
        borderRadius: BorderRadius.circular(10),
      ),
    ));
  }

  Widget buildExercise() {
    double width = MediaQuery.of(context).size.width;
    List<Widget> temp = [];
    for (int i = 0; i < widget.exercise.sets; i++) {
      temp.add(SetRow(i + 1,
          repsController: widget.repsControllers[i],
          weightController: widget.weightControllers[i],
          rpeController: widget.rpeControllers[i]));
    }
    //temp.add(buildAddSetButton());
    //temp.add(const SizedBox(height: 24));
    Column tempColumn = Column(children: temp);
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              focusNode.requestFocus();
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 28),
                IntrinsicWidth(
                  child: TextField(
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: "Name",
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    controller: widget.nameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Expanded(
                flex: 2,
                child: Padding(
                    padding: EdgeInsets.only(top: 24, bottom: 24),
                    child: Text(
                      "Set",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Text(
                      "Reps goal: ${widget.exercise.reps}",
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              Expanded(
                flex: 10,
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 24, bottom: 24, left: 8),
                    child: Text(
                      widget.exercise.weightRecord != null
                          ? "Best weight: ${widget.exercise.weightRecord} kg"
                          : "",
                      style: const TextStyle(color: Colors.white),
                    )),
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
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.nameController.text = widget.exercise.name;
    startingRecord = widget.startingRecord;
    if (startingRecord != null) {
      var rwr = startingRecord!.reps_weight_rpe;
      for (int i = 0; i < rwr.length; i++) {
        String initialReps = rwr[i]['reps'].toString();
        String initialWeight = rwr[i]['weight'].toString();
        String initialRpe = rwr[i]['rpe'].toString();
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
      widget.nameController.text = startingRecord!.exerciseName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildExercise();
  }

  @override
  bool get wantKeepAlive => false;
}
