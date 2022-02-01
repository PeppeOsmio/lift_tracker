import 'package:flutter/material.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/data/excercise.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({Key? key}) : super(key: key);

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  List<Excercise> excercises = [
    Excercise(1, "Bench press", 5, 5, type: "slow eccentric"),
    Excercise(2, "French Press", 4, 8),
    Excercise(3, "Lat machine", 5, 5),
    Excercise(4, "Bent-over row", 5, 10)
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
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
            child: ListView(
              children: [
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: WorkoutCard(Workout(1, "Petto", excercises))),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: WorkoutCard(Workout(2, "Gambe", excercises))),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: WorkoutCard(Workout(3, "Dorso", excercises))),
              ],
            ),
          ),
        ],
      ),
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
          )
          //Text(widget.excercises[i], style: const TextStyle(fontSize: 15, color: Colors.white)),
          ));
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
        decoration: const BoxDecoration(
          color: const Color.fromARGB(255, 31, 31, 31),
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
