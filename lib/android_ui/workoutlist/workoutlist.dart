import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/widgets/reactiveappbardata.dart';
import 'package:lift_tracker/android_ui/workoutlist/workoutcard.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';

class WorkoutList extends ConsumerStatefulWidget {
  const WorkoutList(
      {Key? key,
      this.onCardTap,
      this.onCardClose,
      required this.canSelectThings,
      required this.appBarData,
      this.selectedCardColor,
      this.selectedTextColor})
      : super(key: key);
  final Function(VoidCallback onDelete, VoidCallback onHistory,
      VoidCallback onEdit, VoidCallback onStart, String workoutName)? onCardTap;
  final Function? onCardClose;
  final bool canSelectThings;
  final ReactiveAppBarData appBarData;
  final Color? selectedCardColor;
  final Color? selectedTextColor;

  @override
  ConsumerState<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends ConsumerState<WorkoutList> {
  List<Workout> workouts = [];
  int? openIndex;

  @override
  void initState() {
    super.initState();
    log('Building WorkoutList...');
    CustomDatabase.instance.readWorkouts().then((value) {
      ref.read(Helper.workoutsProvider.notifier).addWorkouts(value);
      log('Workouts from workout list: ' + value.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.canSelectThings) {
      openIndex = null;
    }
    workouts = ref.watch(Helper.workoutsProvider);
    return GestureDetector(
      onTap: () {
        deselectWorkouts();
      },
      child: Container(
        child: ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              return WorkoutCard(
                  color: widget.canSelectThings && openIndex == index
                      ? widget.selectedCardColor
                      : null,
                  textColor: widget.canSelectThings && openIndex == index
                      ? widget.selectedTextColor
                      : null,
                  isOpen: widget.canSelectThings && openIndex == index,
                  workout: workouts[index],
                  onCardTap: () {
                    if (!widget.canSelectThings) {
                      return;
                    }
                    setState(() {
                      if (openIndex != null && openIndex == index) {
                        openIndex = null;
                      } else {
                        openIndex = index;
                      }
                    });
                    if (openIndex == index) {
                      selectWorkout(index);
                    } else {
                      deselectWorkouts();
                    }
                  });
            }),
      ),
    );
  }

  void selectWorkout(int index) {
    widget.appBarData.title = workouts[index].name;
    widget.appBarData.actions = [
      IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
      IconButton(onPressed: () {}, icon: Icon(Icons.history_rounded)),
      IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
      IconButton(onPressed: () {}, icon: Icon(Icons.play_arrow))
    ];
    widget.appBarData.leading =
        IconButton(onPressed: deselectWorkouts, icon: Icon(Icons.arrow_back));
    widget.appBarData.isSelected = true;
    if (widget.appBarData.onUpdate != null) {
      widget.appBarData.onUpdate!();
    }
  }

  void deselectWorkouts() {
    widget.appBarData.title = null;
    widget.appBarData.leading = null;
    widget.appBarData.actions = [];
    widget.appBarData.isSelected = false;
    widget.appBarData.backgroundColor = null;
    openIndex = null;
    if (widget.appBarData.onUpdate != null) {
      widget.appBarData.onUpdate!();
    }
  }
}
