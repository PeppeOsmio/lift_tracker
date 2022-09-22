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
    TextStyle textStyle = Theme.of(context).textTheme.bodyLarge!;
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
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
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      UIUtilities.loadTranslation(context, 'set'),
                      style: textStyle.copyWith(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  ...exerciseRecord.sets.asMap().entries.map((mapEntry) {
                    int index = mapEntry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('${index + 1}',
                          style: textStyle.copyWith(
                              color: Theme.of(context).colorScheme.outline)),
                    );
                  }).toList()
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                        UIUtilities.loadTranslation(context, 'shortReps'),
                        style: textStyle.copyWith(
                            color: Theme.of(context).colorScheme.outline)),
                  ),
                  ...exerciseRecord.sets.asMap().entries.map((mapEntry) {
                    var set = mapEntry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: set.hasRepsRecord == 1
                          ? Row(
                              children: [
                                Text('${set.reps}', style: textStyle),
                                recordIcon
                              ],
                            )
                          : Text(
                              '${set.reps}',
                              style: textStyle,
                            ),
                    );
                  }).toList()
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                        UIUtilities.loadTranslation(context, 'weight') +
                            ' (kg)',
                        style: textStyle.copyWith(
                            color: Theme.of(context).colorScheme.outline)),
                  ),
                  ...exerciseRecord.sets.asMap().entries.map((mapEntry) {
                    var set = mapEntry.value;
                    String weight = set.weight - set.weight.floor() > 0
                        ? '${set.weight}'
                        : '${set.weight.toStringAsFixed(0)}';
                    String weightString = '${weight}';
                    if (set.rpe != null) {
                      weightString += ' @RPE ${set.rpe}';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: set.hasWeightRecord == 1
                          ? Row(
                              children: [
                                Text(weightString, style: textStyle),
                                recordIcon
                              ],
                            )
                          : Text(weightString, style: textStyle),
                    );
                  }).toList()
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                        UIUtilities.loadTranslation(context, 'volume') +
                            ' (kg)',
                        style: textStyle.copyWith(
                            color: Theme.of(context).colorScheme.outline)),
                  ),
                  ...exerciseRecord.sets.asMap().entries.map((mapEntry) {
                    var set = mapEntry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: set.hasVolumeRecord == 1
                          ? Row(
                              children: [
                                Text('${set.volume()}', style: textStyle),
                                recordIcon
                              ],
                            )
                          : Text(
                              '${set.volume()}',
                              style: textStyle,
                            ),
                    );
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
