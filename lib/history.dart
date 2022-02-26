import 'package:fluttericon/font_awesome5_icons.dart';

import 'package:flutter/material.dart';
import 'package:lift_tracker/data/database.dart';

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
                    readOnly: true,
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
                        WorkoutRecordCard workoutRecordCard =
                            WorkoutRecordCard(records[length - 1 - i], () {});
                        GlobalKey key = GlobalKey();
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: WorkoutRecordCard(records[length - 1 - i], () {
                            MaterialPageRoute route =
                                MaterialPageRoute(builder: (context) {
                              return Session(records[length - 1 - i]);
                            });
                            Navigator.push(context, route);
                          }, onLongPress: () {
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
  const WorkoutRecordCard(this.workoutRecord, this.onPressed,
      {Key? key, this.onLongPress})
      : super(key: key);
  final Function? onLongPress;
  final WorkoutRecord workoutRecord;
  final void Function() onPressed;
  Duration get expandDuration => Duration(
      milliseconds: 100 + (workoutRecord.excerciseRecords.length - 5) * 40);

  @override
  _WorkoutRecordCardState createState() => _WorkoutRecordCardState();
}

class _WorkoutRecordCardState extends State<WorkoutRecordCard> {
  bool isButtonPressed = false;
  late Duration expandDuration;
  int totalVolume = 0;
  int recordNumber = 0;
  List<int> recordExcercisesIndexes = [];

  @override
  void initState() {
    super.initState();
    expandDuration = Duration(
        milliseconds:
            100 + (widget.workoutRecord.excerciseRecords.length - 5) * 20);
    // total volume of workout
    for (int i = 0; i < widget.workoutRecord.excerciseRecords.length; i++) {
      var excerciseRecord = widget.workoutRecord.excerciseRecords[i];
      bool hasRecord = false;
      for (int j = 0; j < excerciseRecord.reps_weight_rpe.length; j++) {
        var set = excerciseRecord.reps_weight_rpe;
        double volume = (set[j]['reps'] * set[j]['weight']);
        totalVolume += volume.round();

        if (set[j]['hasRecord'] == 1) {
          hasRecord = true;
        }
      }
      if (hasRecord) {
        recordExcercisesIndexes.add(i);
      }
    }
    recordNumber = recordExcercisesIndexes.length;
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
              child: Row(
                children: [
                  Text(
                      "${excercises[i].reps_weight_rpe.length}  ×  " +
                          excercises[i].excerciseName,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.white)),
                  recordExcercisesIndexes.contains(i)
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            FontAwesome5.trophy,
                            size: 14,
                            color: Colors.green,
                          ),
                        )
                      : const SizedBox()
                ],
              ),
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
                    style: const TextStyle(color: Colors.white, fontSize: 20),
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
                  Expanded(
                    flex: 4,
                    child: Text(widget.workoutRecord.workoutName,
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white)),
                  ),
                  const Spacer(),
                  recordNumber > 0
                      ? Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green),
                              color: Colors.green.withAlpha(25)),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesome5.trophy,
                                size: 18,
                                color: Colors.green,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "$recordNumber",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber),
                        color: Colors.amber.withAlpha(25)),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesome5.weight_hanging,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          "$totalVolume kg",
                          style: TextStyle(
                              color: Colors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
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
