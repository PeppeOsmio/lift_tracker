import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/ui/app/menu.dart';
import 'package:lift_tracker/ui/history/history.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/newsession.dart';
import 'package:lift_tracker/ui/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/helper.dart';
import '../workoutlist/workoutlist.dart';
import '../exercises.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PageNameNotifier extends StateNotifier<String> {
  PageNameNotifier() : super("Workouts");
  void setName(String name) {
    state = name;
  }
}

final pageNameProvider = StateNotifierProvider<PageNameNotifier, String>((ref) {
  return PageNameNotifier();
});

class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  List<String> pageKeys = ["History", "Workouts", "Exercises"];
  DateTime? backPressedTime;
  late Widget workoutList;
  Widget? history;
  Widget? exercises;
  List<Widget> pages = [];
  late SharedPreferences pref;

  Widget _buildOffStage(int index, Widget child) {
    int indexState = ref.read(Helper.pageIndexProvider.notifier).state;
    switch (index) {
      case 0:
        return Offstage(offstage: index != indexState, child: child);

      case 1:
        return Offstage(offstage: index != indexState, child: child);

      default:
        return Offstage(offstage: index != indexState, child: child);
    }
  }

  void _selectTab(int index, intCurrentIndex) {
    ref.read(Helper.pageIndexProvider.notifier).setIndex(index);
    Helper.pageStack.add(index);
    ref.read(pageNameProvider.notifier).setName(pageKeys[index]);
    Widget? temp;
    if (index == 0) {
      temp = history!;
    } else if (index == 2) {
      temp = exercises!;
    }
    if (temp != null) {
      ref.read(Helper.pagesProvider.notifier).addPage(temp, index);
    }
  }

  @override
  void initState() {
    super.initState();
    Helper.pageStack.add(1);
    workoutList = WorkoutList();
    Future.delayed(Duration.zero, () async {
      pref = await SharedPreferences.getInstance();
      bool? temp = pref.getBool('didCacheSession');
      bool cached = false;
      if (temp != null) {
        cached = temp;
      }
      if (cached) {
        showDimmedBackgroundDialog(context,
            rightText: 'Cancel', leftText: 'Resume', rightOnPressed: () async {
          await CustomDatabase.instance.removeCachedSession();
          Navigator.maybePop(context);
        }, leftOnPressed: () async {
          var cachedRecord = await CustomDatabase.instance.getCachedSession();
          var cachedWorkout = await CustomDatabase.instance
              .getCachedWorkout(cachedRecord.workoutId);
          log(cachedWorkout.name);
          log(cachedRecord.workoutName);
          Route route = MaterialPageRoute(builder: (context) {
            return NewSession(cachedWorkout, resumedSession: cachedRecord);
          });
          Navigator.pushReplacement(context, route);
        }, onDispose: () async {
          await CustomDatabase.instance.removeCachedSession();
        }, title: 'Resume last workout session?');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Helper.unfocusTextFields(context);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Palette.backgroundDark,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: IconButton(
                    onPressed: () {
                      Helper.unfocusTextFields(context);
                      showDimmedBackgroundDialog(context,
                          title: 'Exit?',
                          rightText: 'Cancel',
                          leftText: 'Yes',
                          rightOnPressed: () => Navigator.maybePop(context),
                          leftOnPressed: () => SystemNavigator.pop());
                    },
                    icon: const Icon(Icons.logout_outlined)),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: Consumer(builder: (context, textRef, child) {
                    String pageName = textRef.watch(pageNameProvider);
                    return Text(pageName);
                  })),
            ],
          ),
          toolbarHeight: 79,
          actions: [BlurredProfileMenu()],
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Palette.backgroundDark,
        body: WillPopScope(
          child: Consumer(builder: (context, ref, child) {
            var temp = ref.watch(Helper.pagesProvider);
            List<Widget> list = [];
            for (int i = 0; i < temp.length; i++) {
              list.add(_buildOffStage(i, temp[i]));
            }
            ref.watch(Helper.pageIndexProvider);
            log("Building stack");
            return Stack(children: list);
          }),
          onWillPop: () async {
            if (Helper.pageStack.length > 1) {
              int index;
              Helper.pageStack.removeLast();
              index = Helper.pageStack.last;
              ref.read(Helper.pageIndexProvider.notifier).setIndex(index);
              return false;
            }
            if (backPressedTime == null) {
              backPressedTime = DateTime.now();
              Fluttertoast.cancel();
              Fluttertoast.showToast(msg: "Press back again to quit");
              return false;
            } else if (DateTime.now().difference(backPressedTime!) >
                const Duration(milliseconds: 2000)) {
              backPressedTime = DateTime.now();
              Fluttertoast.cancel();
              Fluttertoast.showToast(msg: "Press back again to quit");
              return false;
            }
            return true;
          },
        ),
        bottomNavigationBar: Consumer(builder: ((context, ref, child) {
          var indexState = ref.read(Helper.pageIndexProvider.notifier).state;
          return BottomNavBar(
            [
              NavBarItem("History", Icons.schedule, () {
                //if something notified that the history was updated
                //we rebuild it in order to reload the content of the history

                history ??= const History();
                _selectTab(0, indexState);
              }),
              NavBarItem("Workouts", Icons.add_outlined, () {
                _selectTab(1, indexState);
              }),
              NavBarItem("Exercises", Icons.fitness_center, () {
                exercises ??= const Exercises();
                _selectTab(2, indexState);
              })
            ],
          );
        })),
      ),
    );
  }
}

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar(this.bottomNavItems, {Key? key}) : super(key: key);
  final List<NavBarItem> bottomNavItems;

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> buildAppBarRow() {
    int indexState = ref.watch(Helper.pageIndexProvider);
    List<Widget> list = [];
    BoxDecoration? dec;
    for (int i = 0; i < widget.bottomNavItems.length; i++) {
      if (i == indexState) {
        dec = BoxDecoration(
          color:
              Colors.blueGrey.withAlpha(125), //Color.fromARGB(200, 80, 36, 12),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        );
      } else {
        dec = const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(20)));
      }
      NavBarItem item = widget.bottomNavItems[i];
      list.add(Expanded(
          child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, top: 6, bottom: 6),
        child: GestureDetector(
            onTap: () {
              if (indexState == i) {
                return;
              } else {
                item.onPressed.call();
              }
            },
            child: AnimatedContainer(
              curve: Curves.decelerate,
              duration: const Duration(milliseconds: 350),
              decoration: dec,
              child: item,
            )),
      )));
      dec = null;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          border: Border.all(color: Colors.black)),
      width: MediaQuery.of(context).size.width,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: buildAppBarRow()),
    );
  }
}

class NavBarItem extends StatefulWidget {
  const NavBarItem(this.title, this.icon, this.onPressed, {Key? key})
      : super(key: key);
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  _NavBarItemState createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> {
  Color selectedColor = Colors.orange;
  Color defaultColorDark = Colors.white;
  Color defaulColorLight = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: defaultColorDark),
          Text(
            widget.title,
            style: TextStyle(color: defaultColorDark),
          )
        ],
      ),
    );
  }
}
