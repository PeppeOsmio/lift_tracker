import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/app.dart';
import 'package:lift_tracker/data/constants.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/data/excerciserecord.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/data/workoutrecord.dart';
import 'package:lift_tracker/history.dart';
import 'package:lift_tracker/ui/colors.dart';

class NewSession extends StatefulWidget {
  const NewSession(this.workout, {Key? key}) : super(key: key);
  final Workout workout;

  @override
  _NewSessionState createState() => _NewSessionState();
}

class _NewSessionState extends State<NewSession> {
  List<ExcerciseRecordItem> records = [];
  List<Excercise> data = [];
  List<Widget> items = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.workout.excercises.length; i++) {
      List<TextEditingController> repsControllers = [];
      List<TextEditingController> weightControllers = [];
      List<TextEditingController> rpeControllers = [];

      for (int j = 0; j < widget.workout.excercises[i].sets; j++) {
        repsControllers.add(TextEditingController());
        weightControllers.add(TextEditingController());
        rpeControllers.add(TextEditingController());
      }

      records.add(ExcerciseRecordItem(widget.workout.excercises[i],
          repsControllers: repsControllers,
          weightControllers: weightControllers,
          rpeControllers: rpeControllers));

      items.add(Padding(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: records[i],
      ));
    }
    items.add(const SizedBox(height: 24));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Palette.backgroundDark,
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Row(
                      children: [
                        Material(
                          color: Palette.elementsDark,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                              height: 35,
                              width: 35,
                              child: InkWell(
                                  radius: 17.5,
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(
                                    Icons.chevron_left_outlined,
                                    color: Colors.redAccent,
                                  ))),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Text(
                              "New " + widget.workout.name + " session",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        Material(
                          color: Palette.elementsDark,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                              height: 35,
                              width: 35,
                              child: InkWell(
                                  radius: 17.5,
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: createWorkoutSession,
                                  child: const Icon(
                                    Icons.check_outlined,
                                    color: Colors.green,
                                  ))),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8, left: 0, right: 0, bottom: 0),
                      child: ListView(
                        children: items,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future createWorkoutSession() async {
    WorkoutRecord? workoutRecord = getWorkoutRecord();
    if (workoutRecord == null) {
      return;
    }
    // delete all excercise records with empty sets
    // and track their indexes
    List<int> indexes = [];
    workoutRecord.excerciseRecords.removeWhere((element) {
      if (element.reps_weight_rpe.isEmpty) {
        indexes.add(workoutRecord.excerciseRecords.indexOf(element));
        return true;
      }
      return false;
    });

    // if every excercise record has been deleted, the session is not valid
    // and will not be saved
    if (workoutRecord.excerciseRecords.isEmpty) {
      Fluttertoast.showToast(msg: "Session canceled");
      Navigator.maybePop(context);
      return;
    }

    // if the session has valid excercise records, save it
    Workout workout = widget.workout;
    // from the workout schedule, delete all the excercises that were
    // not excecuted in this session
    List<Excercise> tempExcercises = workout.excercises;
    for (int i = 0; i < indexes.length; i++) {
      tempExcercises.removeAt(i);
    }

    // check if there were weight records in this session
    // among all the excercises that were excecuted
    for (int i = 0; i < tempExcercises.length; i++) {
      Excercise excercise = tempExcercises[i];
      double? previousWeightRecord = excercise.weightRecord;
      var reps_weight_rpe = workoutRecord.excerciseRecords[i].reps_weight_rpe;
      double currentMaxWeight = 0;
      int setRecordIndex = -1;
      //if there's only one set its weight is already the max weight among all sets
      if (reps_weight_rpe.length > 1) {
        for (int j = 0; j < reps_weight_rpe.length - 1; j++) {
          currentMaxWeight = reps_weight_rpe[j]['weight'];
          currentMaxWeight =
              max(currentMaxWeight, reps_weight_rpe[j + 1]['weight']);
        }
      } else {
        currentMaxWeight = reps_weight_rpe[0]['weight'];
      }
      if (previousWeightRecord != null) {
        if (currentMaxWeight > previousWeightRecord) {
          // if this weight is a record, mark the first set with this weight
          // as record
          setRecordIndex = workoutRecord.excerciseRecords[i].reps_weight_rpe
              .indexWhere((element) => element['weight'] == currentMaxWeight);
          workoutRecord.excerciseRecords[i].reps_weight_rpe[setRecordIndex]
              ['hasRecord'] = 1;
          await CustomDatabase.instance
              .setWeightRecord(excercise.id, currentMaxWeight);
          Constants.didSetWeightRecord = true;
        }
      } else {
        // if this weight is a record, mark the first set with this weight
        // as record
        setRecordIndex = workoutRecord.excerciseRecords[i].reps_weight_rpe
            .indexWhere((element) => element['weight'] == currentMaxWeight);
        workoutRecord.excerciseRecords[i].reps_weight_rpe[setRecordIndex]
            ['hasRecord'] = 1;
        await CustomDatabase.instance
            .setWeightRecord(excercise.id, currentMaxWeight);
        Constants.didSetWeightRecord = true;
      }
    }
    // save this workout session on the database
    await CustomDatabase.instance.addWorkoutRecord(workoutRecord);
    Constants.didUpdateHistory = true;
    Navigator.pop(context);
  }

  WorkoutRecord? getWorkoutRecord() {
    List<ExcerciseRecord> worecords = [];
    for (int i = 0; i < widget.workout.excercises.length; i++) {
      ExcerciseRecord? excerciseRecord;
      try {
        excerciseRecord = records[i].excerciseRecord;
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Typo in ${widget.workout.excercises[i].name}'s weight");
        return null;
      }
      if (excerciseRecord == null) {
        return null;
      }
      worecords.add(records[i].excerciseRecord!);
    }
    return WorkoutRecord(0, DateTime.now(), widget.workout.name, worecords);
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

class ExcerciseRecordItem extends StatefulWidget {
  const ExcerciseRecordItem(this.excercise,
      {required this.repsControllers,
      required this.weightControllers,
      required this.rpeControllers,
      Key? key})
      : super(key: key);
  final Excercise excercise;
  final List<TextEditingController> repsControllers;
  final List<TextEditingController> weightControllers;
  final List<TextEditingController> rpeControllers;
  ExcerciseRecord? get excerciseRecord {
    List<Map<String, dynamic>> listMap = [];
    for (int i = 0; i < excercise.sets; i++) {
      String reps = repsControllers[i].text;
      String weight = weightControllers[i].text;
      String rpe = rpeControllers[i].text;
      if (reps.isEmpty || weight.isEmpty || rpe.isEmpty) {
        return null;
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
    return ExcerciseRecord(excercise.name, listMap);
  }

  @override
  _ExcerciseRecordItemState createState() => _ExcerciseRecordItemState();
}

class _ExcerciseRecordItemState extends State<ExcerciseRecordItem> {
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

  Widget buildExcercise() {
    double width = MediaQuery.of(context).size.width;
    List<Widget> temp = [];
    for (int i = 0; i < widget.excercise.sets; i++) {
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
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.excercise.name,
                  style: const TextStyle(fontSize: 20, color: Colors.white)),
            ],
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
                      "Reps goal: ${widget.excercise.reps}",
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              Expanded(
                flex: 10,
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 24, bottom: 24, left: 8),
                    child: Text(
                      widget.excercise.weightRecord != null
                          ? "Best weight: ${widget.excercise.weightRecord} kg"
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildExcercise();
  }
}
