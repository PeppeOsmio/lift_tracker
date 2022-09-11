import 'package:flutter/material.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/gym_icons_icons.dart';

class ExerciseDataCard extends StatelessWidget {
  const ExerciseDataCard({Key? key, required this.exerciseData})
      : super(key: key);
  final ExerciseData exerciseData;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (exerciseData.type) {
      case 'free':
        icon = GymIcons.cardio;
        break;
      case 'barebell':
        icon = GymIcons.barebell;
        break;
      case 'dumbbell':
        icon = GymIcons.dumbbell;
        break;
      default:
        icon = GymIcons.machine;
        break;
    }
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 26,
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(
                    icon,
                    size: 26,
                  )),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        UIUtilities.loadTranslation(context, exerciseData.name),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          UIUtilities.loadTranslation(
                              context, exerciseData.firstMuscle),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        SizedBox(width: 16),
                        Text(
                            UIUtilities.loadTranslation(
                                context, exerciseData.secondMuscle),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                        SizedBox(width: 16),
                        Text(
                            UIUtilities.loadTranslation(
                                context, exerciseData.thirdMuscle),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary))
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
