import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/old_ui/styles.dart';
import 'package:lift_tracker/old_ui/widgets.dart';
import 'package:lift_tracker/localizations.dart';

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
    for (int i = 0; i < widget.workoutRecord.exerciseRecords.length; i++) {
      var exerciseRecord = widget.workoutRecord.exerciseRecords[i];
      bool hasRecord = false;
      for (int j = 0; j < exerciseRecord.sets.length; j++) {
        var set = exerciseRecord.sets;
        double volume = (set[j].reps * set[j].weight);
        totalVolume += volume.round();

        if (set[j].hasRepsRecord == 1 ||
            set[j].hasWeightRecord == 1 ||
            set[j].hasVolumeRecord == 1) {
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
    var date = Helper.dateToString(widget.workoutRecord.day);
    List<Widget> items = buildExerciseCardList();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Palette.backgroundDark,
        body: Column(
          children: [
            CustomAppBar(
                middleText:
                    '${UIUtilities.loadTranslation(context, 'sessionOf')} ${widget.workoutRecord.workoutName} ${UIUtilities.loadTranslation(context, date['month']!)} ${date['day']}, ${date['year']}',
                onBack: () {
                  Navigator.pop(context);
                },
                onSubmit: () {},
                backButton: true,
                submitButton: false),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => items[index],
                itemCount: items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildExerciseCardList() {
    var records = widget.workoutRecord.exerciseRecords;
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
                    '${UIUtilities.loadTranslation(context, 'volume')}: $totalVolume kg',
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
                    'Records: $recordNumber',
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
        child: ExerciseRecordCard(widget.workoutRecord.exerciseRecords[i]),
      ));
    }
    return cardList;
  }
}

class ExerciseRecordCard extends StatelessWidget {
  const ExerciseRecordCard(this.exerciseRecord, {Key? key}) : super(key: key);
  final ExerciseRecord exerciseRecord;

  TableRow buildSetRow(int index, BuildContext context) {
    String weight = exerciseRecord.sets[index].weight.toString();
    String reps = exerciseRecord.sets[index].reps.toString();
    String rpe = exerciseRecord.sets[index].rpe.toString();
    String volume =
        (exerciseRecord.sets[index].reps * exerciseRecord.sets[index].weight)
            .round()
            .toString();
    int hasWeightRecord = exerciseRecord.sets[index].hasWeightRecord;
    int hasVolumeRecord = exerciseRecord.sets[index].hasVolumeRecord;
    int hasRepsRecord = exerciseRecord.sets[index].hasRepsRecord;
    double width = MediaQuery.of(context).size.width;
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
            padding: const EdgeInsets.only(left: 8),
            width: (width - 32) / 10,
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            )),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 08),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            hasRepsRecord == 1
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(FontAwesome5.trophy,
                        color: Colors.green, size: 14),
                  )
                : SizedBox(),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: hasRepsRecord == 1 ? 22 : 0),
                child: Text(
                  rpe != 'null' && exerciseRecord.type == 'free'
                      ? reps + ' @' + rpe
                      : reps,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            hasWeightRecord == 1
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(FontAwesome5.trophy,
                        color: Colors.green, size: 14),
                  )
                : SizedBox(),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: hasWeightRecord == 1 ? 22 : 0),
                child: Text(
                  exerciseRecord.type != 'free'
                      ? rpe != 'null'
                          ? weight + ' @' + rpe
                          : weight
                      : '/',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            hasVolumeRecord == 1
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(FontAwesome5.trophy,
                        color: Colors.green, size: 14),
                  )
                : SizedBox(),
            Flexible(
              child: FittedBox(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: hasVolumeRecord == 1 ? 22 : 0),
                  child: Text(
                    exerciseRecord.type != 'free' ? volume : '/',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<TableRow> setRows = [];

    TableRow topRow = TableRow(children: [
      Padding(
          padding: EdgeInsets.only(top: 24, bottom: 12),
          child: Center(
            child: Text(
              UIUtilities.loadTranslation(context, 'set'),
              style: const TextStyle(color: Colors.white),
            ),
          )),
      Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Center(
            child: Text(
              UIUtilities.loadTranslation(context, 'reps'),
              style: const TextStyle(color: Colors.white),
            ),
          )),
      Padding(
          padding: EdgeInsets.only(top: 24, bottom: 12),
          child: Center(
            child: Text(
              '${UIUtilities.loadTranslation(context, 'weight')} (kg)',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Padding(
          padding: EdgeInsets.only(top: 24, bottom: 12, left: 8),
          child: Center(
            child: Text(
              '${UIUtilities.loadTranslation(context, 'volume')} (kg)',
              style: TextStyle(color: Colors.white),
            ),
          )),
    ]);

    setRows.add(topRow);

    for (int i = 0; i < exerciseRecord.sets.length; i++) {
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
                  UIUtilities.loadTranslation(
                      context, exerciseRecord.exerciseData.name),
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
                  padding: const EdgeInsets.only(left: 4, right: 12),
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
