import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:lift_tracker/ui/app/app.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/data/excerciserecord.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/data/workoutrecord.dart';
import 'package:lift_tracker/ui/history/history.dart';
import 'package:lift_tracker/ui/colors.dart';

class Session extends StatefulWidget {
  const Session(this.workoutRecord, {Key? key}) : super(key: key);
  final WorkoutRecord workoutRecord;

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<Session> {
  int totalVolume = 0;
  int recordNumber = 0;

  @override
  void initState() {
    super.initState();
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
        recordNumber++;
      }
    }
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
                            Helper.dateToString(widget.workoutRecord.day),
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
              child: ListView(
                children: buildExcerciseCardList(),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  List<Widget> buildExcerciseCardList() {
    var records = widget.workoutRecord.excerciseRecords;
    List<Widget> cardList = [];
    cardList.add(
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber),
                  color: Colors.amber.withAlpha(25)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                    "Volume: $totalVolume kg",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                  color: Colors.green.withAlpha(25)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                    "Records: $recordNumber",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    for (int i = 0; i < records.length; i++) {
      cardList.add(Padding(
        padding:
            EdgeInsets.only(top: 24, bottom: i == records.length - 1 ? 24 : 0),
        child: ExcerciseRecordCard(widget.workoutRecord.excerciseRecords[i]),
      ));
    }
    return cardList;
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
    int hasRecord = excerciseRecord.reps_weight_rpe[index]['hasRecord'];
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            hasRecord == 1
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(FontAwesome5.trophy,
                        color: Colors.green, size: 14),
                  )
                : SizedBox(),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: hasRecord == 1 ? 22 : 0),
                child: Text(
                  weight,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
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
              "Weight (kg)",
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
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  excerciseRecord.excerciseName,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 32),
                  child: Divider(
                    thickness: 2,
                    color: Palette.elementsDark,
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Container(
                color: Palette.elementsDark,
                width: 8,
                //height: double.infinity,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 32, right: 32),
                  child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(4),
                      3: FlexColumnWidth(3)
                    },
                    children: setRows,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
