import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/ui/exercises.dart';
import 'package:lift_tracker/ui/widgets.dart';

import 'colors.dart';

class SelectExercise extends ConsumerStatefulWidget {
  const SelectExercise({Key? key}) : super(key: key);

  @override
  _SelectExerciseState createState() => _SelectExerciseState();
}

class _SelectExerciseState extends ConsumerState<SelectExercise> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Palette.backgroundDark,
        body: Column(children: [
          CustomAppBar(
            middleText: 'Select an exercise',
            onBack: () => Navigator.pop(context),
            onSubmit: () {},
            backButton: true,
            submitButton: false,
          ),
          SearchBar(
            hint: 'Filter...',
            textController: TextEditingController(),
          ),
          Expanded(
            child: FutureBuilder(
                future: Helper.getExerciseData(),
                builder: (context, ss) {
                  if (ss.hasData) {
                    List<ExerciseData> exerciseData =
                        ss.data! as List<ExerciseData>;
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: 16,
                            );
                          },
                          itemCount: exerciseData.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context, exerciseData[index]);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: index == exerciseData.length - 1
                                        ? 16
                                        : 0),
                                child: ExerciseCard(
                                    exerciseData: exerciseData[index]),
                              ),
                            );
                          }),
                    );
                  }
                  if (ss.hasError) {
                    return Expanded(
                        child: Center(
                      child: Text('Error'),
                    ));
                  }
                  return SizedBox();
                }),
          )
        ]),
      ),
    );
  }
}
