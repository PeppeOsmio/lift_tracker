import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exerciserecord.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';

class ExerciseRecordCard extends StatelessWidget {
  const ExerciseRecordCard({Key? key, required this.exerciseRecord})
      : super(key: key);
  final ExerciseRecord exerciseRecord;

  @override
  Widget build(BuildContext context) {
    Widget recordIcon = Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(
        FontAwesome5.trophy,
        color: Theme.of(context).colorScheme.secondary,
        size: Theme.of(context).textTheme.bodyText2!.fontSize,
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            Text(
              UIUtilities.loadTranslation(
                  context, exerciseRecord.exerciseData.name),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Divider(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    UIUtilities.loadTranslation(context, 'set'),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                  ...exerciseRecord.sets.asMap().entries.map((mapEntry) {
                    int index = mapEntry.key;
                    return Text(
                      '${index + 1}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                    );
                  }).toList()
                ],
              ),
              Column(
                children: [
                  Text(UIUtilities.loadTranslation(context, 'shortReps'),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline)),
                  ...exerciseRecord.sets.asMap().entries.map((mapEntry) {
                    var set = mapEntry.value;
                    return set.hasRepsRecord == 1
                        ? Row(
                            children: [Text('${set.reps}'), recordIcon],
                          )
                        : Text('${set.reps}');
                  }).toList()
                ],
              ),
              Column(
                children: [
                  Text(UIUtilities.loadTranslation(context, 'weight') + ' (kg)',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline)),
                  ...exerciseRecord.sets.asMap().entries.map((mapEntry) {
                    var set = mapEntry.value;
                    String weight = set.weight - set.weight.floor() > 0
                        ? '${set.weight}'
                        : '${set.weight.toStringAsFixed(0)}';
                    String weightString = '${weight}';
                    if (set.rpe != null) {
                      weightString += ' @RPE ${set.rpe}';
                    }
                    return set.hasWeightRecord == 1
                        ? Row(
                            children: [Text(weightString), recordIcon],
                          )
                        : Text(weightString);
                  }).toList()
                ],
              ),
              Column(
                children: [
                  Text(UIUtilities.loadTranslation(context, 'volume') + ' (kg)',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline)),
                  ...exerciseRecord.sets.asMap().entries.map((mapEntry) {
                    var set = mapEntry.value;
                    return set.hasVolumeRecord == 1
                        ? Row(
                            children: [Text('${set.volume()}'), recordIcon],
                          )
                        : Text('${set.volume()}');
                  }).toList()
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
