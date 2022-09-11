import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/classes/workouthistory.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/old_ui/styles.dart';
import 'package:lift_tracker/old_ui/workouts/newworkout.dart';
import 'package:lift_tracker/old_ui/widgets.dart';
import 'package:lift_tracker/old_ui/workoutlist/workoutcard.dart';
import 'package:lift_tracker/old_ui/workoutlist/menuworkoutcard.dart';

class WorkoutList extends ConsumerStatefulWidget {
  const WorkoutList({Key? key}) : super(key: key);

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends ConsumerState<WorkoutList> {
  ColorScheme colorScheme = Helper.instance.colorSchemeDark;
  List<Workout> workouts = [];
  bool isButtonPressed = false;
  List<Size> cardSized = [];
  List<GlobalKey> cardKeys = [];
  List<bool> hasHistory = [];
  @override
  void initState() {
    super.initState();
    CustomDatabase.instance.readWorkouts().then((workouts) {
      ref.read(Helper.instance.workoutsProvider.notifier).addWorkouts(workouts);
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'workoutlist: ' + error.toString());
    });
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
              UIUtilities.unfocusTextFields(context);
              var route =
                  MaterialPageRoute(builder: (context) => const NewWorkout());
              await Navigator.push(context, route)
                  .then((value) {})
                  .catchError((error) {
                Fluttertoast.showToast(msg: 'workoutlist: ' + error.toString());
              });
            },
            backgroundColor: colorScheme.surface,
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Icon(Icons.add_outlined,
                size: 24, color: colorScheme.onBackground),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    workouts = ref.watch(Helper.instance.workoutsProvider);
    return Stack(
      children: [
        Column(
          children: [
            workouts.isNotEmpty
                ? Body(
                    workouts: workouts, readMoreCallback: readMoreAndUpdateUI)
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Text(
                        UIUtilities.loadTranslation(
                            context, 'workoutListWelcome'),
                        style: TextStyle(color: colorScheme.onPrimary),
                        textAlign: TextAlign.center,
                      )),
                    ),
                  )
          ],
        ),
      ],
    );
  }

  void readMoreAndUpdateUI() {
    CustomDatabase.instance.readWorkouts().then((workouts) {
      ref.read(Helper.instance.workoutsProvider.notifier).addWorkouts(workouts);
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'workoutlist: ' + error.toString());
    });
  }
}

class Body extends ConsumerStatefulWidget {
  const Body({Key? key, required this.workouts, required this.readMoreCallback})
      : super(key: key);
  final List<Workout> workouts;
  final Function readMoreCallback;

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
            hint: UIUtilities.loadTranslation(context, 'filter'),
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
              itemBuilder: (context, i) {
                if ((i + 1).remainder(CustomDatabase.instance.searchLimit) ==
                        0 &&
                    (i + 1) ~/ CustomDatabase.instance.searchLimit >
                        (CustomDatabase.instance.workoutsOffset - 1)) {
                  widget.readMoreCallback();
                }
                return columnContent[i];
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
              hasCache: workoutCard.workout.hasCache,
              positionedAnimationDuration: const Duration(milliseconds: 150),
              workoutCardKey: key,
              workoutCard: workoutCard,
              deleteOnPressed: () async {
                bool didRemove = false;
                await CustomDatabase.instance
                    .removeWorkout(workoutCard.workout.id)
                    .then((response) {
                  didRemove = response;
                }).catchError((error) {
                  Fluttertoast.showToast(
                      msg: 'workoutlist: ' + error.toString());
                });
                if (didRemove) {
                  ref
                      .read(Helper.instance.workoutsProvider.notifier)
                      .removeWorkout(workoutCard.workout.id);
                }
                await Navigator.maybePop(context);
              },
              cancelOnPressed: () {
                Navigator.maybePop(context);
              });
        });
  }
}
