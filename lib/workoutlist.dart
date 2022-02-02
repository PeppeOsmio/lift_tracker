import 'package:flutter/material.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/newworkout.dart';
import 'package:lift_tracker/ui/colors.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({Key? key}) : super(key: key);

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  List<Workout> workouts = [];

  @override
  void initState() {
    super.initState();
    CustomDatabase.instance.readWorkouts().then((value) {
      setState(() {
        workouts.addAll(value);
      });
    });
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
                workouts.clear();
                workouts.addAll(value);
              });
            });
          });
        },
        heroTag: "0",
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
            Expanded(
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: WorkoutCard(workouts[index]),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox();
                    },
                    itemCount: workouts.length)),
          ],
        ),
        Positioned(bottom: 16, right: 16, child: buildFAB()),
      ],
    );
  }
}

class WorkoutCard extends StatefulWidget {
  const WorkoutCard(this.workout, {Key? key}) : super(key: key);

  final Workout workout;

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    var excercises = widget.workout.excercises;
    List<Widget> exc = [];
    int stop;
    if (isOpen) {
      stop = excercises.length;
    } else {
      stop = 1;
    }
    if (excercises.isEmpty) {
      stop = 0;
    }
    for (int i = 0; i < stop; i++) {
      String name = excercises[i].name;
      if (excercises[i].type != null) {
        name += " (${excercises[i].type!})";
      }
      exc.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(name,
                    style: const TextStyle(fontSize: 15, color: Colors.white)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                    excercises[i].sets.toString() +
                        "  ×  " +
                        excercises[i].reps.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ],
          )));
    }
    if (!isOpen) {
      exc.add(const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Text("...", style: TextStyle(fontSize: 15, color: Colors.white)),
      ));
    }
    return GestureDetector(
      onTap: () {
        isOpen = !isOpen;
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Palette.elementsDark,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          //border: Border.all(color: const Color.fromARGB(255, 50, 50, 50))
        ),
        child: AnimatedSize(
          curve: Curves.linear,
          duration: const Duration(milliseconds: 100),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    children: [
                      Text(widget.workout.name,
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white)),
                      const Spacer(),
                      isOpen
                          ? const Icon(
                              Icons.expand_less_outlined,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.expand_more_outlined,
                              color: Colors.white,
                            )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: exc),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
