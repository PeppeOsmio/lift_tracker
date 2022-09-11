import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';

class NewSession extends ConsumerStatefulWidget {
  const NewSession({Key? key, required this.workout, this.resumedSession})
      : super(key: key);
  final Workout workout;
  final WorkoutRecord? resumedSession;

  @override
  ConsumerState<NewSession> createState() => _NewSessionState();
}

class _NewSessionState extends ConsumerState<NewSession> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIUtilities.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: UIUtilities.getAppBarColor(context),
        title: Text(UIUtilities.loadTranslation(context, 'newSessionOf') +
            ' ${widget.workout.name}'),
      ),
    );
  }
}
