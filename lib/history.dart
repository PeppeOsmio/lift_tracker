import 'package:flutter/material.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/data/excerciserecord.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/ui/colors.dart';

import 'data/workoutrecord.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.search_outlined,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  )),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: WorkoutRecordCard(
                      WorkoutRecord(
                          DateTime.parse("2022-02-02"),
                          Workout(0, "Push 1", [Excercise(0, "Panca", 4, 10)]),
                          [
                            ExcerciseRecord(Excercise(0, "Panca", 4, 10), [
                              {"reps": 10, "weight": 69}
                            ])
                          ]),
                      () {},
                      false)),
            ]),
          ),
        ],
      ),
    );
  }
}

class WorkoutRecordCard extends StatefulWidget {
  const WorkoutRecordCard(this.workoutRecord, this.onPressed, this.removeMode,
      {Key? key})
      : super(key: key);

  final WorkoutRecord workoutRecord;
  final void Function() onPressed;
  final bool removeMode;
  Duration get expandDuration => Duration(
      milliseconds: 100 + (workoutRecord.excerciseRecords.length - 5) * 40);

  @override
  _WorkoutRecordCardState createState() => _WorkoutRecordCardState();
}

class _WorkoutRecordCardState extends State<WorkoutRecordCard> {
  bool isOpen = false;
  bool isButtonPressed = false;
  late bool _removeMode;
  late Duration expandDuration;

  @override
  void initState() {
    super.initState();
    expandDuration = Duration(
        milliseconds:
            100 + (widget.workoutRecord.excerciseRecords.length - 5) * 20);
    _removeMode = widget.removeMode;
    if (_removeMode == true) {
      Future.delayed(Duration.zero, () {
        isOpen = true;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var excercises = widget.workoutRecord.excerciseRecords;
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

    return WillPopScope(
      onWillPop: () async {
        if (_removeMode) {
          setState(() {
            isOpen = false;
          });
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          widget.onPressed.call();
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Palette.orange,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Wednesday, Februrary 2",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        const Spacer(),
                        Icon(
                          isOpen
                              ? Icons.expand_less_outlined
                              : Icons.expand_more_outlined,
                          color: Colors.white,
                        )
                      ]),
                    ),
                    Row(
                      children: [
                        Text(widget.workoutRecord.workout.name,
                            style: const TextStyle(
                                fontSize: 24, color: Colors.white)),
                        const Spacer(),
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
