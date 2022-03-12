import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/exercise.dart';
import 'colors.dart';

class ExerciseListItem extends StatefulWidget {
  ExerciseListItem(this.exerciseNumber,
      {required this.onDelete,
      this.onMoveUp,
      this.onMoveDown,
      this.initialExercise,
      Key? key})
      : super(key: key);
  int exerciseNumber;
  int get number => exerciseNumber;
  set exNumber(int num) => exerciseNumber = num;
  final TextEditingController nameController = TextEditingController();
  String get name => nameController.text;
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
  String a = "c";

  @override
  void initState() {
    super.initState();
    if (widget.initialExercise != null) {
      widget.nameController.text = widget.initialExercise!.name;
      widget.setsController.text = widget.initialExercise!.sets.toString();
      widget.repsController.text = widget.initialExercise!.reps.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Container(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          //width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 31, 31, 31),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: TextFormField(
                            controller: widget.nameController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: "Exercise name",
                              border: InputBorder.none,
                            ),
                          )),
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
                              hintText: "Sets",
                              border: InputBorder.none,
                            ),
                          )),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "×",
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
                                hintText: "Reps",
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
