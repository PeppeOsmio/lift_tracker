import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/classes/workouthistory.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/ui/styles.dart';
import 'package:lift_tracker/ui/workouts/newworkout.dart';
import 'package:lift_tracker/ui/widgets.dart';
import 'package:lift_tracker/ui/workoutlist/workoutcard.dart';
import 'package:lift_tracker/ui/workoutlist/menuworkoutcard.dart';

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
  List<bool> hasHistory = [];
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
            FutureBuilder(
              future: workoutsFuture,
              builder: (context, ss) {
                if (ss.hasData) {
                  List<Workout> workouts = [];
                  workouts.addAll(ss.data! as List<Workout>);

                  if (workouts.isNotEmpty) {
                    return Body(workouts: workouts);
                  } else {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                            child: Text(
                          Helper.loadTranslation(context, 'workoutListWelcome'),
                          style: Styles.style(dark: true, fontSize: 20),
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
}

class Body extends ConsumerStatefulWidget {
  const Body({Key? key, required this.workouts}) : super(key: key);
  final List<Workout> workouts;

  @override
  ConsumerState<Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<Body> {
  List<GlobalKey> cardKeys = [];
  TextEditingController searchController = TextEditingController();
  List<Workout> workouts = [];

  @override
  void initState() {
    super.initState();
    workouts = widget.workouts;
    log('Initting body ' + widget.workouts.toString());
  }

  @override
  void didUpdateWidget(covariant Body oldWidget) {
    super.didUpdateWidget(oldWidget);
    workouts = widget.workouts;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnContent = [];
    for (int i = 0; i < workouts.length; i++) {
      cardKeys.add(GlobalKey());
      columnContent.add(Padding(
          padding: const EdgeInsets.all(16.0),
          child: WorkoutCard(workouts[i], (startAsClosed) async {
            bool hasHistory =
                await CustomDatabase.instance.hasHistory(workouts[i].id);
            WorkoutCard workoutCard = WorkoutCard(
              workouts[i],
              (startAsClosed) async {},
              true,
            );
            await Navigator.push(context,
                blurredMenuBuilder(workoutCard, cardKeys[i], hasHistory));
          }, false, key: cardKeys[i])));
    }
    return Expanded(
        child: Column(
      children: [
        SearchBar(
            hint: Helper.loadTranslation(context, 'filter'),
            textController: searchController,
            onTextChange: (change) {
              List<Workout> temp = [];
              if (change.isEmpty) {
                workouts = widget.workouts;
                setState(() {});
                return;
              }
              for (Workout data in widget.workouts) {
                if (data.name.toLowerCase().contains(change.toLowerCase())) {
                  temp.add(data);
                }
              }
              workouts = temp;
              setState(() {});
            }),
        Expanded(
          child: ListView.builder(
              itemCount: columnContent.length,
              itemBuilder: (context, index) {
                return columnContent[index];
              }),
        )
      ],
    ));
  }

  PageRouteBuilder blurredMenuBuilder(
      WorkoutCard workoutCard, GlobalKey key, bool hasHistory) {
    return PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, a1, a2) {
          return MenuWorkoutCard(
              hasHistory: hasHistory,
              positionedAnimationDuration: const Duration(milliseconds: 150),
              workoutCardKey: key,
              workoutCard: workoutCard,
              deleteOnPressed: () async {
                await CustomDatabase.instance
                    .removeWorkout(workoutCard.workout.id);
                ref.read(Helper.workoutsProvider.notifier).refreshWorkouts();
                await Navigator.maybePop(context);
                //somehow necessary to clear to trigger init state again...
                return;
              },
              cancelOnPressed: () {
                Navigator.maybePop(context);
              });
        });
  }
}
