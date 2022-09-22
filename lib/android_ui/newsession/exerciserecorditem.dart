import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lift_tracker/android_ui/newsession/newsession.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/android_ui/widgets/materialpopupmenu.dart'
    as MaterialPopupMenu;

class ExerciseRecordItem extends StatefulWidget {
  const ExerciseRecordItem(
      {Key? key,
      required this.exercise,
      required this.repsControllers,
      required this.weightControllers,
      required this.rpeControllers,
      required this.popupMenuButton,
      required this.animatedListKey,
      this.onSetAdded})
      : super(key: key);
  final Exercise exercise;
  final List<TextEditingController> repsControllers;
  final List<TextEditingController> weightControllers;
  final List<TextEditingController> rpeControllers;
  final MaterialPopupMenu.MaterialPopupMenuButton popupMenuButton;
  final GlobalKey<AnimatedListState> animatedListKey;
  final Function(Function insertItem, Function removeItem)? onSetAdded;

  @override
  State<ExerciseRecordItem> createState() => _ExerciseRecordItemState();
}

class _ExerciseRecordItemState extends State<ExerciseRecordItem> {
  late GlobalKey<AnimatedListState> animatedListKey;
  late List<TextEditingController> repsControllers;
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> rpeControllers;
  late Exercise exercise;

  @override
  void initState() {
    super.initState();
    animatedListKey = widget.animatedListKey;
    repsControllers = widget.repsControllers;
    weightControllers = widget.weightControllers;
    rpeControllers = widget.rpeControllers;
    exercise = widget.exercise;
  }

  @override
  void didUpdateWidget(covariant ExerciseRecordItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    animatedListKey = widget.animatedListKey;
    repsControllers = widget.repsControllers;
    weightControllers = widget.weightControllers;
    rpeControllers = widget.rpeControllers;
    exercise = widget.exercise;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              UIUtilities.loadTranslation(context, exercise.exerciseData.name),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            Spacer(),
            widget.popupMenuButton
          ],
        ),
        AnimatedList(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            initialItemCount: repsControllers.length,
            key: animatedListKey,
            itemBuilder: ((context, index, animation) {
              return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 16, left: 8, top: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text((index + 1).toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  style: UIUtilities.getTextFieldTextStyle(
                                      context),
                                  controller: repsControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      UIUtilities.getTextFieldDecoration(
                                          context,
                                          UIUtilities.loadTranslation(
                                              context, 'shortReps')),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  style: UIUtilities.getTextFieldTextStyle(
                                      context),
                                  controller: weightControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      UIUtilities.getTextFieldDecoration(
                                          context,
                                          UIUtilities.loadTranslation(
                                              context, 'weight')),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  style: UIUtilities.getTextFieldTextStyle(
                                      context),
                                  controller: rpeControllers[index],
                                  onChanged: (value) {
                                    try {
                                      if (int.tryParse(value)! > 10) {
                                        rpeControllers[index].text = '10';
                                      }
                                    } catch (e) {}
                                    ;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      UIUtilities.getTextFieldDecoration(
                                          context, 'RPE'),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ));
            })),
      ],
    );
  }
}
