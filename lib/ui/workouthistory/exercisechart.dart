import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/workouthistory.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/workouthistory/chart.dart';

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
        volumes.add(foundRecord.volume());
        dates.add(widget.workoutHistory.workoutRecords[i].day);
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              Helper.loadTranslation(context, widget.exercise.name),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Divider(
                  thickness: 2,
                  color: Palette.elementsDark,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isOpen = !isOpen;
                });
              },
              child: Icon(
                isOpen ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
            ),
          ],
        ),
        IntrinsicHeight(
          child: AnimatedSize(
              duration: const Duration(milliseconds: 100),
              child: isOpen
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        height: 150,
                        child: volumes.isNotEmpty
                            ? Column(
                                children: [
                                  Text(
                                    'Total volume of last 15 sessions',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Chart(
                                        color: Colors.green,
                                        values: volumes,
                                        getTooltips: (lineBarSpotList) {
                                          List<LineTooltipItem> list = [];
                                          for (var item in lineBarSpotList) {
                                            var date = Helper.dateToString(
                                                dates[(item.x).toInt()]);
                                            String dateString =
                                                '${Helper.loadTranslation(context, date['month']!)} ${date['day']}, ${date['year']}';
                                            list.add(LineTooltipItem(
                                                dateString +
                                                    '\n${item.y.toStringAsFixed(0)} kg',
                                                TextStyle(
                                                    color: Colors.white)));
                                          }
                                          return list;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'This exercise has not been performed yet in this workout',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    )),
        )
      ],
    );
  }
}