import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import '../styles.dart';

class ExerciseListItem extends StatefulWidget {
  const ExerciseListItem(
      {required this.onDelete,
      this.onMoveUp,
      this.onMoveDown,
      required this.onNameFieldPress,
      required this.repsController,
      required this.nameController,
      required this.setsController,
      Key? key})
      : super(key: key);

  final TextEditingController nameController;
  final TextEditingController setsController;
  String get sets => setsController.text;
  final TextEditingController repsController;
  String get reps => repsController.text;
  final Function onDelete;
  final Function? onMoveUp;
  final Function? onMoveDown;
  final Function onNameFieldPress;

  @override
  _ExerciseListItemState createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {
  ExerciseData? exerciseData;

  @override
  void initState() {
    super.initState();
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
                      child: GestureDetector(
                        onTap: () {
                          widget.onNameFieldPress();
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
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: Helper.loadTranslation(
                                      context, 'selectExercise'),
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
                            decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText:
                                  Helper.loadTranslation(context, 'setsField'),
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
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText:
                                    Helper.loadTranslation(context, 'reps'),
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
                            widget.onMoveUp!.call();
                          }
                        },
                        color: Palette.elementsDark,
                        icon: Icons.expand_less_outlined),
                    const SizedBox(height: 16),
                    exerciseButton(
                        onTap: () {
                          if (widget.onMoveDown != null) {
                            widget.onMoveDown!.call();
                          }
                        },
                        color: Palette.elementsDark,
                        icon: Icons.expand_more_outlined),
                    const SizedBox(height: 16),
                    exerciseButton(
                        onTap: () => widget.onDelete(),
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
