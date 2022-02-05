import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/newworkout.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/widgets.dart';

List<GlobalKey> cardKeys = [];

class WorkoutList extends StatefulWidget {
  const WorkoutList({Key? key}) : super(key: key);

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  late Future<List<Workout>> workoutsFuture;
  bool isButtonPressed = false;
  List<Size> cardSized = [];

  @override
  void initState() {
    super.initState();
    workoutsFuture = CustomDatabase.instance.readWorkouts();
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
                      child: WorkoutCard(workouts[i], (startAsClosed) {
                        WorkoutCard workoutCard = WorkoutCard(
                          workouts[i],
                          (startAsClosed) {},
                          true,
                          startAsClosed,
                          key: GlobalKey(),
                        );
                        Navigator.push(context,
                            blurredMenuBuilder(workoutCard, cardKeys[i]));
                      }, false, false, key: cardKeys[i]),
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

  PageRouteBuilder blurredMenuBuilder(WorkoutCard workoutCard, GlobalKey key) {
    return PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, a1, a2) {
          var box = key.currentContext!.findRenderObject() as RenderBox;
          var dy = box.localToGlobal(Offset.zero).dy;

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: MediaQuery.of(context).size.height - dy,
                    child: AnimatedEntry(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, right: 8),
                            child: GestureDetector(
                              onTap: () async {
                                if (!isButtonPressed) {
                                  isButtonPressed = true;
                                  await CustomDatabase.instance
                                      .removeWorkout(workoutCard.workout.id);
                                  workoutsFuture =
                                      CustomDatabase.instance.readWorkouts();
                                  Navigator.pop(context);
                                  setState(() {});
                                  isButtonPressed = false;
                                }
                                return;
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(25),
                                    border: Border.all(
                                        color: Palette.backgroundDark),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                  width: 70,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(25),
                                      border:
                                          Border.all(color: Colors.redAccent),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Center(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Palette.backgroundDark,
                                      border: Border.all(
                                          color: Palette.backgroundDark),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                    width: 70,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.green.withAlpha(25),
                                        border: Border.all(color: Colors.green),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: dy,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Center(child: workoutCard),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class WorkoutCard extends StatefulWidget {
  const WorkoutCard(
      this.workout, this.onLongPress, this.removeMode, this.startAsClosed,
      {Key? key})
      : super(key: key);

  final Workout workout;
  final void Function(bool) onLongPress;
  final bool removeMode;
  final bool startAsClosed;

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  bool isOpen = false;
  bool isButtonPressed = false;
  late bool _removeMode;

  @override
  void initState() {
    super.initState();
    _removeMode = widget.removeMode;
    if (widget.removeMode == true && widget.startAsClosed) {
      Future.delayed(const Duration(seconds: 0), () {
        isOpen = true;
        setState(() {});
      });
    } else if (_removeMode) {
      isOpen = true;
    }
  }

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
    if (excercises.length <= 2) {
      stop = excercises.length;
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
    if (!isOpen && excercises.length > 2) {
      exc.add(const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Text("...", style: TextStyle(fontSize: 15, color: Colors.white)),
      ));
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 100),
      child: Column(
        children: [
          /*Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, right: 8),
                      child: GestureDetector(
                        onTap: () async {
                          //widget.onRemove.call();
                        },
                        child: Container(
                          height: 34,
                          width: 70,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.red.withAlpha(25),
                              border: Border.all(color: Colors.redAccent),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Center(
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            _removeMode = false;
                            isOpen = false;
                            setState(() {});
                          },
                          child: Container(
                            height: 34,
                            width: 70,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.green.withAlpha(25),
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        )),
                  ],
                )*/
          GestureDetector(
            onTap: () {
              if (!_removeMode) {
                isOpen = !isOpen;
                setState(() {});
              }
            },
            onLongPress: () {
              widget.onLongPress.call(!isOpen);
              if (!isOpen) {
                setState(() {
                  isOpen = true;
                });
              }
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
                      Row(
                        children: [
                          Text(widget.workout.name,
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white)),
                          const Spacer(),
                          isOpen || _removeMode
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
          ),
        ],
      ),
    );
  }
}
