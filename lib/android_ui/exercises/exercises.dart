import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lift_tracker/android_ui/app.dart';
import 'package:lift_tracker/android_ui/exercises/exercisedatacard.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/android_ui/widgets/customanimatedicon.dart';
import 'package:lift_tracker/android_ui/widgets/customdrawer.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/gym_icons_icons.dart';

class Exercises extends StatefulWidget {
  const Exercises({Key? key}) : super(key: key);

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  List<ExerciseData> exerciseDatas = [];
  bool isSearchBarActivated = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    log('Building Exercises...');
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
      backgroundColor: UIUtilities.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: UIUtilities.getAppBarColor(context),
        leading: IconButton(
            onPressed: () {
              if (isSearchBarActivated) {
                setState(() {
                  isSearchBarActivated = false;
                });
              } else {
                mainScaffoldKey.currentState!.openDrawer();
              }
            },
            icon: CustomAnimatedIcon(
              animatedIconData: AnimatedIcons.arrow_menu,
              start: !isSearchBarActivated,
            )),
        actions: [
          AnimatedSize(
            curve: Curves.decelerate,
            duration: Duration(milliseconds: 150),
            child: Row(children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      isSearchBarActivated = true;
                    });
                  },
                  icon: Icon(isSearchBarActivated ? Icons.close : Icons.search))
            ]),
          )
        ],
        title: AnimatedSize(
          curve: Curves.decelerate,
          duration: Duration(milliseconds: 150),
          child: isSearchBarActivated
              ? TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                      hintText: UIUtilities.loadTranslation(
                          context, 'searchExercises'),
                      border: InputBorder.none),
                )
              : Text(UIUtilities.loadTranslation(context, 'exercises')),
        ),
      ),
      drawer: isSearchBarActivated ? null : CustomDrawer(),
      body: GestureDetector(
        onTap: () {
          UIUtilities.unfocusTextFields(context);
          setState(() {
            isSearchBarActivated = false;
          });
        },
        child: ListView.builder(
            itemCount: exerciseDatas.length,
            itemBuilder: (context, index) {
              return ExerciseDataCard(exerciseData: exerciseDatas[index]);
            }),
      ),
    );
  }
}