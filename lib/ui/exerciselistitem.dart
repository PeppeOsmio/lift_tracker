import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/ui/selectexercise.dart';
import '../data/classes/exercise.dart';
import 'colors.dart';
import 'package:lift_tracker/localizations.dart';

class ExerciseListItem extends StatefulWidget {
  ExerciseListItem(this.exerciseNumber,
      {required this.onDelete,
      this.onMoveUp,
      this.onMoveDown,
      this.initialExercise,
      this.exerciseData,
      Key? key})
      : super(key: key);
  ExerciseData? exerciseData;
  int exerciseNumber;
  int get number => exerciseNumber;
  String get type {
    if (exerciseData == null) {
      return '';
    } else {
      return exerciseData!.type;
    }
  }

  String get name {
    if (exerciseData == null) {
      return '';
    } else {
      return exerciseData!.name;
    }
  }

  String get jsonId {
    if (exerciseData == null) {
      return '';
    } else {
      return exerciseData!.id.toString();
    }
  }

  set exNumber(int num) => exerciseNumber = num;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  String get sets => setsController.text;
  final TextEditingController repsController = TextEditingController();
  String get reps => repsController.text;
  final Function(int index) onDelete;
  final Function(int index)? onMoveUp;
  final Function(int index)? onMoveDown;
  final Exercise? initialExercise;

  @override
  _ExerciseListItemState createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {
  ExerciseData? exerciseData;

  @override
  void initState() {
    super.initState();
    if (widget.initialExercise != null) {
      widget.exerciseData = ExerciseData(
          id: widget.initialExercise!.jsonId,
          name: widget.initialExercise!.name,
          type: widget.initialExercise!.type);
      widget.nameController.text = widget.initialExercise!.name;
      widget.setsController.text = widget.initialExercise!.sets.toString();
      widget.repsController.text = widget.initialExercise!.reps.toString();
    }
    exerciseData = widget.exerciseData;
  }

  @override
  Widget build(BuildContext context) {
    if (exerciseData != null) {
      widget.nameController.text =
          Helper.loadTranslation(context, exerciseData!.name);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          log('tap');
                          var result = await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return SelectExercise();
                          }));
                          if (result != null) {
                            exerciseData = result;
                            widget.exerciseData = result;
                            setState(() {});
                          }
                        },
                        child: Container(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            //width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 31, 31, 31),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: IgnorePointer(
                              child: TextFormField(
                                readOnly: true,
                                controller: widget.nameController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                decoration: const InputDecoration(
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Select exercise...',
                                  border: InputBorder.none,
                                ),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          //width: MediaQuery.of(context).size.width / 2 - 32,
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 31, 31, 31),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            controller: widget.setsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: 'Sets',
                              border: InputBorder.none,
                            ),
                          )),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '×',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          //width: MediaQuery.of(context).size.width / 2 - 32,
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 31, 31, 31),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              controller: widget.repsController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Reps',
                                border: InputBorder.none,
                              ))),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    exerciseButton(
                        onTap: () {
                          if (widget.onMoveUp != null) {
                            widget.onMoveUp!.call(widget.exerciseNumber - 1);
                          }
                        },
                        color: Palette.elementsDark,
                        icon: Icons.expand_less_outlined),
                    const SizedBox(height: 16),
                    exerciseButton(
                        onTap: () {
                          if (widget.onMoveDown != null) {
                            widget.onMoveDown!.call(widget.exerciseNumber - 1);
                          }
                        },
                        color: Palette.elementsDark,
                        icon: Icons.expand_more_outlined),
                    const SizedBox(height: 16),
                    exerciseButton(
                        onTap: () => widget.onDelete(widget.exerciseNumber - 1),
                        color: Colors.red,
                        icon: Icons.remove_outlined),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget exerciseButton(
      {required Function() onTap,
      required Color color,
      required IconData icon}) {
    return Container(
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(17)),
        child: GestureDetector(
          onTap: onTap,
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ));
  }
}
