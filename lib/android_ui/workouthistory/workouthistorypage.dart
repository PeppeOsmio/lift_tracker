import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/workouthistory.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/old_ui/styles.dart';
import 'package:lift_tracker/old_ui/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lift_tracker/android_ui/workouthistory/chart.dart';
import 'package:lift_tracker/android_ui/workouthistory/exercisechart.dart';

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({Key? key, required this.workoutHistory})
      : super(key: key);
  final WorkoutHistory workoutHistory;

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryState();
}

class _WorkoutHistoryState extends State<WorkoutHistoryPage> {
  late List<WorkoutRecord> workoutRecords;
  List<double> volumes = [];
  List<FlSpot> spots = [];
  late double ySpacing;
  late String totalVolume;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      UIUtilities.showSnackBar(
          context: context,
          msg: UIUtilities.loadTranslation(context, 'touchToSeeDetails'));
    });
    workoutRecords = widget.workoutHistory.workoutRecords;
    if (workoutRecords.length > 15) {
      List<WorkoutRecord> temp = [];
      for (int i = workoutRecords.length - 15; i < workoutRecords.length; i++) {
        temp.add(workoutRecords[i]);
      }
      workoutRecords.clear();
      workoutRecords.addAll(temp);
    }
    for (var workoutRecord in workoutRecords) {
      volumes.add(workoutRecord.totalVolume().toDouble());
    }
    for (int i = 0; i < volumes.length; i++) {
      spots.add(FlSpot(i.toDouble(), volumes[i]));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (volumes.length > 1) {
      totalVolume = UIUtilities.loadTranslation(context, 'totalVolumeOf');
      totalVolume = totalVolume.replaceFirst('%s', volumes.length.toString());
    } else {
      totalVolume = UIUtilities.loadTranslation(context, 'totalVolumeOne');
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          tooltip: UIUtilities.loadTranslation(context, 'back'),
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            '${UIUtilities.loadTranslation(context, 'historyOf')} ${widget.workoutHistory.workout.name}'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Center(
              child: Text(
            totalVolume,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
          )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          child: SizedBox(
            height: 200,
            child: Chart(
              color: Theme.of(context).colorScheme.secondary,
              values: volumes,
              getTooltips: (lineBarSpotList) {
                List<LineTooltipItem> list = [];
                for (var item in lineBarSpotList) {
                  WorkoutRecord workoutRecord =
                      workoutRecords[(item.x).toInt()];
                  var date = Helper.dateToString(workoutRecord.day);
                  String dateString =
                      '${UIUtilities.loadTranslation(context, date['month']!)} ${date['day']}, ${date['year']}';
                  list.add(LineTooltipItem(
                      dateString + '\n${item.y.toStringAsFixed(0)} kg',
                      Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: Theme.of(context).colorScheme.secondary)));
                }
                return list;
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ListView.builder(
                itemCount: widget.workoutHistory.workout.exercises.length,
                itemBuilder: ((context, index) {
                  var exercise = widget.workoutHistory.workout.exercises[index];
                  return Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: ExerciseChart(
                        exercise: exercise,
                        workoutHistory: widget.workoutHistory),
                  );
                })),
          ),
        ),
        SizedBox(
          height: 16,
        )
      ]),
    );
  }
}
