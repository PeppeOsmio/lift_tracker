import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/exercises/selectexercise.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/android_ui/workouts/newexercisecard.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';

class EditWorkout extends ConsumerStatefulWidget {
  const EditWorkout({Key? key, required this.workout}) : super(key: key);
  final Workout workout;

  @override
  ConsumerState<EditWorkout> createState() => _EditWorkoutState();
}

enum MoveOrRemoveMenuOption { remove, move_up, move_down }

class _EditWorkoutState extends ConsumerState<EditWorkout> {
  TextEditingController workoutNameController = TextEditingController();
  List<ExerciseData?> exerciseDataList = [];
  List<Exercise?> exercises = [];
  List<TextEditingController> setsControllers = [];
  List<TextEditingController> repsControllers = [];
  bool canSave = false;
  final GlobalKey<AnimatedListState> animatedListKey =
      GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyWidgets = body();
    return WillPopScope(
      onWillPop: () async {
        UIUtilities.showDimmedBackgroundDialog(context,
            title: UIUtilities.loadTranslation(context, 'discard'),
            content: UIUtilities.loadTranslation(context, 'discardContent'),
            leftText: UIUtilities.loadTranslation(context, 'discardNo'),
            rightText: UIUtilities.loadTranslation(context, 'discardYes'),
            leftOnPressed: () {
          Navigator.maybePop(context);
        }, rightOnPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.maybePop(context);
              /*showDialog(
                  useRootNavigator: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title:
                          Text(UIUtilities.loadTranslation(context, 'discard')),
                      content: Text(
                          UIUtilities.loadTranslation(context, 'discardContent')),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(UIUtilities.loadTranslation(
                                context, 'keepThem'))),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(UIUtilities.loadTranslation(
                                context, 'yesDiscard')))
                      ],
                    );
                  });*/
            },
          ),
          title: Text("${UIUtilities.loadTranslation(context, 'editWorkout')}"),
          actions: [
            AnimatedSize(
              duration: Duration(milliseconds: 150),
              curve: Curves.decelerate,
              child: Row(children: [
                canSave
                    ? IconButton(
                        tooltip: 'Save',
                        onPressed: () {
                          saveWorkout().then((value) {
                            Navigator.pop(context);
                          }).catchError((error) {
                            UIUtilities.showSnackBar(
                                context: context,
                                msg: UIUtilities.loadTranslation(
                                        context, 'error') +
                                    ': $error');
                          });
                        },
                        icon: Icon(Icons.done))
                    : SizedBox()
              ]),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            UIUtilities.unfocusTextFields(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedList(
              key: animatedListKey,
              initialItemCount: bodyWidgets.length,
              itemBuilder: ((context, index, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: FadeTransition(
                      opacity: animation, child: bodyWidgets[index]),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> body() {
    return [
      Padding(
        padding: EdgeInsets.only(top: 8),
        child: TextField(
          style: UIUtilities.getTextFieldTextStyle(context),
          controller: workoutNameController,
          decoration: UIUtilities.getTextFieldDecoration(
              context, UIUtilities.loadTranslation(context, 'workoutName')),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Text(
          UIUtilities.loadTranslation(context, 'exercises'),
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: UIUtilities.getPrimaryColor(context)),
        ),
      ),
      ...exerciseDataList.asMap().entries.map<Widget>((mapEntry) {
        int i = mapEntry.key;
        var items = menuItems(i);
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: NewExerciseCard(
              exerciseName: mapEntry.value?.name,
              setsController: setsControllers[i],
              repsController: repsControllers[i],
              popupMenuButton: items.isEmpty
                  ? null
                  : PopupMenuButton<MoveOrRemoveMenuOption>(
                      onSelected: (option) {
                        switch (option) {
                          case MoveOrRemoveMenuOption.move_up:
                            moveUp(i);
                            break;
                          case MoveOrRemoveMenuOption.move_down:
                            moveDown(i);
                            break;
                          case MoveOrRemoveMenuOption.remove:
                            remove(i);
                            break;
                        }
                      },
                      itemBuilder: ((context) => menuItems(i))),
              exerciseNumber: i + 1,
              onSelectExercise: () async {
                ExerciseData? newExerciseData = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return SelectExercise();
                }));
                if (newExerciseData != null) {
                  setState(() {
                    exerciseDataList[i] = newExerciseData;
                  });
                }
              }),
        );
      }).toList(),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: IconButton(
          icon: ListTile(
            contentPadding: EdgeInsets.only(left: 0),
            leading: Icon(
              Icons.add,
              color: UIUtilities.getPrimaryColor(context),
            ),
            title: Text(
              UIUtilities.loadTranslation(context, 'addExercise'),
              style: TextStyle(color: UIUtilities.getPrimaryColor(context)),
            ),
          ),
          onPressed: () {
            if (exerciseDataList.last != null &&
                setsControllers.last.text.isNotEmpty &&
                repsControllers.last.text.isNotEmpty) {
              setState(() {
                exerciseDataList.add(null);
                exercises.add(Exercise(
                    workoutId: widget.workout.id,
                    id: -1,
                    sets: 0,
                    reps: 0,
                    exerciseData: ExerciseData(
                      id: 0,
                      name: '',
                      type: '',
                    )));
                setsControllers.add(TextEditingController());
                setsControllers.last.addListener(() {
                  updateCanSave();
                });
                repsControllers.add(TextEditingController());
                repsControllers.last.addListener(() {
                  updateCanSave();
                });
                canSave = false;
              });
              // +2 because in the list items there are the initial TextField and
              // the Exercises Text title
              animatedListKey.currentState!.insertItem(
                  exerciseDataList.length - 1 + 2,
                  duration: Duration(milliseconds: 150));
            }
          },
        ),
      )
    ];
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.workout.exercises.length; i++) {
      Exercise exercise = widget.workout.exercises[i];
      setsControllers.add(TextEditingController());
      setsControllers[i].text = exercise.sets.toString();
      setsControllers[i].addListener(() {
        updateCanSave();
      });
      repsControllers.add(TextEditingController());
      repsControllers[i].text = exercise.reps.toString();
      repsControllers[i].addListener(() {
        updateCanSave();
      });
      workoutNameController.text = widget.workout.name;
      workoutNameController.addListener(() {
        updateCanSave();
      });
      exerciseDataList.add(exercise.exerciseData);
      exercises.add(exercise);
    }
    canSave = getCanSave();
  }

  List<PopupMenuItem<MoveOrRemoveMenuOption>> menuItems(int index) {
    List<PopupMenuItem<MoveOrRemoveMenuOption>> menuItems = [];
    if (exerciseDataList.length == 1 && exerciseDataList.first == null) {
      return menuItems;
    }
    if (index > 0) {
      menuItems.add(PopupMenuItem<MoveOrRemoveMenuOption>(
        value: MoveOrRemoveMenuOption.move_up,
        child: Text(UIUtilities.loadTranslation(context, 'moveUp')),
      ));
    }
    if (index < exerciseDataList.length - 1) {
      menuItems.add(PopupMenuItem<MoveOrRemoveMenuOption>(
        value: MoveOrRemoveMenuOption.move_down,
        child: Text(UIUtilities.loadTranslation(context, 'moveDown')),
      ));
    }
    // since the first element is always null
    if (exerciseDataList.isNotEmpty) {
      menuItems.add(PopupMenuItem<MoveOrRemoveMenuOption>(
        value: MoveOrRemoveMenuOption.remove,
        child: Text(UIUtilities.loadTranslation(context, 'remove')),
      ));
    }
    return menuItems;
  }

  void updateCanSave() {
    var tmp = getCanSave();
    if (tmp != canSave) {
      setState(() {
        canSave = tmp;
      });
    }
  }

  bool getCanSave() {
    if (setsControllers.isEmpty ||
        repsControllers.isEmpty ||
        workoutNameController.text.replaceAll(' ', '').isEmpty ||
        exerciseDataList.isEmpty) {
      return false;
    }
    for (int i = 0; i < setsControllers.length; i++) {
      if (setsControllers[i].text.isEmpty ||
          int.tryParse(setsControllers[i].text) == 0) {
        return false;
      }
      if (repsControllers[i].text.isEmpty ||
          int.tryParse(repsControllers[i].text) == 0) {
        return false;
      }
    }
    return true;
  }

  void moveUp(int index) {
    if (index <= 0) {
      return;
    }
    TextEditingController tmpController = setsControllers[index];
    setsControllers[index] = setsControllers[index - 1];
    setsControllers[index - 1] = tmpController;
    tmpController = repsControllers[index];
    repsControllers[index] = repsControllers[index - 1];
    repsControllers[index - 1] = tmpController;
    ExerciseData? tmpExerciseData = exerciseDataList[index];
    exerciseDataList[index] = exerciseDataList[index - 1];
    exerciseDataList[index - 1] = tmpExerciseData;
    Exercise? tmpExercise = exercises[index];
    exercises[index] = exercises[index - 1];
    exercises[index - 1] = tmpExercise;
    setState(() {});
  }

  void moveDown(int index) {
    if (index >= exerciseDataList.length - 1) {
      return;
    }
    TextEditingController tmpController = setsControllers[index];
    setsControllers[index] = setsControllers[index + 1];
    setsControllers[index + 1] = tmpController;
    tmpController = repsControllers[index];
    repsControllers[index] = repsControllers[index + 1];
    repsControllers[index + 1] = tmpController;
    ExerciseData? tmpExerciseData = exerciseDataList[index];
    exerciseDataList[index] = exerciseDataList[index + 1];
    exerciseDataList[index + 1] = tmpExerciseData;
    Exercise? tmpExercise = exercises[index];
    exercises[index] = exercises[index + 1];
    exercises[index + 1] = tmpExercise;
    setState(() {});
  }

  void remove(int index) {
    if (exerciseDataList.length <= 1) {
      setState(() {
        setsControllers[index].text = '';
        repsControllers[index].text = '';
        exerciseDataList[index] = null;
        exercises[index] = null;
      });
      return;
    }
    String? oldName = exerciseDataList.length - 1 >= index
        ? exerciseDataList[index] != null
            ? UIUtilities.loadTranslation(
                context, exerciseDataList[index]!.name)
            : ''
        : null;
    String oldSets = setsControllers[index].text;
    String oldReps = repsControllers[index].text;
    setState(() {
      setsControllers.removeAt(index);
      repsControllers.removeAt(index);
      exerciseDataList.removeAt(index);
      exercises.removeAt(index);
    });
    updateCanSave();
    TextEditingController tmpSets = TextEditingController();
    TextEditingController tmpReps = TextEditingController();
    tmpSets.text = oldSets;
    tmpReps.text = oldReps;
    animatedListKey.currentState!.removeItem(index + 2, (context, animation) {
      return FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          child: NewExerciseCard(
              exerciseName: oldName,
              setsController: tmpSets,
              repsController: tmpReps,
              onSelectExercise: () {},
              exerciseNumber: index + 1),
        ),
      );
    }, duration: Duration(milliseconds: 150));
  }

  Future saveWorkout() async {
    if (!canSave) {
      return;
    }
    List<Exercise> tmp = [];
    Workout workout;
    for (int i = 0; i < exercises.length; i++) {
      int sets = int.parse(setsControllers[i].text);
      int reps = int.parse(repsControllers[i].text);
      tmp.add(Exercise(
          workoutId: widget.workout.id,
          id: exercises[i]!.id,
          sets: sets,
          reps: reps,
          exerciseData: exerciseDataList[i]!));
    }
    workout = Workout(widget.workout.id, workoutNameController.text, tmp);
    bool success = await CustomDatabase.instance.editWorkout(workout);
    if (success) {
      ref
          .read(Helper.instance.workoutsProvider.notifier)
          .removeWorkout(workout.id);
      ref.read(Helper.instance.workoutsProvider.notifier).addWorkout(workout);
    } else {
      UIUtilities.showSnackBar(context: context, msg: 'error');
    }
  }
}
