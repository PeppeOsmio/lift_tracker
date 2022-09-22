import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lift_tracker/android_ui/app/app.dart';
import 'package:lift_tracker/android_ui/exercises/exercisedatacard.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/android_ui/widgets/customanimatedicon.dart';
import 'package:lift_tracker/android_ui/app/customdrawer.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/gym_icons_icons.dart';

class SelectExercise extends StatefulWidget {
  const SelectExercise({Key? key}) : super(key: key);

  @override
  State<SelectExercise> createState() => _SelectExercisesState();
}

class _SelectExercisesState extends State<SelectExercise> {
  List<ExerciseData> exerciseDatas = [];
  bool isSearchBarActivated = false;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchString = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      while (exerciseDatas.isEmpty) {
        exerciseDatas = Helper.instance.exerciseDataGlobal;
        await Future.delayed(Duration(milliseconds: 100));
      }
      if (exerciseDatas.isNotEmpty) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              if (isSearchBarActivated) {
                setState(() {
                  isSearchBarActivated = false;
                  searchString = '';
                  searchController.text = '';
                });
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.arrow_back)),
        actions: [
          AnimatedSize(
            curve: Curves.linear,
            duration: Duration(milliseconds: 150),
            child: Row(children: [
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
                  icon: Icon(isSearchBarActivated ? Icons.close : Icons.search))
            ]),
          )
        ],
        title: AnimatedSize(
          curve: Curves.linear,
          duration: Duration(milliseconds: 150),
          child: isSearchBarActivated
              ? TextField(
                  style: UIUtilities.getTextFieldTextStyle(context),
                  onChanged: (newValue) {
                    setState(() {
                      searchString = newValue;
                    });
                  },
                  focusNode: searchFocusNode,
                  controller: searchController,
                  decoration: InputDecoration(
                      hintText: UIUtilities.loadTranslation(
                          context, 'searchExercises'),
                      border: InputBorder.none),
                )
              : Text(
                  UIUtilities.loadTranslation(context, 'selectExerciseTitle')),
        ),
      ),
      drawer: isSearchBarActivated ? null : CustomDrawer(),
      body: GestureDetector(
        onTap: () {
          UIUtilities.unfocusTextFields(context);
          setState(() {
            isSearchBarActivated = false;
            searchString = '';
            searchController.text = '';
          });
        },
        child: ListView.builder(
            itemCount: exerciseDatas.length,
            itemBuilder: (context, index) {
              if (UIUtilities.loadTranslation(
                      context, exerciseDatas[index].name)
                  .toLowerCase()
                  .contains(searchString.toLowerCase())) {
                return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, exerciseDatas[index]);
                    },
                    child:
                        ExerciseDataCard(exerciseData: exerciseDatas[index]));
              } else {
                return SizedBox();
              }
            }),
      ),
    );
  }

  void openSearchBar() {
    setState(() {
      isSearchBarActivated = true;
      searchFocusNode.requestFocus();
    });
  }
}
