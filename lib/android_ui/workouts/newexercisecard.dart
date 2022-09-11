import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';

class NewExerciseCard extends StatefulWidget {
  const NewExerciseCard(
      {Key? key,
      this.exerciseName,
      required this.setsController,
      required this.repsController,
      required this.onSelectExercise,
      required this.exerciseNumber,
      this.popupMenuButton})
      : super(key: key);
  final String? exerciseName;
  final TextEditingController setsController;
  final TextEditingController repsController;
  final VoidCallback onSelectExercise;
  final int exerciseNumber;
  final PopupMenuButton? popupMenuButton;

  @override
  State<NewExerciseCard> createState() => _NewExerciseCardState();
}

class _NewExerciseCardState extends State<NewExerciseCard> {
  TextEditingController exerciseNameController = TextEditingController();
  int exerciseNumber = 0;

  @override
  void initState() {
    super.initState();
    exerciseNumber = widget.exerciseNumber;
  }

  @override
  Widget build(BuildContext context) {
    InputDecorationTheme inputDecorationTheme =
        Theme.of(context).inputDecorationTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).primaryTextTheme;
    FocusNode exerciseNameFocusNode = FocusNode();
    return Column(
      children: [
        TextField(
          focusNode: exerciseNameFocusNode,
          onTap: () {
            exerciseNameFocusNode.unfocus();
            widget.onSelectExercise();
          },
          controller: exerciseNameController,
          readOnly: true,
          decoration: InputDecoration(
              suffixIcon: widget.popupMenuButton,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.onBackground)),
              floatingLabelBehavior: inputDecorationTheme.floatingLabelBehavior,
              label: Text(UIUtilities.loadTranslation(context, 'exercise') +
                  ' $exerciseNumber')),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.setsController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: colorScheme.onBackground)),
                      floatingLabelBehavior:
                          inputDecorationTheme.floatingLabelBehavior,
                      label: Text(
                          UIUtilities.loadTranslation(context, 'setsField'))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  '×',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.repsController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: colorScheme.onBackground)),
                      floatingLabelBehavior:
                          inputDecorationTheme.floatingLabelBehavior,
                      label:
                          Text(UIUtilities.loadTranslation(context, 'reps'))),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  void didUpdateWidget(covariant NewExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    exerciseNameController.text =
        UIUtilities.loadTranslation(context, widget.exerciseName ?? '');
    setState(() {
      exerciseNumber = widget.exerciseNumber;
    });
  }
}

enum MoveOrRemoveMenuOption { remove, move_up, move_down }
