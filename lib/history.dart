import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lift_tracker/data/constants.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/data/excerciserecord.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/session.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/widgets.dart';

import 'data/workoutrecord.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late Future<List<WorkoutRecord>> workoutRecords;

  @override
  void initState() {
    super.initState();
    workoutRecords = CustomDatabase.instance.readWorkoutRecords();
    workoutRecords.then((value) {
      setState(() {});
    });
  }

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
          FutureBuilder(
            future: workoutRecords,
            builder: (context, ss) {
              if (ss.hasData) {
                List<WorkoutRecord> records = ss.data! as List<WorkoutRecord>;
                int length = records.length;
                return Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, i) {
                        WorkoutRecordCard workoutRecordCard = WorkoutRecordCard(
                            records[length - 1 - i], () {}, false);
                        GlobalKey key = GlobalKey();
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: WorkoutRecordCard(
                              records[length - 1 - i],
                              () {
                                MaterialPageRoute route =
                                    MaterialPageRoute(builder: (context) {
                                  return Session(records[length - 1 - i]);
                                });
                                Navigator.push(context, route);
                              },
                              false,
                              onLongPress: () {
                                Navigator.push(
                                        context,
                                        blurredMenuBuilder(
                                            workoutRecordCard, key, i))
                                    .then((value) {
                                  setState(() {});
                                });
                              }),
                          key: key,
                        );
                      },
                      separatorBuilder: (context, i) {
                        return const SizedBox();
                      },
                      itemCount: length),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  PageRouteBuilder blurredMenuBuilder(
      WorkoutRecordCard workoutRecordCard, GlobalKey key, int tag) {
    return PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        opaque: false,
        pageBuilder: (context, a1, a2) {
          return MenuWorkoutRecordCard(
              positionedAnimationDuration: const Duration(milliseconds: 200),
              workoutCardKey: key,
              workoutRecordCard: workoutRecordCard,
              heroTag: tag,
              deleteOnPressed: () async {
                await CustomDatabase.instance
                    .removeWorkoutRecord(workoutRecordCard.workoutRecord.id);
                workoutRecords = CustomDatabase.instance.readWorkoutRecords();
                Navigator.maybePop(context);
              },
              cancelOnPressed: () {
                Navigator.maybePop(context);
              });
        });
  }
}

class WorkoutRecordCard extends StatefulWidget {
  const WorkoutRecordCard(this.workoutRecord, this.onPressed, this.removeMode,
      {Key? key, this.onLongPress})
      : super(key: key);
  final Function? onLongPress;
  final WorkoutRecord workoutRecord;
  final void Function() onPressed;
  final bool removeMode;
  Duration get expandDuration => Duration(
      milliseconds: 100 + (workoutRecord.excerciseRecords.length - 5) * 40);

  @override
  _WorkoutRecordCardState createState() => _WorkoutRecordCardState();
}

class _WorkoutRecordCardState extends State<WorkoutRecordCard> {
  bool isButtonPressed = false;
  late bool _removeMode;
  late Duration expandDuration;

  @override
  void initState() {
    super.initState();
    expandDuration = Duration(
        milliseconds:
            100 + (widget.workoutRecord.excerciseRecords.length - 5) * 20);
  }

  @override
  Widget build(BuildContext context) {
    var excercises = widget.workoutRecord.excerciseRecords;
    List<Widget> exc = [];

    for (int i = 0; i < excercises.length; i++) {
      exc.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                  "${excercises[i].reps_weight_rpe.length}" +
                      "  ×  " +
                      excercises[i].excerciseName,
                  style: const TextStyle(fontSize: 15, color: Colors.white)),
            ),
          ],
        ),
      ));
    }
    return GestureDetector(
      onTap: () {
        widget.onPressed.call();
      },
      onLongPress: () {
        if (widget.onLongPress != null) {
          widget.onLongPress!.call();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Palette.elementsDark,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Material(
            color: Colors.transparent,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Palette.orange,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.workoutRecord.day.day.toString() +
                        " - " +
                        widget.workoutRecord.day.month.toString() +
                        " - " +
                        widget.workoutRecord.day.year.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.expand_more_outlined,
                    color: Colors.white,
                  )
                ]),
              ),
              Row(
                children: [
                  Text(widget.workoutRecord.workoutName,
                      style:
                          const TextStyle(fontSize: 24, color: Colors.white)),
                  const Spacer(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: exc)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
