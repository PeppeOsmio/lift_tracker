import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:lift_tracker/android_ui/session/exerciserecordcard.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';

class Session extends StatefulWidget {
  const Session({Key? key, required this.workoutRecord}) : super(key: key);
  final WorkoutRecord workoutRecord;

  @override
  State<Session> createState() => _SessionState();
}

class _SessionState extends State<Session> {
  int totalVolume = 0;
  int recordNumber = 0;
  List<int> recordExercisesIndexes = [];

  List<Widget> body() {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                color: UIUtilities.getRecordsBackgroundColor(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesome5.trophy,
                        size: 18 * 1.2,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(
                        width: 8 * 1.2,
                      ),
                      Text(
                        'Records: $recordNumber',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 14 * 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: UIUtilities.getVolumeBackgroundColor(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesome5.weight_hanging,
                        size: 18 * 1.2,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(
                        width: 8 * 1.2,
                      ),
                      Text(
                        '${UIUtilities.loadTranslation(context, 'volume')}: $totalVolume kg',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 14 * 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      ...widget.workoutRecord.exerciseRecords.map((exerciseRecord) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: ExerciseRecordCard(exerciseRecord: exerciseRecord),
        );
      }).toList()
    ];
  }

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
    List<Widget> bodyItems = body();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(UIUtilities.loadTranslation(context, 'sessionOf') +
            ' ${widget.workoutRecord.workoutName}'),
      ),
      body: ListView.builder(
          itemCount: bodyItems.length,
          itemBuilder: (context, index) {
            return bodyItems[index];
          }),
    );
  }
}