import 'package:flutter/material.dart';
import 'package:lift_tracker/data/workout.dart';

import '../../data/helper.dart';
import '../colors.dart';

class WorkoutCard extends StatefulWidget {
  const WorkoutCard(this.workout, this.onLongPress, this.removeMode, {Key? key})
      : super(key: key);

  final Workout workout;
  final Future Function(bool) onLongPress;
  final bool removeMode;
  Duration get expandDuration =>
      Duration(milliseconds: 100 + (workout.exercises.length - 5) * 40);

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  bool isOpen = false;
  bool isButtonPressed = false;
  late bool _removeMode;
  late Duration expandDuration;
  bool offstage = false;

  @override
  void initState() {
    super.initState();
    expandDuration = Duration(
        milliseconds: 100 + (widget.workout.exercises.length - 5) * 20);
    _removeMode = widget.removeMode;
    if (_removeMode == true) {
      Future.delayed(const Duration(seconds: 0), () {
        isOpen = true;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var exercises = widget.workout.exercises;
    List<Widget> exc = [];
    int stop;
    if (isOpen) {
      stop = exercises.length;
    } else {
      stop = 4;
    }
    if (exercises.length <= 5) {
      stop = exercises.length;
    }
    for (int i = 0; i < stop; i++) {
      String name = exercises[i].name;
      if (exercises[i].type != null) {
        name += " (${exercises[i].type!})";
      }
      exc.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(name,
                    style: const TextStyle(fontSize: 15, color: Colors.white)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                    exercises[i].sets.toString() +
                        "  ×  " +
                        exercises[i].reps.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ],
          )));
    }
    if (!isOpen && exercises.length > 5) {
      exc.add(const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Text("...", style: TextStyle(fontSize: 15, color: Colors.white)),
      ));
    }
    return WillPopScope(
      onWillPop: () async {
        if (_removeMode) {}
        return true;
      },
      child: GestureDetector(
        onTap: () async {
          if (!_removeMode) {
            setState(() {
              offstage = true;
            });
            Helper.unfocusTextFields(context);
            await widget.onLongPress.call(!isOpen);
            Future.delayed(const Duration(milliseconds: 150), () {
              setState(() {
                offstage = false;
              });
            });
          }
        },
        child: Visibility(
          visible: !offstage,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Container(
            decoration: BoxDecoration(
              color: Palette.elementsDark,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.workout.name,
                            style: const TextStyle(
                                fontSize: 24, color: Colors.white)),
                        const Spacer(),
                        _removeMode
                            ? InkWell(
                                borderRadius: BorderRadius.circular(20),
                                radius: 20,
                                onTap: () => Navigator.maybePop(context),
                                child: Icon(
                                  isOpen
                                      ? Icons.expand_less_outlined
                                      : Icons.expand_more_outlined,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isOpen
                                    ? Icons.expand_less_outlined
                                    : Icons.expand_more_outlined,
                                color: Colors.white,
                              )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: exc),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
