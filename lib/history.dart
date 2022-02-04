import 'package:flutter/material.dart';
import 'package:lift_tracker/data/excercise.dart';
import 'package:lift_tracker/data/workout.dart';
import 'package:lift_tracker/ui/colors.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
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
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: WorkoutCard(
                        Workout(0, "Petto", [Excercise(0, "Panca", 4, 10)]),
                        () {})),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutCard extends StatefulWidget {
  const WorkoutCard(this.workout, this.onRemove, {Key? key}) : super(key: key);

  final Workout workout;
  final VoidCallback onRemove;

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  bool isOpen = false;
  bool isButtonPressed = false;
  bool _removeMode = false;

  @override
  void initState() {
    super.initState();
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
    if (excercises.isEmpty) {
      stop = 0;
    }
    for (int i = 0; i < stop; i++) {
      String name = excercises[i].name;
      if (excercises[i].type != null) {
        name += " (${excercises[i].type!})";
      }
      exc.add(Table(
        children: const [],
      )
          /*Padding(
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
          ))*/
          );
    }
    if (!isOpen) {
      exc.add(const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Text("...", style: TextStyle(fontSize: 15, color: Colors.white)),
      ));
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 100),
      child: Column(
        children: [
          _removeMode
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, right: 8),
                      child: GestureDetector(
                        onTap: () async {
                          widget.onRemove.call();
                        },
                        child: Container(
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
                )
              : const SizedBox(),
          GestureDetector(
            onTap: () {
              if (!_removeMode) {
                isOpen = !isOpen;
                setState(() {});
              }
            },
            onLongPress: () {
              isOpen = true;
              _removeMode = true;
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
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.calendar_today, color: Palette.orange),
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                "Wedsnday, February 2, 2022",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              isOpen
                                  ? Icons.expand_less_outlined
                                  : Icons.expand_more_outlined,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(widget.workout.name,
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white)),
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
