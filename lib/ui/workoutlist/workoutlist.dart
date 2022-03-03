import 'package:flutter/material.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/ui/newworkout.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/widgets.dart';
import 'package:lift_tracker/ui/workoutlist/workoutcard.dart';
import 'package:lift_tracker/ui/workoutlist/menuworkoutcard.dart';

import '../../data/excercise.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({Key? key}) : super(key: key);

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  late Future<List<Workout>> workoutsFuture;
  bool isButtonPressed = false;
  List<Size> cardSized = [];
  List<GlobalKey> cardKeys = [];

  @override
  void initState() {
    super.initState();
    workoutsFuture = CustomDatabase.instance.readWorkouts();
    workoutsFuture.then((value) {
      if (Helper.firstAppRun) {
        Helper.firstAppRun = false;
        Future.delayed(Duration.zero, () {
          List<Excercise> excercises = [
            Excercise(
                id: 0, name: "Panca inclinata manubri", sets: 4, reps: 10),
            Excercise(id: 1, name: "Croci ai cavi alti", sets: 4, reps: 10),
            Excercise(id: 2, name: "Shoulder press", sets: 3, reps: 12),
            Excercise(id: 3, name: "Alzate laterali cavi", sets: 5, reps: 12),
            Excercise(id: 4, name: "Pushdown corda", sets: 4, reps: 12),
            Excercise(id: 5, name: "French press cavi", sets: 4, reps: 12)
          ];
          CustomDatabase.instance
              .createWorkout("Push", excercises)
              .then((value) {
            setState(() {});
            excercises.clear();
            excercises = [
              Excercise(id: 0, name: "Lat machine", sets: 4, reps: 10),
              Excercise(id: 1, name: "Pulley basso", sets: 4, reps: 10),
              Excercise(id: 2, name: "Hyperextension", sets: 3, reps: 20),
              Excercise(id: 3, name: "Alzate laterali 90", sets: 5, reps: 12),
              Excercise(id: 4, name: "Curl manubri", sets: 3, reps: 12),
              Excercise(id: 5, name: "Curl martello", sets: 3, reps: 12),
              Excercise(id: 6, name: "Curl panca inclinata", sets: 3, reps: 12)
            ];
            CustomDatabase.instance
                .createWorkout("Pull", excercises)
                .then((value) {
              setState(() {});
            });
          });
        });
      }
    });
  }

  Widget buildFAB() {
    return SizedBox(
      height: 65,
      width: 65,
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
                      readOnly: false,
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
                          if (Helper.didSetWeightRecord) {
                            Helper.didSetWeightRecord = false;
                            workoutsFuture =
                                CustomDatabase.instance.readWorkouts();
                            workouts = await workoutsFuture;
                            setState(() {});
                          }
                          WorkoutCard workoutCard = WorkoutCard(
                            workouts[i],
                            (startAsClosed) {},
                            true,
                          );
                          await Navigator.push(context,
                              blurredMenuBuilder(workoutCard, cardKeys[i], i));
                          workoutsFuture =
                              CustomDatabase.instance.readWorkouts();
                          workouts = await workoutsFuture;
                          setState(() {});
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

  PageRouteBuilder blurredMenuBuilder(
      WorkoutCard workoutCard, GlobalKey key, int tag) {
    return PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 00),
        opaque: false,
        pageBuilder: (context, a1, a2) {
          return MenuWorkoutCard(
              positionedAnimationDuration: const Duration(milliseconds: 200),
              workoutCardKey: key,
              workoutCard: workoutCard,
              deleteOnPressed: () async {
                isButtonPressed = true;
                await CustomDatabase.instance
                    .removeWorkout(workoutCard.workout.id);
                workoutsFuture = CustomDatabase.instance.readWorkouts();
                Navigator.maybePop(context);
                setState(() {});
                isButtonPressed = false;

                return;
              },
              cancelOnPressed: () {
                Navigator.maybePop(context);
              });
        });
  }
}
