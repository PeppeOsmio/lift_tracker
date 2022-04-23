import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/ui/newworkout.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/widgets.dart';
import 'package:lift_tracker/ui/workoutlist/workoutcard.dart';
import 'package:lift_tracker/ui/workoutlist/menuworkoutcard.dart';

import '../../data/classes/exercise.dart';

class WorkoutList extends ConsumerStatefulWidget {
  const WorkoutList({Key? key}) : super(key: key);

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends ConsumerState<WorkoutList> {
  late Future<List<Workout>> workoutsFuture;
  bool isButtonPressed = false;
  List<Size> cardSized = [];
  List<GlobalKey> cardKeys = [];

  @override
  void initState() {
    super.initState();
  }

  Widget buildFAB() {
    return SizedBox(
      height: 65,
      width: 65,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: FloatingActionButton(
            onPressed: () async {
              Helper.unfocusTextFields(context);
              var route =
                  MaterialPageRoute(builder: (context) => const NewWorkout());
              await Navigator.push(context, route).then((value) {
                CustomDatabase.instance.readWorkouts().then((value) {
                  setState(() {
                    workoutsFuture = CustomDatabase.instance.readWorkouts();
                  });
                });
              });
            },
            backgroundColor: Colors.blueGrey.withAlpha(125),
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Icon(Icons.add_outlined, size: 24, color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    workoutsFuture = ref.watch(Helper.workoutsProvider);
    return Stack(
      children: [
        Column(
          children: [
            SearchBar(
                hint: Helper.loadTranslation(context, 'filter'),
                textController: TextEditingController()),
            FutureBuilder(
              future: workoutsFuture,
              builder: (context, ss) {
                if (ss.hasData) {
                  var workouts = ss.data! as List<Workout>;
                  if (workouts.isNotEmpty) {
                    List<Widget> columnContent = [];
                    for (int i = 0; i < workouts.length; i++) {
                      cardKeys.add(GlobalKey());
                      columnContent.add(Padding(
                          padding: const EdgeInsets.all(16.0),
                          child:
                              WorkoutCard(workouts[i], (startAsClosed) async {
                            WorkoutCard workoutCard = WorkoutCard(
                              workouts[i],
                              (startAsClosed) async {},
                              true,
                            );
                            await Navigator.push(context,
                                blurredMenuBuilder(workoutCard, cardKeys[i]));
                          }, false, key: cardKeys[i])));
                    }
                    return Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                      children: columnContent,
                    )));
                  } else {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                            child: Text(
                          Helper.loadTranslation(context, 'workoutListWelcome'),
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    );
                  }
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
        Positioned(bottom: 16, right: 16, child: buildFAB()),
      ],
    );
  }

  PageRouteBuilder blurredMenuBuilder(WorkoutCard workoutCard, GlobalKey key) {
    ref.read(Helper.blurProvider.notifier).setBlur(1);
    return PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, a1, a2) {
          return MenuWorkoutCard(
              positionedAnimationDuration: const Duration(milliseconds: 150),
              workoutCardKey: key,
              workoutCard: workoutCard,
              deleteOnPressed: () async {
                isButtonPressed = true;
                await CustomDatabase.instance
                    .removeWorkout(workoutCard.workout.id);
                ref.read(Helper.workoutsProvider.notifier).refreshWorkouts();
                await Navigator.maybePop(context);
                isButtonPressed = false;
                return;
              },
              cancelOnPressed: () {
                Navigator.maybePop(context);
              });
        });
  }
}
