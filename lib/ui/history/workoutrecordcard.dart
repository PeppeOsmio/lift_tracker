import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:fluttericon/zocial_icons.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/workoutrecord.dart';
import 'package:lift_tracker/ui/colors.dart';

class WorkoutRecordCard extends StatefulWidget {
  const WorkoutRecordCard(this.workoutRecord, this.onPressed,
      {Key? key, this.onLongPress})
      : super(key: key);
  final Future Function()? onLongPress;
  final WorkoutRecord workoutRecord;
  final void Function() onPressed;
  Duration get expandDuration => Duration(
      milliseconds: 100 + (workoutRecord.exerciseRecords.length - 5) * 40);

  @override
  _WorkoutRecordCardState createState() => _WorkoutRecordCardState();
}

class _WorkoutRecordCardState extends State<WorkoutRecordCard> {
  bool isButtonPressed = false;
  late Duration expandDuration;
  int totalVolume = 0;
  int recordNumber = 0;
  List<int> recordExercisesIndexes = [];
  bool offstage = false;

  @override
  void initState() {
    super.initState();
    expandDuration = Duration(
        milliseconds:
            100 + (widget.workoutRecord.exerciseRecords.length - 5) * 20);
    // total volume of workout
    for (int i = 0; i < widget.workoutRecord.exerciseRecords.length; i++) {
      var exerciseRecord = widget.workoutRecord.exerciseRecords[i];
      bool hasRecord = false;
      for (int j = 0; j < exerciseRecord.reps_weight_rpe.length; j++) {
        var set = exerciseRecord.reps_weight_rpe;
        double volume = (set[j]['reps'] * set[j]['weight']);
        totalVolume += volume.round();

        if (set[j]['hasRecord'] == 1) {
          hasRecord = true;
        }
      }
      if (hasRecord) {
        recordExercisesIndexes.add(i);
      }
    }
    recordNumber = recordExercisesIndexes.length;
  }

  @override
  Widget build(BuildContext context) {
    var exercises = widget.workoutRecord.exerciseRecords;
    List<Widget> exc = [];

    for (int i = 0; i < exercises.length; i++) {
      exc.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Text(
                      "${exercises[i].reps_weight_rpe.length}  ×  " +
                          exercises[i].exerciseName,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.white)),
                  recordExercisesIndexes.contains(i)
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
      onLongPress: () async {
        if (widget.onLongPress != null) {
          setState(() {
            offstage = true;
          });
          await widget.onLongPress!.call();
          Future.delayed(const Duration(milliseconds: 150), () {
            setState(() {
              offstage = false;
            });
          });
        }
      },
      child: Visibility(
        visible: !offstage,
        maintainAnimation: true,
        maintainSize: true,
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(children: [
                        Icon(
                            Icons
                                .calendar_today_outlined, //FontAwesome5.calendar_check,
                            color: Colors.blueGrey),
                        const SizedBox(width: 16),
                        Text(
                          Helper.dateToString(widget.workoutRecord.day),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
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
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white)),
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
      ),
    );
  }
}
