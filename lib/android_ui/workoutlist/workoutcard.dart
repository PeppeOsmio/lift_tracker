import 'package:flutter/material.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/helper.dart';

class WorkoutCard extends StatefulWidget {
  const WorkoutCard(
      {Key? key,
      this.color,
      this.textColor,
      required this.isOpen,
      required this.workout,
      required this.onCardTap})
      : super(key: key);
  final bool isOpen;
  final Workout workout;
  final Function() onCardTap;
  final Color? color;
  final Color? textColor;

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var exercises = widget.workout.exercises;
    List<Widget> exc = [];
    int stop;
    if (widget.isOpen) {
      stop = exercises.length;
    } else {
      stop = 4;
    }
    if (exercises.length <= 5) {
      stop = exercises.length;
    }
    for (int i = 0; i < stop; i++) {
      String name = exercises[i].exerciseData.name;
      exc.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(UIUtilities.loadTranslation(context, name),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                    exercises[i].sets.toString() +
                        '  ×  ' +
                        exercises[i].reps.toString(),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface)),
              ),
            ],
          )));
    }
    if (!widget.isOpen && exercises.length > 5) {
      exc.add(Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Text('...',
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ));
    }
    return AnimatedSize(
      duration: Duration(milliseconds: 150),
      curve: Curves.decelerate,
      child: GestureDetector(
        onTap: () {
          widget.onCardTap();
        },
        child: Card(
          elevation: widget.isOpen ? 5 : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(widget.workout.name,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary)),
                  Spacer(),
                  AnimatedRotation(
                    curve: Curves.decelerate,
                    turns: widget.isOpen ? 0.5 : 0,
                    duration: Duration(milliseconds: 150),
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exc,
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
