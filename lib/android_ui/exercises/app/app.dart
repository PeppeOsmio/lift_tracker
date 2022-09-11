import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/workouts/newworkout.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/android_ui/widgets/appbardata.dart';
import 'package:lift_tracker/android_ui/exercises/app/customdrawer.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/localizations.dart';
import 'package:lift_tracker/android_ui/workoutlist/workoutlist.dart';
import 'package:lift_tracker/android_ui/loading.dart';
import 'package:lift_tracker/android_ui/exercises/exercises.dart';
import 'package:lift_tracker/android_ui/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey();

class App extends ConsumerStatefulWidget {
  const App({Key? key, required this.useMaterial3}) : super(key: key);
  final bool useMaterial3;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int pageIndex = 1;
  List<String> pageKeys = ['history', 'workouts', 'exercises'];
  List<Widget> actions = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        UIUtilities.showDimmedBackgroundDialog(context,
            title: UIUtilities.loadTranslation(context, 'exit'),
            content: UIUtilities.loadTranslation(context, 'exitContent'),
            leftText: UIUtilities.loadTranslation(context, 'exitNo'),
            rightText: UIUtilities.loadTranslation(context, 'exitYes'),
            leftOnPressed: () {
          Navigator.maybePop(context);
        }, rightOnPressed: () {
          SystemNavigator.pop(animated: true);
        });
        return false;
      },
      child: Scaffold(
          key: mainScaffoldKey,
          drawer: CustomDrawer(),
          body: Stack(children: [
            Offstage(offstage: pageIndex != 0, child: History()),
            Offstage(
              offstage: pageIndex != 1,
              child: WorkoutList(
                onCardTap:
                    ((onDelete, onHistory, onEdit, onStart, workoutName) {}),
                onCardClose: () {},
              ),
            ),
            Offstage(offstage: pageIndex != 2, child: Exercises())
          ]),
          bottomNavigationBar: BottomNavBar(
            index: pageIndex,
            useMaterial3: widget.useMaterial3,
            navigationItems: [
              NavigationItem(
                  icon: Icon(Icons.timer),
                  label: UIUtilities.loadTranslation(context, 'history')),
              NavigationItem(
                  icon: Icon(Icons.create),
                  label: UIUtilities.loadTranslation(context, 'workouts')),
              NavigationItem(
                  icon: Icon(Icons.fitness_center),
                  label: UIUtilities.loadTranslation(context, 'exercises'))
            ],
            onItemSelected: (index) {
              if (index == pageIndex) {
                return;
              }
              setState(() {
                actions = [];
                pageIndex = index;
              });
            },
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await Helper.getExerciseData().then((value) async {
        Helper.instance.exerciseDataGlobal = value;
        List<String> tempNames = [];
        for (var e in Helper.instance.exerciseDataGlobal) {
          tempNames.add(UIUtilities.loadTranslation(context, e.name));
        }
        tempNames.sort();
        List<ExerciseData> temp = [];
        for (var name in tempNames) {
          temp.add(Helper.instance.exerciseDataGlobal.firstWhere((element) =>
              UIUtilities.loadTranslation(context, element.name) == name));
        }
        Helper.instance.exerciseDataGlobal.clear();
        Helper.instance.exerciseDataGlobal.addAll(temp);
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        if (sharedPreferences.getBool('firstAppRun') == null) {
          UIUtilities.showSnackBar(
              context: context,
              msg: "Added debug workouts: " +
                  (await Helper.addDebugWorkouts()).toString());
          ref.read(Helper.instance.workoutsProvider.notifier).addWorkouts(
              await CustomDatabase.instance.readWorkouts(readAll: true));
          sharedPreferences.setBool('firstAppRun', true);
        }
      }); /*.catchError((error) {
        Fluttertoast.showToast(msg: 'loading: $error');
      });*/
    });
  }
}

class NavigationItem {
  const NavigationItem({required this.icon, required this.label});
  final Icon icon;
  final String label;
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar(
      {Key? key,
      this.useMaterial3 = true,
      required this.navigationItems,
      required this.index,
      required this.onItemSelected})
      : super(key: key);
  final bool useMaterial3;
  final List<NavigationItem> navigationItems;
  final int index;
  final Function(int) onItemSelected;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return widget.useMaterial3
        ? NavigationBar(
            selectedIndex: widget.index,
            destinations: widget.navigationItems
                .map((e) => NavigationDestination(icon: e.icon, label: e.label))
                .toList(),
            onDestinationSelected: widget.onItemSelected)
        : BottomNavigationBar(
            currentIndex: widget.index,
            items: widget.navigationItems
                .map((e) =>
                    BottomNavigationBarItem(icon: e.icon, label: e.label))
                .toList(),
            onTap: widget.onItemSelected);
  }
}
