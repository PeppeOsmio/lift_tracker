import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/excercise.dart';

class NewWorkout extends StatefulWidget {
  const NewWorkout({Key? key}) : super(key: key);

  @override
  _NewWorkoutState createState() => _NewWorkoutState();
}

class _NewWorkoutState extends State<NewWorkout> {
  List<ExcerciseListItem> excerciseWidgets = [];
  List<Excercise> data = [];
  TextEditingController workoutName = TextEditingController();

  @override
  void initState() {
    super.initState();
    excerciseWidgets.add(ExcerciseListItem(1));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> temp = [];

    for (int i = 0; i < excerciseWidgets.length; i++) {
      temp.add(Stack(
        children: [
          Positioned(top: 0, right: 0, child: deleteExcerciseButton(i)),
          excerciseWidgets[i]
        ],
      ));
    }
    return Material(
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color.fromARGB(255, 20, 20, 20),
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Material(
                    color: const Color.fromARGB(255, 31, 31, 31),
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
                            child: const Icon(Icons.chevron_left_outlined))),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Text(
                      "New workout",
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: const Color.fromARGB(255, 31, 31, 31),
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                        height: 35,
                        width: 35,
                        child: InkWell(
                            radius: 17.5,
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              List<Excercise> excercises = [];
                              for (int i = 0;
                                  i < excerciseWidgets.length;
                                  i++) {
                                var excerciseWidget = excerciseWidgets[i];
                                excercises.add(Excercise(
                                    i,
                                    excerciseWidget.name,
                                    int.parse(excerciseWidget.sets),
                                    int.parse(excerciseWidget.reps)));
                                print(excerciseWidget.name);
                              }
                              CustomDatabase.instance
                                  .createWorkout(workoutName.text, excercises)
                                  .then((value) {
                                Navigator.pop(context);
                              });
                            },
                            child: const Icon(Icons.check_outlined))),
                  )
                ],
              ),
            ),
            toolbarHeight: 79,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 48, left: 24, right: 24, bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Workout name",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 31, 31, 31),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: TextField(
                        controller: workoutName,
                        decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: "Chest, Legs...",
                            border: InputBorder.none),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(mainAxisSize: MainAxisSize.min, children: temp),
                  addExcerciseButton()
                ],
              ),
            ),
          )),
    );
  }

  Widget deleteExcerciseButton(int num) {
    return Material(
        color: Colors.red, //const Color.fromARGB(255, 31, 31, 31),
        borderRadius: BorderRadius.circular(17.5),
        child: SizedBox(
            child: InkWell(
                radius: 17.5,
                borderRadius: BorderRadius.circular(10),
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
                ))));
  }

  Widget addExcerciseButton() {
    return Center(
        child: SizedBox(
            height: 65,
            width: 65,
            child: FloatingActionButton(
              onPressed: () {
                var excerciseElement =
                    excerciseWidgets[excerciseWidgets.length - 1];
                if (excerciseElement.name != "" &&
                    excerciseElement.sets != "" &&
                    excerciseElement.reps != "") {
                  excerciseWidgets
                      .add(ExcerciseListItem(excerciseWidgets.length + 1));
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

class ExcerciseListItem extends StatefulWidget {
  ExcerciseListItem(this.excerciseNumber, {Key? key}) : super(key: key);
  int excerciseNumber;
  int get number => excerciseNumber;
  set exNumber(int num) => excerciseNumber = num;
  final TextEditingController nameController = TextEditingController();
  String get name => nameController.text;
  final TextEditingController setsController = TextEditingController();
  String get sets => setsController.text;
  final TextEditingController repsController = TextEditingController();
  String get reps => repsController.text;

  @override
  _ExcerciseListItemState createState() => _ExcerciseListItemState();
}

class _ExcerciseListItemState extends State<ExcerciseListItem> {
  String a = "c";
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Excercise ${widget.excerciseNumber}",
                style: const TextStyle(fontSize: 20, color: Colors.white)),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 24),
        Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 31, 31, 31),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: TextFormField(
              controller: widget.nameController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Colors.grey),
                hintText: "Excercise name",
                border: InputBorder.none,
              ),
            )),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                width: MediaQuery.of(context).size.width / 2 - 32,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 31, 31, 31),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  controller: widget.setsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey),
                    hintText: "Sets",
                    border: InputBorder.none,
                  ),
                )),
            const Spacer(),
            Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                width: MediaQuery.of(context).size.width / 2 - 32,
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
                      hintText: "Reps",
                      border: InputBorder.none,
                    )))
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
