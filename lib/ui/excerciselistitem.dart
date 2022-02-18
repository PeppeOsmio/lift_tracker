import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/excercise.dart';
import 'colors.dart';

class ExcerciseListItem extends StatefulWidget {
  ExcerciseListItem(this.excerciseNumber,
      {required this.onDelete,
      this.onMoveUp,
      this.onMoveDown,
      this.initialExcercise,
      Key? key})
      : super(key: key);
  int excerciseNumber;
  int get number => excerciseNumber;
  set exNumber(int num) => excerciseNumber = num;
  final TextEditingController nameController = TextEditingController();
  String get name => nameController.text;
  final TextEditingController setsController = TextEditingController();
  String get sets => setsController.text;
  final TextEditingController repsController = TextEditingController();
  String get reps => repsController.text;
  final Function(int index) onDelete;
  final Function(int index)? onMoveUp;
  final Function(int index)? onMoveDown;
  final Excercise? initialExcercise;

  @override
  _ExcerciseListItemState createState() => _ExcerciseListItemState();
}

class _ExcerciseListItemState extends State<ExcerciseListItem> {
  String a = "c";

  @override
  void initState() {
    super.initState();
    if (widget.initialExcercise != null) {
      widget.nameController.text = widget.initialExcercise!.name;
      widget.setsController.text = widget.initialExcercise!.sets.toString();
      widget.repsController.text = widget.initialExcercise!.reps.toString();
    }
  }

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
            excerciseButton(
                onTap: () {
                  if (widget.onMoveUp != null) {
                    widget.onMoveUp!.call(widget.excerciseNumber - 1);
                  }
                },
                color: Palette.elementsDark,
                icon: Icons.expand_less_outlined),
            const SizedBox(width: 16),
            excerciseButton(
                onTap: () {
                  if (widget.onMoveDown != null) {
                    widget.onMoveDown!.call(widget.excerciseNumber - 1);
                  }
                },
                color: Palette.elementsDark,
                icon: Icons.expand_more_outlined),
            const SizedBox(width: 16),
            excerciseButton(
                onTap: () => widget.onDelete(widget.excerciseNumber - 1),
                color: Colors.red,
                icon: Icons.remove_outlined)
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

  Widget excerciseButton(
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
