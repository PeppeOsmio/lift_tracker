import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_tracker/app.dart';
import 'package:lift_tracker/data/constants.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/data/excerciserecord.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/data/workoutrecord.dart';
import 'package:lift_tracker/history.dart';
import 'package:lift_tracker/ui/colors.dart';

class Session extends StatefulWidget {
  const Session(this.workoutRecord, {Key? key}) : super(key: key);
  final WorkoutRecord workoutRecord;

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<Session> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
      child: Scaffold(
        backgroundColor: Palette.backgroundDark,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Palette.elementsDark,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                        height: 35,
                        width: 35,
                        child: InkWell(
                            radius: 17.5,
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.chevron_left_outlined,
                              color: Colors.redAccent,
                            ))),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        widget.workoutRecord.workoutName +
                            " session of " +
                            widget.workoutRecord.day
                                .toString()
                                .substring(0, 10),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    int length = widget.workoutRecord.excerciseRecords.length;
                    return Padding(
                      padding: EdgeInsets.only(
                          top: 24, bottom: index == length - 1 ? 24 : 0),
                      child: ExcerciseRecordCard(
                          widget.workoutRecord.excerciseRecords[index]),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 0);
                  },
                  itemCount: widget.workoutRecord.excerciseRecords.length),
            ),
          ],
        ),
      ),
    ));
  }
}

class ExcerciseRecordCard extends StatelessWidget {
  const ExcerciseRecordCard(this.excerciseRecord, {Key? key}) : super(key: key);
  final ExcerciseRecord excerciseRecord;

  TableRow buildSetRow(int index, BuildContext context) {
    String weight = excerciseRecord.reps_weight_rpe[index]['weight'].toString();
    int k = weight.indexOf(".");
    for (int i = k + 1; i < weight.length; i++) {
      if (weight[i] != 0) {
        i = weight.length;
        weight = (excerciseRecord.reps_weight_rpe[index]['weight'] as double)
            .toStringAsFixed(0);
      }
    }
    String reps = excerciseRecord.reps_weight_rpe[index]['reps'].toString();
    String rpe = excerciseRecord.reps_weight_rpe[index]['rpe'].toString();
    double width = MediaQuery.of(context).size.width;
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
            padding: const EdgeInsets.only(left: 8),
            width: (width - 32) / 10,
            child: Center(
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            )),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Center(
          child: Text(reps,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Center(
          child: Text(
            weight + " kg",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 08),
        child: Center(
          child: Text(rpe, style: const TextStyle(color: Colors.white)),
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<TableRow> setRows = [];

    TableRow topRow = const TableRow(children: [
      Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Center(
            child: Text(
              "Set",
              style: const TextStyle(color: Colors.white),
            ),
          )),
      Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Center(
            child: Text(
              "Reps",
              style: const TextStyle(color: Colors.white),
            ),
          )),
      Padding(
          padding: EdgeInsets.only(top: 24, bottom: 12),
          child: Center(
            child: Text(
              "Weight",
              style: TextStyle(color: Colors.white),
            ),
          )),
      Padding(
          padding: EdgeInsets.only(top: 24, bottom: 12, left: 8),
          child: Center(
            child: Text(
              "Rpe",
              style: TextStyle(color: Colors.white),
            ),
          )),
    ]);

    setRows.add(topRow);

    for (int i = 0; i < excerciseRecord.reps_weight_rpe.length; i++) {
      setRows.add(buildSetRow(i, context));
    }

    //double width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(right: 0 /*Constants.screenSize!.width / 5*/),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  excerciseRecord.excerciseName,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32),
            child: Table(
              children: setRows,
            ),
          )
        ],
      ),
    );
  }
}
