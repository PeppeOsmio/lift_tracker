import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      home: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Palette.backgroundDark,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Palette.backgroundDark,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 16),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      widget.workout.name + " session",
                    ),
                  ),
                  const Spacer(),
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
                              Constants.didUpdateHistory = true;
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.check_outlined,
                              color: Colors.green,
                            ))),
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 0, right: 0, bottom: 0),
            child: ListView(
              children: items,
            ),
          )),
    );
  }

  WorkoutRecord getWorkoutRecord() {
    List<ExcerciseRecord> records = [];
    for (int i = 0; i < widget.workout.excercises.length; i++) {
      records.add(ExcerciseRecord(
          widget.workout.excercises[i].name, records[i].reps_weight_rpe));
    }
    return WorkoutRecord(DateTime.now(), widget.workout.name, records);
  }
}

class SetRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                  padding: const EdgeInsets.only(left: 8),
                  width: (width - 32) / 10,
                  child: Text(
                    "$rowIndex",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    width: (width - 32) / 4,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 31, 31, 31),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: TextFormField(
                      controller: repsController,
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
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Container(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    width: (width - 32) / 4,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 31, 31, 31),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: "Weight",
                        border: InputBorder.none,
                      ),
                    )),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Container(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    width: (width - 32) / 4,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 31, 31, 31),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        controller: rpeController,
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
        const SizedBox(height: 24),
      ],
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
  ExcerciseRecord get excerciseRecord {
    List<Map<String, dynamic>> listMap = [];
    for (int i = 0; i < excercise.sets; i++) {
      listMap.add({
        "reps": int.parse(repsControllers[i].text),
        "weight": double.parse(weightControllers[i].text),
        "rpe": int.parse(rpeControllers[i].text)
      });
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
    temp.add(buildAddSetButton());
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
              SizedBox(
                width: (width - 32) / 10 + 8,
                child: const Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Text(
                      "Set",
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(
                width: (width - 32) / 4 + 8,
                child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Text(
                      "Reps goal: ${widget.excercise.reps}",
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              const Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 24, left: 8),
                  child: Text(
                    "Weight record: N/A",
                    style: TextStyle(color: Colors.white),
                  )),
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
