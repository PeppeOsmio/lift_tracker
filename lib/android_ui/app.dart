import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/widgets/reactiveappbardata.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/localizations.dart';
import 'package:lift_tracker/android_ui/workoutlist/workoutlist.dart';
import 'package:lift_tracker/android_ui/loading.dart';
import 'package:lift_tracker/android_ui/exercises.dart';
import 'package:lift_tracker/android_ui/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? appBarTitle;
  Color? selectedColor;
  Color? selectedTextColor;
  Color? appBarColor;
  bool isSomethingSelected = false;
  ReactiveAppBarData appBarData =
      ReactiveAppBarData(false, null, null, [], () {});

  Widget drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.secondary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lift Tracker',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 24),
                  ),
                  //Image.asset('assets/icon/icon.png')
                ],
              )),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(Helper.loadTranslation(context, 'exit')),
            onTap: () {},
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    selectedColor = Color.lerp(Theme.of(context).colorScheme.secondaryContainer,
        Theme.of(context).colorScheme.surface, 0.5);
    selectedTextColor = Color.lerp(
        Theme.of(context).colorScheme.onSecondaryContainer,
        Theme.of(context).colorScheme.onSurface,
        0.5);
    return Scaffold(
        appBar: AppBar(
          leading: appBarData.isSelected ? appBarData.leading : null,
          actions: [
            AnimatedSize(
              curve: Curves.decelerate,
              duration: Duration(milliseconds: 150),
              child: Row(
                  children: appBarData.isSelected ? appBarData.actions : []),
            )
          ],
          title: Text(!appBarData.isSelected
              ? Helper.loadTranslation(context, pageKeys[pageIndex])
              : appBarData.title!),
          backgroundColor: appBarData.isSelected ? selectedColor : null,
          foregroundColor: appBarData.isSelected ? selectedTextColor : null,
        ),
        drawer: appBarData.isSelected ? null : drawer(),
        body: Stack(children: [
          Offstage(offstage: pageIndex != 0, child: History()),
          Offstage(
            offstage: pageIndex != 1,
            child: WorkoutList(
              appBarData: appBarData,
              canSelectThings: pageIndex == 1,
              selectedCardColor: selectedColor,
              selectedTextColor: selectedTextColor,
              onCardTap:
                  ((onDelete, onHistory, onEdit, onStart, workoutName) {}),
              onCardClose: () {},
            ),
          ),
          Offstage(offstage: pageIndex != 2, child: Exercises())
        ]),
        floatingActionButton: pageIndex == 1
            ? FloatingActionButton(
                heroTag: -4,
                onPressed: () {},
                child: Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: BottomNavBar(
          index: pageIndex,
          useMaterial3: widget.useMaterial3,
          navigationItems: [
            NavigationItem(
                icon: Icon(Icons.timer),
                label: Helper.loadTranslation(context, 'history')),
            NavigationItem(
                icon: Icon(Icons.create),
                label: Helper.loadTranslation(context, 'workouts')),
            NavigationItem(
                icon: Icon(Icons.fitness_center),
                label: Helper.loadTranslation(context, 'exercises'))
          ],
          onItemSelected: (index) {
            if (index == pageIndex) {
              return;
            }
            setState(() {
              actions = [];
              pageIndex = index;
              appBarData.isSelected = false;
            });
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        appBarData.onUpdate = () {
          setState(() {});
        };
      });
    });
    Future.delayed(Duration.zero, () async {
      await Helper.getExerciseData().then((value) async {
        Helper.exerciseDataGlobal = value;
        List<String> tempNames = [];
        for (var e in Helper.exerciseDataGlobal) {
          tempNames.add(Helper.loadTranslation(context, e.name));
        }
        tempNames.sort();
        List<ExerciseData> temp = [];
        for (var name in tempNames) {
          temp.add(Helper.exerciseDataGlobal.firstWhere((element) =>
              Helper.loadTranslation(context, element.name) == name));
        }
        Helper.exerciseDataGlobal.clear();
        Helper.exerciseDataGlobal.addAll(temp);
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        if (sharedPreferences.getBool('firstAppRun') == null) {
          Helper.showSnackBar(
              context: context,
              msg: "Added debug workouts: " +
                  (await Helper.addDebugWorkouts()).toString());
          ref.read(Helper.workoutsProvider.notifier).addWorkouts(
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
