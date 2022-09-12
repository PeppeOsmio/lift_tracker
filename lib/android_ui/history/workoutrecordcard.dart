import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';

class WorkoutRecordCard extends StatefulWidget {
  const WorkoutRecordCard(
      {Key? key,
      this.color,
      this.isSelected = false,
      this.textColor,
      required this.workoutRecord,
      required this.onCardTap,
      required this.onCardLongPress})
      : super(key: key);
  final WorkoutRecord workoutRecord;
  final Function() onCardTap;
  final Function() onCardLongPress;
  final Color? color;
  final Color? textColor;
  final bool isSelected;

  @override
  State<WorkoutRecordCard> createState() => _WorkoutRecordCardState();
}

class _WorkoutRecordCardState extends State<WorkoutRecordCard> {
  int totalVolume = 0;
  int recordNumber = 0;
  List<int> recordExercisesIndexes = [];

  @override
  void initState() {
    super.initState();
    totalVolume = widget.workoutRecord.totalVolume();
    for (int i = 0; i < widget.workoutRecord.exerciseRecords.length; i++) {
      var exerciseRecord = widget.workoutRecord.exerciseRecords[i];
      bool hasRecord = false;
      for (int j = 0; j < exerciseRecord.sets.length; j++) {
        var set = exerciseRecord.sets;

        if (set[j].hasRepsRecord == 1 ||
            set[j].hasWeightRecord == 1 ||
            set[j].hasVolumeRecord == 1) {
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
    List<ExerciseRecord> exerciseRecords = widget.workoutRecord.exerciseRecords;
    List<Widget> exc = [];
    int stop;
    stop = 4;
    if (exerciseRecords.length <= 5) {
      stop = exerciseRecords.length;
    }
    for (int i = 0; i < stop; i++) {
      exc.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                    exerciseRecords[i].sets.length.toString() +
                        '  ×  ' +
                        UIUtilities.loadTranslation(
                            context, exerciseRecords[i].exerciseData.name),
                    style: TextStyle(color: widget.textColor, fontSize: 15)),
              ),
              recordExercisesIndexes.contains(i)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        FontAwesome5.trophy,
                        size: 14,
                        color: UIUtilities.getSecondaryColor(context),
                      ),
                    )
                  : const SizedBox()
            ],
          )));
    }
    if (exerciseRecords.length > 5) {
      exc.add(Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Text('...',
            style: TextStyle(color: widget.textColor, fontSize: 15)),
      ));
    }
    var date = Helper.dateToString(widget.workoutRecord.day);
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      curve: Curves.decelerate,
      child: GestureDetector(
        onTap: () {
          widget.onCardTap();
        },
        onLongPress: () {
          widget.onCardLongPress();
        },
        child: Card(
          color: widget.color,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(children: [
                  Icon(
                      Icons
                          .calendar_today_outlined, //FontAwesome5.calendar_check,
                      color: UIUtilities.getPrimaryColor(context)),
                  const SizedBox(width: 16),
                  Text(
                    '${UIUtilities.loadTranslation(context, date['month']!)} ${date['day']}, ${date['year']}',
                    style: TextStyle(
                        color: UIUtilities.getPrimaryColor(context),
                        fontSize: 20),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.expand_more_outlined,
                    color: UIUtilities.getPrimaryColor(context),
                  )
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.workoutRecord.workoutName,
                      style: TextStyle(
                          fontSize: 24,
                          color: UIUtilities.getPrimaryColor(context)),
                    ),
                    const Spacer(),
                    recordNumber > 0
                        ? Card(
                            color:
                                UIUtilities.getRecordsBackgroundColor(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesome5.trophy,
                                    size: 18,
                                    color:
                                        UIUtilities.getSecondaryColor(context),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    '$recordNumber',
                                    style: TextStyle(
                                        color: UIUtilities.getSecondaryColor(
                                            context),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(),
                    const SizedBox(
                      width: 8,
                    ),
                    Card(
                      color: UIUtilities.getVolumeBackgroundColor(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesome5.weight_hanging,
                              size: 18,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              '$totalVolume kg',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exc,
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
