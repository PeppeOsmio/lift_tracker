import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/workoutrecord.dart';
import 'package:lift_tracker/ui/colors.dart';

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
                    Helper.dateToString(widget.workoutRecord.day),
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
