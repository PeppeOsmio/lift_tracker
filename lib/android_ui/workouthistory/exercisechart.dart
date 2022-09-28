import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/workouthistory.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/android_ui/workouthistory/chart.dart';

class ExerciseChart extends StatelessWidget {
  const ExerciseChart(
      {Key? key,
      required this.exercise,
      required this.workoutHistory,
      required this.isOpen,
      required this.onOpen})
      : super(key: key);
  final Exercise exercise;
  final WorkoutHistory workoutHistory;
  final bool isOpen;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    List<double> volumes = [];
    List<DateTime> dates = [];
    late String totalVolume;

    for (int i = 0; i < workoutHistory.workoutRecords.length; i++) {
      List<ExerciseRecord> exerciseRecords =
          workoutHistory.workoutRecords[i].exerciseRecords;
      for (int j = 0; j < exerciseRecords.length; j++) {}
      try {
        var foundRecord = exerciseRecords
            .firstWhere((element) => element.exerciseId == exercise.id);
        exerciseRecords.add(foundRecord);
        volumes.add(foundRecord.volume().toDouble());
        dates.add(workoutHistory.workoutRecords[i].day);
      } catch (e) {}
    }
    if (volumes.length > 1) {
      totalVolume = UIUtilities.loadTranslation(context, 'totalVolumeExercise');
      totalVolume = totalVolume.replaceFirst('%s', volumes.length.toString());
    } else {
      totalVolume =
          UIUtilities.loadTranslation(context, 'totalVolumeExerciseOne');
    }

    return Column(
      children: [
        Row(
          children: [
            Text(
              UIUtilities.loadTranslation(context, exercise.exerciseData.name),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Divider(
                  thickness: 1,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                onOpen();
              },
              icon: AnimatedRotation(
                duration: Duration(milliseconds: 150),
                child: Icon(
                  isOpen ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).colorScheme.primary,
                ),
                turns: isOpen ? 0.5 : 0,
              ),
            ),
          ],
        ),
        AnimatedSize(
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 150),
            child: isOpen
                ? volumes.isNotEmpty
                    ? SizedBox(
                        height: 200,
                        child: Column(
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
                                  color: Theme.of(context).colorScheme.tertiary,
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
                                                      .onBackground)));
                                    }
                                    return list;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        UIUtilities.loadTranslation(
                            context, 'exerciseNotPerformed'),
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                      )
                : SizedBox(
                    height: 0,
                  ))
      ],
    );
  }
}
