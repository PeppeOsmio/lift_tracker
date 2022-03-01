import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/excerciselistitem.dart';
import 'package:lift_tracker/ui/widgets.dart';

import 'data/constants.dart';

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
    excerciseWidgets.add(ExcerciseListItem(
      1,
      onDelete: (index) => onDelete(index),
      onMoveDown: (index) => onMoveDown(index),
      onMoveUp: (index) => onMoveUp(index),
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> temp = [];
    for (int i = 0; i < excerciseWidgets.length; i++) {
      temp.add(Padding(
        padding:
            EdgeInsets.only(bottom: i == excerciseWidgets.length - 1 ? 0 : 24),
        child: excerciseWidgets[i],
      ));
    }
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          Constants.unfocusTextFields(context);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Palette.backgroundDark,
            body: Column(
              children: [
                CustomAppBar(
                    middleText: "New workout",
                    onBack: () => Navigator.pop(context),
                    onSubmit: () => createWorkout(),
                    backButton: true,
                    submitButton: true),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 48, left: 24, bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Workout name",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 24, bottom: 24, right: 48),
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 31, 31, 31),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                controller: workoutName,
                                decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: "Chest, Legs...",
                                    border: InputBorder.none),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Column(
                              mainAxisSize: MainAxisSize.min, children: temp),
                          addExcerciseButton()
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void createWorkout() {
    if (workoutName.text.isEmpty) {
      return;
    }
    List<Excercise> excercises = [];
    for (int i = 0; i < excerciseWidgets.length; i++) {
      var excerciseWidget = excerciseWidgets[i];
      String name = excerciseWidget.name;
      String sets = excerciseWidget.sets;
      String reps = excerciseWidget.reps;
      if (name.isEmpty || sets.isEmpty || reps.isEmpty) {
        return;
      }
      excercises.add(Excercise(
          id: i, name: name, sets: int.parse(sets), reps: int.parse(reps)));
    }
    CustomDatabase.instance
        .createWorkout(workoutName.text, excercises)
        .then((value) {
      Navigator.pop(context);
    });
  }

  void onDelete(index) {
    if (excerciseWidgets.length > 1) {
      setState(() {
        excerciseWidgets.removeAt(index);
        for (int i = 0; i < excerciseWidgets.length; i++) {
          excerciseWidgets[i].exNumber = i + 1;
        }
      });
    }
  }

  void onMoveDown(index) {
    if (index == excerciseWidgets.length - 1) {
      return;
    }
    var temp = excerciseWidgets[index + 1];
    temp.exNumber = temp.excerciseNumber - 1;
    excerciseWidgets[index].exNumber =
        excerciseWidgets[index].excerciseNumber + 1;
    excerciseWidgets[index + 1] = excerciseWidgets[index];
    excerciseWidgets[index] = temp;
    setState(() {});
  }

  void onMoveUp(index) {
    if (index == 0) {
      return;
    }
    var temp = excerciseWidgets[index - 1];
    temp.exNumber = temp.excerciseNumber + 1;
    excerciseWidgets[index].exNumber =
        excerciseWidgets[index].excerciseNumber - 1;
    excerciseWidgets[index - 1] = excerciseWidgets[index];
    excerciseWidgets[index] = temp;
    setState(() {});
  }

  Widget addExcerciseButton() {
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
                  excerciseWidgets.add(ExcerciseListItem(
                    excerciseWidgets.length + 1,
                    onDelete: (index) => onDelete(index),
                    onMoveDown: (index) => onMoveDown(index),
                    onMoveUp: (index) => onMoveUp(index),
                  ));
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
