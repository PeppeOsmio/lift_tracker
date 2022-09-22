import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/app/app.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/android_ui/widgets/customanimatedicon.dart';
import 'package:lift_tracker/android_ui/app/customdrawer.dart';
import 'package:lift_tracker/android_ui/workoutlist/workoutcard.dart';
import 'package:lift_tracker/android_ui/workouts/editworkout.dart';
import 'package:lift_tracker/android_ui/workouts/newworkout.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/android_ui/newsession/newsession.dart';

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
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    log('Building WorkoutList...');
    CustomDatabase.instance.readWorkouts(readAll: true).then((value) {
      // remove circular progress indicator
      animatedListKey.currentState!.removeItem(
          0,
          (context, animation) => SizedBox(
                height: 0,
              ),
          duration: Duration.zero);
      ref.read(Helper.instance.workoutsProvider.notifier).addListener((state) {
        if (state.length > workouts.length) {
          for (int i = workouts.length; i < state.length; i++) {
            animatedListKey.currentState!
                .insertItem(i, duration: Duration(milliseconds: 150));
          }
        }
      });
      ref.read(Helper.instance.workoutsProvider.notifier).addWorkouts(value);
      log('Workouts from workout list: ' + value.toString());
    });
  }

  void removeWorkoutCard(int index) {}

  @override
  Widget build(BuildContext context) {
    workouts = ref.watch(Helper.instance.workoutsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isAppBarSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        leading: IconButton(
          onPressed: () {
            if (isSearchBarActivated) {
              setState(() {
                resetAppBarAndOpenCards();
              });
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
            curve: Curves.linear,
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
                        IconButton(
                            onPressed: () {
                              if (openIndex != null) {
                                var editWorkoutPage =
                                    EditWorkout(workout: workouts[openIndex!]);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return editWorkoutPage;
                                }));
                                setState(() {
                                  resetAppBarAndOpenCards();
                                });
                              }
                            },
                            icon: Icon(Icons.edit)),
                        IconButton(
                            onPressed: () {
                              if (openIndex != null) {
                                var newSessionPage =
                                    NewSession(workout: workouts[openIndex!]);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return newSessionPage;
                                }));
                                setState(() {
                                  resetAppBarAndOpenCards();
                                });
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
          curve: Curves.linear,
          duration: Duration(milliseconds: 150),
          child: isSearchBarActivated && !isAppBarSelected
              ? TextField(
                  onChanged: (newValue) {
                    setState(() {
                      searchString = newValue;
                    });
                  },
                  style: UIUtilities.getTextFieldTextStyle(context),
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
      ),
      drawer: isAppBarSelected || isSearchBarActivated ? null : CustomDrawer(),
      body: GestureDetector(
        onTap: () {
          setState(() {
            resetAppBarAndOpenCards();
          });
        },
        child: AnimatedList(
            key: animatedListKey,
            // show circular progress indicator if we did not yet read workouts
            initialItemCount: CustomDatabase.instance.didReadWorkouts ? 0 : 1,
            itemBuilder: (context, index, animation) {
              if (!CustomDatabase.instance.didReadWorkouts) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }
              if (!workouts[index]
                  .name
                  .toLowerCase()
                  .contains(searchString.toLowerCase())) {
                return SizedBox();
              }
              return FadeTransition(
                opacity: animation,
                child: WorkoutCard(
                    isOpen: openIndex == index,
                    workout: workouts[index],
                    onCardTap: () {
                      if (openIndex != null && openIndex == index) {
                        setState(() {
                          resetAppBarAndOpenCards();
                        });
                      } else {
                        selectWorkout(index);
                      }
                    }),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: -4,
        onPressed: () async {
          resetAppBarAndOpenCards();
          setState(() {});
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
    isAppBarSelected = false;
    isSearchBarActivated = false;
    searchString = '';
    searchController.text = '';
    openIndex = null;
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
      animatedListKey.currentState!
          .removeItem(workouts.indexWhere((element) => element.id == workoutId),
              (context, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child:
                WorkoutCard(isOpen: true, workout: workout, onCardTap: () {}),
          ),
        );
      }, duration: Duration(milliseconds: 150));
      ref
          .read(Helper.instance.workoutsProvider.notifier)
          .removeWorkout(workoutId);
    }
    return workout;
  }
}
