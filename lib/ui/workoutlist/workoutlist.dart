import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/ui/newworkout.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/widgets.dart';
import 'package:lift_tracker/ui/workoutlist/workoutcard.dart';
import 'package:lift_tracker/ui/workoutlist/menuworkoutcard.dart';

import '../../data/exercise.dart';

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
    workoutsFuture.then((value) {
      if (Helper.firstAppRun) {
        Helper.firstAppRun = false;
        Future.delayed(Duration.zero, () {
          List<Exercise> exercises = [
            Exercise(
                id: 0,
                name: "Panca inclinata manubri",
                sets: 4,
                reps: 10,
                workoutId: 0),
            Exercise(
                id: 1,
                name: "Croci ai cavi alti",
                sets: 4,
                reps: 10,
                workoutId: 0),
            Exercise(
                id: 2, name: "Shoulder press", sets: 3, reps: 12, workoutId: 0),
            Exercise(
                id: 3,
                name: "Alzate laterali cavi",
                sets: 5,
                reps: 12,
                workoutId: 0),
            Exercise(
                id: 4, name: "Pushdown corda", sets: 4, reps: 12, workoutId: 0),
            Exercise(
                id: 5,
                name: "French press cavi",
                sets: 4,
                reps: 12,
                workoutId: 0)
          ];
          CustomDatabase.instance
              .createWorkout("Push", exercises)
              .then((value) {
            exercises.clear();
            exercises = [
              Exercise(
                  id: 0, name: "Lat machine", sets: 4, reps: 10, workoutId: 0),
              Exercise(
                  id: 1, name: "Pulley basso", sets: 4, reps: 10, workoutId: 0),
              Exercise(
                  id: 2,
                  name: "Hyperextension",
                  sets: 3,
                  reps: 20,
                  workoutId: 0),
              Exercise(
                  id: 3,
                  name: "Alzate laterali 90",
                  sets: 5,
                  reps: 12,
                  workoutId: 0),
              Exercise(
                  id: 4, name: "Curl manubri", sets: 3, reps: 12, workoutId: 0),
              Exercise(
                  id: 5,
                  name: "Curl martello",
                  sets: 3,
                  reps: 12,
                  workoutId: 0),
              Exercise(
                  id: 6,
                  name: "Curl panca inclinata",
                  sets: 3,
                  reps: 12,
                  workoutId: 0)
            ];
            CustomDatabase.instance
                .createWorkout("Pull", exercises)
                .then((value) {
              exercises.clear();
              exercises = [
                Exercise(
                    id: 0, name: "Hack squat", sets: 5, reps: 10, workoutId: 0),
                Exercise(
                    id: 1,
                    name: "Leg exensions",
                    sets: 5,
                    reps: 10,
                    workoutId: 0),
                Exercise(
                    id: 2,
                    name: "Stacchi gambe tese",
                    sets: 5,
                    reps: 10,
                    workoutId: 0),
                Exercise(
                    id: 3, name: "Leg curl", sets: 5, reps: 10, workoutId: 0),
                Exercise(
                    id: 4,
                    name: "Calf pressa",
                    sets: 5,
                    reps: 20,
                    workoutId: 0),
              ];
              CustomDatabase.instance
                  .createWorkout('Legs', exercises)
                  .then((value) {
                ref.read(Helper.workoutsProvider.notifier).refreshWorkouts();
              });
            });
          });
        });
      }
    });
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.search_outlined,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                        child: TextField(
                      readOnly: false,
                      decoration: InputDecoration(border: InputBorder.none),
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )),
                  ],
                ),
              ),
            ),
            FutureBuilder(
              future: workoutsFuture,
              builder: (context, ss) {
                if (ss.hasData) {
                  var workouts = ss.data! as List<Workout>;
                  List<Widget> columnContent = [];
                  for (int i = 0; i < workouts.length; i++) {
                    cardKeys.add(GlobalKey());
                    columnContent.add(Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: WorkoutCard(workouts[i], (startAsClosed) async {
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
