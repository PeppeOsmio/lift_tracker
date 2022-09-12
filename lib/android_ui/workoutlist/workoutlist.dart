import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/app/app.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/android_ui/widgets/customanimatedicon.dart';
import 'package:lift_tracker/android_ui/app/customdrawer.dart';
import 'package:lift_tracker/android_ui/workoutlist/workoutcard.dart';
import 'package:lift_tracker/android_ui/workouts/newworkout.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/android_ui/sessions/newsession.dart';

class WorkoutList extends ConsumerStatefulWidget {
  const WorkoutList({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends ConsumerState<WorkoutList> {
  List<Workout> workouts = [];
  int? openIndex;
  Color? selectedColor;
  Color? selectedTextColor;
  Color? selectedAppBarColor;
  bool isAppBarSelected = false;
  bool isSearchBarActivated = false;
  TextEditingController searchController = TextEditingController();
  String searchString = '';
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    log('Building WorkoutList...');
    CustomDatabase.instance.readWorkouts().then((value) {
      ref.read(Helper.instance.workoutsProvider.notifier).addWorkouts(value);
      log('Workouts from workout list: ' + value.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    workouts = ref.watch(Helper.instance.workoutsProvider);
    return Scaffold(
      backgroundColor: UIUtilities.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (isSearchBarActivated) {
              resetAppBarAndOpenCards();
            } else {
              mainScaffoldKey.currentState!.openDrawer();
            }
          },
          icon: CustomAnimatedIcon(
              animatedIconData: AnimatedIcons.arrow_menu,
              start: !isSearchBarActivated),
        ),
        actions: [
          AnimatedSize(
            curve: Curves.decelerate,
            duration: Duration(milliseconds: 150),
            child: Row(
                children: isAppBarSelected
                    ? [
                        IconButton(
                            onPressed: () {
                              if (openIndex != null) {
                                deleteWorkout(workouts[openIndex!].id)
                                    .catchError((error) {
                                  UIUtilities.showSnackBar(
                                      context: context,
                                      msg: UIUtilities.loadTranslation(
                                              context, 'error') +
                                          ': $error');
                                });
                              }
                            },
                            icon: Icon(Icons.delete)),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.history_rounded)),
                        IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                        IconButton(
                            onPressed: () {
                              if (openIndex != null) {
                                var newSessionPage =
                                    NewSession(workout: workouts[openIndex!]);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return newSessionPage;
                                }));
                                resetAppBarAndOpenCards();
                              }
                            },
                            icon: Icon(Icons.play_arrow))
                      ]
                    : [
                        IconButton(
                            onPressed: () {
                              if (isSearchBarActivated) {
                                setState(() {
                                  searchController.text = '';
                                  searchString = '';
                                });
                              } else {
                                openSearchBar();
                              }
                            },
                            icon: Icon(isSearchBarActivated
                                ? Icons.close
                                : Icons.search))
                      ]),
          )
        ],
        title: AnimatedSize(
          curve: Curves.decelerate,
          duration: Duration(milliseconds: 150),
          child: isSearchBarActivated && !isAppBarSelected
              ? TextField(
                  onChanged: (newValue) {
                    setState(() {
                      searchString = newValue;
                    });
                  },
                  focusNode: searchFocusNode,
                  controller: searchController,
                  decoration: InputDecoration(
                      hintText: UIUtilities.loadTranslation(
                          context, 'searchWorkouts'),
                      border: InputBorder.none),
                )
              : Text(isAppBarSelected && openIndex != null
                  ? workouts[openIndex!].name
                  : UIUtilities.loadTranslation(context, 'workouts')),
        ),
        backgroundColor: isAppBarSelected
            ? UIUtilities.getSelectedAppBarColor(context)
            : UIUtilities.getAppBarColor(context),
      ),
      drawer: isAppBarSelected || isSearchBarActivated ? null : CustomDrawer(),
      body: GestureDetector(
        onTap: () {
          resetAppBarAndOpenCards();
        },
        child: ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              if (!workouts[index]
                  .name
                  .toLowerCase()
                  .contains(searchString.toLowerCase())) {
                return SizedBox();
              }
              return WorkoutCard(
                  color: openIndex == index
                      ? UIUtilities.getSelectedWidgetColor(context)
                      : null,
                  textColor: openIndex == index
                      ? UIUtilities.getSelectedTextColor(context)
                      : null,
                  isOpen: openIndex == index,
                  workout: workouts[index],
                  onCardTap: () {
                    if (openIndex != null && openIndex == index) {
                      resetAppBarAndOpenCards();
                    } else {
                      selectWorkout(index);
                    }
                  });
            }),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: -4,
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) {
            return NewWorkout();
          }));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void resetAppBarAndOpenCards() {
    setState(() {
      isAppBarSelected = false;
      isSearchBarActivated = false;
      openIndex = null;
    });
  }

  void openSearchBar() {
    setState(() {
      isSearchBarActivated = true;
      searchFocusNode.requestFocus();
    });
  }

  void selectWorkout(int index) {
    setState(() {
      openIndex = index;
      isAppBarSelected = true;
      isSearchBarActivated = false;
    });
  }

  Future<Workout> deleteWorkout(int workoutId) async {
    Workout workout =
        workouts.where((workout) => workout.id == workoutId).first;
    bool success = await CustomDatabase.instance.removeWorkout(workoutId);
    if (success) {
      resetAppBarAndOpenCards();
      ref
          .read(Helper.instance.workoutsProvider.notifier)
          .removeWorkout(workoutId);
    }
    return workout;
  }
}
