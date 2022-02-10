import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/ui/colors.dart';

class NewSession extends StatefulWidget {
  const NewSession(this.workout, {Key? key}) : super(key: key);
  final Workout workout;

  @override
  _NewSessionState createState() => _NewSessionState();
}

class _NewSessionState extends State<NewSession> {
  List<ExcerciseRecordItem> excerciseWidgets = [];
  List<Excercise> data = [];
  TextEditingController repsController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController rpeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> temp = [];

    for (int i = 0; i < widget.workout.excercises.length; i++) {
      temp.add(ExcerciseRecordItem(widget.workout.excercises[i],
          repsController: repsController,
          weightController: weightController,
          rpeController: rpeController));
    }
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
                ],
              ),
            ),
            toolbarHeight: 79,
          ),
          body: Padding(
            padding:
                const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 0),
            child: ListView(
              children: temp,
            ),
          )),
    );
  }

  /*Widget deleteExcerciseButton(int num) {
    return Material(
        color: Colors.red, //const Color.fromARGB(255, 31, 31, 31),
        borderRadius: BorderRadius.circular(17.5),
        child: SizedBox(
            child: GestureDetector(
          onTap: () {
            if (excerciseWidgets.length > 1) {
              setState(() {
                excerciseWidgets.removeAt(num);
                for (int i = 0; i < excerciseWidgets.length; i++) {
                  excerciseWidgets[i].exNumber = i + 1;
                }
              });
            }
          },
          child: const Icon(
            Icons.remove_outlined,
            color: Colors.white,
          ),
        )));
  }*/

  /*Widget addExcerciseButton() {
    return Center(
        child: SizedBox(
            height: 65,
            width: 65,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                var excerciseElement =
                    excerciseWidgets[excerciseWidgets.length - 1];
                if (excerciseElement.name != "" &&
                    excerciseElement.sets != "" &&
                    excerciseElement.reps != "") {
                  excerciseWidgets
                      .add(ExcerciseRecordItem(excerciseWidgets.length + 1));
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
  }*/
}

class ExcerciseRecordItem extends StatefulWidget {
  const ExcerciseRecordItem(this.excercise,
      {required this.repsController,
      required this.weightController,
      required this.rpeController,
      Key? key})
      : super(key: key);
  final Excercise excercise;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final TextEditingController rpeController;

  @override
  _ExcerciseRecordItemState createState() => _ExcerciseRecordItemState();
}

class _ExcerciseRecordItemState extends State<ExcerciseRecordItem> {
  Widget buildSetRow() {
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
                  child: TextFormField(
                    controller: widget.repsController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: "1",
                      border: InputBorder.none,
                    ),
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
                      controller: widget.weightController,
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
                        controller: widget.repsController,
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

  Widget buildExcercise() {
    double width = MediaQuery.of(context).size.width;
    List<Widget> temp = [];
    for (int i = 0; i < widget.excercise.sets; i++) {
      temp.add(buildSetRow());
    }

    Column tempColumn = Column(children: temp);
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
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
                      "Reps goal: ${widget.excercise.sets}",
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24, left: 8),
                  child: Text(
                    "Weight goal: ${widget.excercise.reps}",
                    style: const TextStyle(color: Colors.white),
                  )),
            ],
          ),
          tempColumn
        ],
      ),
    );
  }

  late TextEditingController repsController;
  late TextEditingController weightController;
  late TextEditingController rpeController;

  @override
  void initState() {
    super.initState();
    repsController = widget.repsController;
    weightController = widget.weightController;
    rpeController = widget.rpeController;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> temp = [];
    print(widget.excercise.sets);
    for (int i = 0; i < widget.excercise.sets; i++) {
      temp.add(buildExcercise());
    }
    return Column(mainAxisSize: MainAxisSize.min, children: temp);
  }
}
