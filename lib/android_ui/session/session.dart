import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';

class Session extends StatefulWidget {
  const Session({Key? key, required this.workoutRecord}) : super(key: key);
  final WorkoutRecord workoutRecord;

  @override
  State<Session> createState() => _SessionState();
}

class _SessionState extends State<Session> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UIUtilities.loadTranslation(context, 'sessionOf') +
            ' ${widget.workoutRecord.workoutName}'),
      ),
    );
  }
}
