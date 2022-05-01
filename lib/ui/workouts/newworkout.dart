import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/ui/styles.dart';
import 'package:lift_tracker/ui/workouts/exerciselistitem.dart';
import 'package:lift_tracker/ui/selectexercise.dart';
import 'package:lift_tracker/ui/widgets.dart';

import '../../data/helper.dart';

class NewWorkout extends ConsumerStatefulWidget {
  const NewWorkout({Key? key}) : super(key: key);

  @override
  _NewWorkoutState createState() => _NewWorkoutState();
}

class _NewWorkoutState extends ConsumerState<NewWorkout> {
  List<ExerciseData?> exerciseDataList = [];
  List<Exercise> data = [];
  TextEditingController workoutName = TextEditingController();
  List<TextEditingController> repsControllers = [];
  List<TextEditingController> setsControllers = [];
  List<TextEditingController> nameControllers = [];

  @override
  void initState() {
    super.initState();
    repsControllers.add(TextEditingController());
    nameControllers.add(TextEditingController());
    setsControllers.add(TextEditingController());
    exerciseDataList.add(null);
  }

  @override
  Widget build(BuildContext context) {
    List<ExerciseListItem> exerciseWidgets = [];
    for (int i = 0; i < exerciseDataList.length; i++) {
      exerciseWidgets.add(ExerciseListItem(
        onDelete: () => onDelete(i),
        onNameFieldPress: () async {
          var result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return SelectExercise();
          }));
          if (result != null) {
            exerciseDataList[i] = result;
            nameControllers[i].text =
                Helper.loadTranslation(context, result.name);
            setState(() {});
          }
        },
        repsController: repsControllers[i],
        nameController: nameControllers[i],
        setsController: setsControllers[i],
        onMoveDown: () => onMoveDown(i),
        onMoveUp: () => onMoveUp(i),
      ));
    }
    List<Widget> temp = [];
    for (int i = 0; i < exerciseWidgets.length; i++) {
      temp.add(Padding(
        padding:
            EdgeInsets.only(bottom: i == exerciseWidgets.length - 1 ? 0 : 24),
        child: exerciseWidgets[i],
      ));
    }
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          Helper.unfocusTextFields(context);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Palette.backgroundDark,
            body: Column(
              children: [
                CustomAppBar(
                    middleText: Helper.loadTranslation(context, 'newWorkout'),
                    onBack: () => Navigator.pop(context),
                    onSubmit: () => createWorkout(),
                    backButton: true,
                    submitButton: true),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 48, left: 24, bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Helper.loadTranslation(context, 'workoutName'),
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 24, bottom: 24, right: 48),
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 31, 31, 31),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                controller: workoutName,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: Helper.loadTranslation(
                                        context, 'workoutNameExample'),
                                    border: InputBorder.none),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            Helper.loadTranslation(context, 'exercises'),
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          Column(
                              mainAxisSize: MainAxisSize.min, children: temp),
                          addExerciseButton()
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void createWorkout() async {
    if (workoutName.text.isEmpty) {
      return;
    }
    List<Exercise> exercises = [];
    for (int i = 0; i < exerciseDataList.length; i++) {
      String sets = setsControllers[i].text;
      String reps = repsControllers[i].text;
      String name = '';
      String type = '';
      String jsonId = '';
      if (exerciseDataList[i] != null) {
        name = exerciseDataList[i]!.name;
        type = exerciseDataList[i]!.type;
        jsonId = exerciseDataList[i]!.id.toString();
      }

      if (name.isEmpty ||
          sets.isEmpty ||
          reps.isEmpty ||
          type.isEmpty ||
          jsonId.isEmpty) {
        return;
      }
      if (sets == '0') {
        Fluttertoast.showToast(
            msg: Helper.loadTranslation(
                    context, '${exerciseDataList[i]!.name}') +
                ' ' +
                Helper.loadTranslation(context, 'noSetsError'));
        return;
      }
      if (reps == '0') {
        Fluttertoast.showToast(
            msg: Helper.loadTranslation(
                    context, '${exerciseDataList[i]!.name}') +
                ' ' +
                Helper.loadTranslation(context, 'noRepsError'));
        return;
      }
      exercises.add(Exercise(
          id: i,
          exerciseData:
              ExerciseData(id: int.parse(jsonId), type: type, name: ''),
          sets: int.parse(sets),
          reps: int.parse(reps),
          workoutId: 0));
    }
    await CustomDatabase.instance.createWorkout(workoutName.text, exercises);
    ref.read(Helper.workoutsProvider.notifier).refreshWorkouts();
    Navigator.pop(context);
  }

  void onDelete(index) {
    if (exerciseDataList.length > 1) {
      exerciseDataList.removeAt(index);
      repsControllers.removeAt(index);
      setsControllers.removeAt(index);
      nameControllers.removeAt(index);
      setState(() {});
    }
  }

  void onMoveDown(index) {
    if (exerciseDataList[index] == exerciseDataList.last) {
      return;
    }
    var temp = exerciseDataList[index];
    exerciseDataList[index] = exerciseDataList[index + 1];
    exerciseDataList[index + 1] = temp;
    var temp1 = repsControllers[index];
    repsControllers[index] = repsControllers[index + 1];
    repsControllers[index + 1] = temp1;
    var temp2 = setsControllers[index];
    setsControllers[index] = setsControllers[index + 1];
    setsControllers[index + 1] = temp2;
    var temp3 = nameControllers[index];
    nameControllers[index] = nameControllers[index + 1];
    nameControllers[index + 1] = temp3;
    setState(() {});
  }

  void onMoveUp(index) {
    if (exerciseDataList[index] == exerciseDataList.first) {
      return;
    }
    var temp = exerciseDataList[index];
    exerciseDataList[index] = exerciseDataList[index - 1];
    exerciseDataList[index - 1] = temp;
    var temp1 = repsControllers[index];
    repsControllers[index] = repsControllers[index - 1];
    repsControllers[index - 1] = temp1;
    var temp2 = setsControllers[index];
    setsControllers[index] = setsControllers[index - 1];
    setsControllers[index - 1] = temp2;
    var temp3 = nameControllers[index];
    nameControllers[index] = nameControllers[index - 1];
    nameControllers[index - 1] = temp3;
    setState(() {});
  }

  Widget addExerciseButton() {
    return Center(
        child: SizedBox(
            height: 65,
            width: 65,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                if (repsControllers.last.text != '' &&
                    setsControllers.last.text != '' &&
                    nameControllers.last.text != '') {
                  exerciseDataList.add(null);
                  nameControllers.add(TextEditingController());
                  setsControllers.add(TextEditingController());
                  repsControllers.add(TextEditingController());
                  setState(() {});
                }
              },
              backgroundColor: const Color.fromARGB(255, 31, 31, 31),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: const FittedBox(
                child: Icon(Icons.add_outlined),
              ),
            )));
  }
}
