import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/ui/exercises.dart';
import 'package:lift_tracker/ui/widgets.dart';

import 'styles.dart';

class SelectExercise extends ConsumerStatefulWidget {
  const SelectExercise({Key? key}) : super(key: key);

  @override
  _SelectExerciseState createState() => _SelectExerciseState();
}

class _SelectExerciseState extends ConsumerState<SelectExercise> {
  final TextEditingController searchController = TextEditingController();
  List<ExerciseData> displayedData = Helper.exerciseDataGlobal;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Palette.backgroundDark,
        body: Column(children: [
          CustomAppBar(
            middleText: Helper.loadTranslation(context, 'selectExerciseTitle'),
            onBack: () => Navigator.pop(context),
            onSubmit: () {},
            backButton: true,
            submitButton: false,
          ),
          SearchBar(
            hint: Helper.loadTranslation(context, 'filter'),
            textController: searchController,
            onTextChange: (change) {
              List<ExerciseData> temp = [];
              if (change.isEmpty) {
                displayedData = Helper.exerciseDataGlobal;
                setState(() {});
                return;
              }
              for (ExerciseData data in Helper.exerciseDataGlobal) {
                if (Helper.loadTranslation(context, data.name)
                    .toLowerCase()
                    .contains(change.toLowerCase())) {
                  temp.add(data);
                }
              }
              displayedData = temp;
              setState(() {});
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 16,
                    );
                  },
                  itemCount: displayedData.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, displayedData[index]);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: index == displayedData.length - 1 ? 16 : 0),
                        child: ExerciseCard(exerciseData: displayedData[index]),
                      ),
                    );
                  }),
            ),
          )
        ]),
      ),
    );
  }
}
