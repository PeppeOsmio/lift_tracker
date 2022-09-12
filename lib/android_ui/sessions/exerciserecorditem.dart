import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/exercise.dart';

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
  final PopupMenuButton popupMenuButton;
  final GlobalKey<AnimatedListState> animatedListKey;
  final Function(Function insertItem, Function removeItem)? onSetAdded;

  @override
  State<ExerciseRecordItem> createState() => _ExerciseRecordItemState();
}

class _ExerciseRecordItemState extends State<ExerciseRecordItem> {
  late final GlobalKey<AnimatedListState> animatedListKey;

  @override
  void initState() {
    super.initState();
    animatedListKey = widget.animatedListKey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              UIUtilities.loadTranslation(
                  context, widget.exercise.exerciseData.name),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: UIUtilities.getPrimaryColor(context)),
            ),
            Spacer(),
            widget.popupMenuButton
          ],
        ),
        AnimatedList(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            initialItemCount: widget.repsControllers.length,
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
                                          color: UIUtilities.getPrimaryColor(
                                              context))),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: widget.repsControllers[index],
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
                                  controller: widget.weightControllers[index],
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
                                  controller: widget.rpeControllers[index],
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
