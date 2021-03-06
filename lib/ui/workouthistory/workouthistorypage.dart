import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/data/classes/workouthistory.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/ui/styles.dart';
import 'package:lift_tracker/ui/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lift_tracker/ui/workouthistory/chart.dart';
import 'package:lift_tracker/ui/workouthistory/exercisechart.dart';

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
      Fluttertoast.showToast(
          msg: Helper.loadTranslation(context, 'touchToSeeDetails'));
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
      totalVolume = Helper.loadTranslation(context, 'totalVolumeOf');
      totalVolume = totalVolume.replaceFirst('#n', volumes.length.toString());
    } else {
      totalVolume = Helper.loadTranslation(context, 'totalVolumeOne');
    }
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Palette.backgroundDark,
        body: Column(children: [
          CustomAppBar(
              middleText:
                  '${Helper.loadTranslation(context, 'historyOf')} ${widget.workoutHistory.workout.name}',
              onBack: () {
                Navigator.maybePop(context);
              },
              onSubmit: () {},
              backButton: true,
              submitButton: false),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(
                child: Text(
              totalVolume,
              style: TextStyle(color: Colors.white, fontSize: 18),
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
            child: SizedBox(
              height: 200,
              child: Chart(
                color: Colors.orange,
                values: volumes,
                getTooltips: (lineBarSpotList) {
                  List<LineTooltipItem> list = [];
                  for (var item in lineBarSpotList) {
                    WorkoutRecord workoutRecord =
                        workoutRecords[(item.x).toInt()];
                    var date = Helper.dateToString(workoutRecord.day);
                    String dateString =
                        '${Helper.loadTranslation(context, date['month']!)} ${date['day']}, ${date['year']}';
                    list.add(LineTooltipItem(
                        dateString + '\n${item.y.toStringAsFixed(0)} kg',
                        TextStyle(color: Colors.white)));
                  }
                  return list;
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ListView.separated(
                  separatorBuilder: ((context, index) {
                    return SizedBox(
                      height: 16,
                    );
                  }),
                  itemCount: widget.workoutHistory.workout.exercises.length,
                  itemBuilder: ((context, index) {
                    var exercise =
                        widget.workoutHistory.workout.exercises[index];
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: index == 0 ? 12 : 0),
                      child: ExerciseChart(
                          exercise: exercise,
                          workoutHistory: widget.workoutHistory),
                    );
                  })),
            ),
          )
        ]),
      ),
    );
  }
}
