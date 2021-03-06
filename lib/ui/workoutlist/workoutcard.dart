import 'package:flutter/material.dart';
import 'package:lift_tracker/data/classes/workout.dart';

import '../../data/helper.dart';
import '../styles.dart';

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
      String name = exercises[i].exerciseData.name;
      exc.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(Helper.loadTranslation(context, name),
                    style: Styles.style(fontSize: 15, dark: true)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                    exercises[i].sets.toString() +
                        '  ×  ' +
                        exercises[i].reps.toString(),
                    style: Styles.style(fontSize: 15, dark: true)),
              ),
            ],
          )));
    }
    if (!isOpen && exercises.length > 5) {
      exc.add(Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Text('...', style: Styles.style(fontSize: 15, dark: true)),
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
              boxShadow: [
                BoxShadow(
                    color: Colors.black,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(1.0, 1.0)),
              ],
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
                            style: Styles.style(dark: true, fontSize: 24)),
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
