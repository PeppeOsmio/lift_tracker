import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lift_tracker/data/constants.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/newworkout.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/widgets.dart';
import 'package:lift_tracker/ui/workoutcard.dart';

import 'data/excercise.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({required this.navBarKey, Key? key}) : super(key: key);
  final GlobalKey navBarKey;

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  late Future<List<Workout>> workoutsFuture;
  bool isButtonPressed = false;
  List<Size> cardSized = [];
  List<GlobalKey> cardKeys = [];
  double navBarOffset = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () {
      RenderBox box =
          widget.navBarKey.currentContext!.findRenderObject() as RenderBox;
      navBarOffset = box.size.height;
    });
    workoutsFuture = CustomDatabase.instance.readWorkouts();
    /*List<Excercise> debug = [];

    for (int i = 0; i < 6; i++) {
      debug.add(Excercise(i, "debug$i", 4, 10));
    }
    CustomDatabase.instance.createWorkout("Push 1", debug).then((value) {
      setState(() {
        workoutsFuture = CustomDatabase.instance.readWorkouts();
      });
    });*/
  }

  Widget buildFAB() {
    return SizedBox(
      height: 65,
      width: 65,
      child: FloatingActionButton(
        onPressed: () async {
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
        heroTag: "-1",
        backgroundColor: Colors.black,
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: FittedBox(
          child: Icon(Icons.add_outlined, color: Palette.orange),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      decoration: InputDecoration(border: InputBorder.none),
                      style: TextStyle(color: Colors.white, fontSize: 25),
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
                          (startAsClosed) {},
                          true,
                        );
                        await Navigator.push(context,
                                blurredMenuBuilder(workoutCard, cardKeys[i], i))
                            .then((value) {});
                      }, false, key: cardKeys[i]),
                    ));
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

  PageRouteBuilder blurredMenuBuilder(
      WorkoutCard workoutCard, GlobalKey key, int tag) {
    return PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        opaque: false,
        pageBuilder: (context, a1, a2) {
          return MenuWorkoutCard(
              positionedAnimationDuration: const Duration(milliseconds: 200),
              workoutCardKey: key,
              workoutCard: workoutCard,
              heroTag: tag,
              deleteOnPressed: () async {
                if (!isButtonPressed) {
                  isButtonPressed = true;
                  await CustomDatabase.instance
                      .removeWorkout(workoutCard.workout.id);
                  workoutsFuture = CustomDatabase.instance.readWorkouts();
                  Navigator.maybePop(context);
                  setState(() {});
                  isButtonPressed = false;
                }
                return;
              },
              cancelOnPressed: () {
                Navigator.maybePop(context);
              });
        });
  }
}
