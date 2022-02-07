import 'package:flutter/material.dart';
import 'package:lift_tracker/data/workout.dart';

import 'colors.dart';

class WorkoutCard extends StatefulWidget {
  const WorkoutCard(
      this.workout, this.onLongPress, this.removeMode, this.startAsClosed,
      {Key? key})
      : super(key: key);

  final Workout workout;
  final void Function(bool) onLongPress;
  final bool removeMode;
  final bool startAsClosed;
  Duration get expandDuration =>
      Duration(milliseconds: 100 + (workout.excercises.length - 2) * 40);

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  bool isOpen = false;
  bool isButtonPressed = false;
  late bool _removeMode;
  late Duration expandDuration;

  @override
  void initState() {
    super.initState();
    expandDuration = Duration(
        milliseconds: 100 + (widget.workout.excercises.length - 2) * 40);
    _removeMode = widget.removeMode;
    if (_removeMode == true && widget.startAsClosed) {
      Future.delayed(const Duration(seconds: 0), () {
        isOpen = true;
        setState(() {});
        Future.delayed(expandDuration, () {
          Scrollable.ensureVisible(context,
              alignment: 1, duration: const Duration(milliseconds: 200));
        });
      });
    } else if (_removeMode) {
      //without the setState
      isOpen = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var excercises = widget.workout.excercises;
    List<Widget> exc = [];
    int stop;
    if (isOpen) {
      stop = excercises.length;
    } else {
      stop = 1;
    }
    if (excercises.length <= 2) {
      stop = excercises.length;
    }
    for (int i = 0; i < stop; i++) {
      String name = excercises[i].name;
      if (excercises[i].type != null) {
        name += " (${excercises[i].type!})";
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
                    excercises[i].sets.toString() +
                        "  ×  " +
                        excercises[i].reps.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ],
          )));
    }
    if (!isOpen && excercises.length > 2) {
      exc.add(const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Text("...", style: TextStyle(fontSize: 15, color: Colors.white)),
      ));
    }
    return WillPopScope(
      onWillPop: () async {
        if (_removeMode && widget.startAsClosed) {
          setState(() {
            isOpen = false;
          });
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          if (!_removeMode) {
            isOpen = !isOpen;
            setState(() {});
          }
        },
        onLongPress: () {
          widget.onLongPress.call(!isOpen);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Palette.elementsDark,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: AnimatedSize(
            curve: Curves.decelerate,
            duration: expandDuration,
            reverseDuration: expandDuration,
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
                        isOpen || _removeMode
                            ? const Icon(
                                Icons.expand_less_outlined,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.expand_more_outlined,
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
