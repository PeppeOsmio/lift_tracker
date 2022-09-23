import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/workouthistory.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/old_ui/styles.dart';
import 'package:lift_tracker/old_ui/workouthistory/chart.dart';

class ExerciseChart extends StatefulWidget {
  const ExerciseChart(
      {Key? key, required this.exercise, required this.workoutHistory})
      : super(key: key);
  final Exercise exercise;
  final WorkoutHistory workoutHistory;

  @override
  State<ExerciseChart> createState() => _ExerciseChartState();
}

class _ExerciseChartState extends State<ExerciseChart> {
  bool isOpen = false;
  List<double> volumes = [];
  List<ExerciseRecord> exerciseRecords = [];
  List<DateTime> dates = [];
  late String totalVolume;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.workoutHistory.workoutRecords.length; i++) {
      List<ExerciseRecord> exerciseRecords =
          widget.workoutHistory.workoutRecords[i].exerciseRecords;
      try {
        var foundRecord = exerciseRecords
            .firstWhere((element) => element.exerciseId == widget.exercise.id);
        exerciseRecords.add(foundRecord);
        volumes.add(foundRecord.volume().toDouble());
        dates.add(widget.workoutHistory.workoutRecords[i].day);
      } catch (e) {
        UIUtilities.showSnackBar(
            context: context, msg: 'exercisechart: ' + e.toString());
        log(e.toString());
      }
    }
    Future.delayed(Duration.zero, () {
      if (volumes.length > 1) {
        totalVolume =
            UIUtilities.loadTranslation(context, 'totalVolumeExercise');
        totalVolume = totalVolume.replaceFirst('%s', volumes.length.toString());
      } else {
        totalVolume =
            UIUtilities.loadTranslation(context, 'totalVolumeExerciseOne');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              UIUtilities.loadTranslation(
                  context, widget.exercise.exerciseData.name),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 0),
                child: Divider(
                  thickness: 1,
                ),
              ),
            ),
            IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    isOpen = !isOpen;
                  });
                },
                icon: AnimatedRotation(
                  child: Icon(Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary),
                  turns: isOpen ? 0.5 : 0,
                  duration: Duration(milliseconds: 150),
                ))
          ],
        ),
        AnimatedSize(
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 150),
            child: isOpen
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      height: 150,
                      child: volumes.isNotEmpty
                          ? Column(
                              children: [
                                Text(
                                  totalVolume,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Chart(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      values: volumes,
                                      getTooltips: (lineBarSpotList) {
                                        List<LineTooltipItem> list = [];
                                        for (var item in lineBarSpotList) {
                                          var date = Helper.dateToString(
                                              dates[(item.x).toInt()]);
                                          String dateString =
                                              '${UIUtilities.loadTranslation(context, date['month']!)} ${date['day']}, ${date['year']}';
                                          list.add(LineTooltipItem(
                                              dateString +
                                                  '\n${item.y.toStringAsFixed(0)} kg',
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyText2!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary)));
                                        }
                                        return list;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              UIUtilities.loadTranslation(
                                  context, 'exerciseNotPerformed'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                            ),
                    ),
                  )
                : SizedBox())
      ],
    );
  }
}
