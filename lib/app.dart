import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/history.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'data/constants.dart';
import 'workoutlist.dart';
import 'excercises.dart';
import 'package:fluttertoast/fluttertoast.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  List<String> pageKeys = ["History", "Workouts", "Excercises"];
  late String _currentPageName;
  DateTime? backPressedTime;
  late GlobalKey navBarKey;
  late Widget workoutList;
  Widget? history;
  Widget? excercises;

  Widget _buildOffStage(int index, Widget child) {
    switch (index) {
      case 0:
        return Offstage(
            offstage: _currentPageName != pageKeys[index], child: child);

      case 1:
        return Offstage(
            offstage: _currentPageName != pageKeys[index], child: child);

      default:
        return Offstage(
            offstage: _currentPageName != pageKeys[index], child: child);
    }
  }

  void _selectTab(int index) {
    setState(() {
      _currentPageName = pageKeys[index];
      Constants.pageIndex = index;
      Constants.pageStack.add(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _currentPageName = pageKeys[1];
    Constants.pageIndex = 1;
    Constants.pageStack.add(1);
    navBarKey = GlobalKey();
    workoutList = WorkoutList(navBarKey: navBarKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            backgroundColor: Palette.backgroundDark,
                            titleTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            title: const Text("Exit?"),
                            actions: [
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Palette.elementsDark)),
                                  onPressed: () {
                                    SystemNavigator.pop();
                                  },
                                  child: const Text("Yes")),
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Palette.elementsDark)),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text("Cancel"))
                            ],
                          );
                        });
                  },
                  icon: const Icon(Icons.logout_outlined)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Text(_currentPageName),
            ),
          ],
        ),
        toolbarHeight: 79,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 16),
            child: Container(
                height: 6,
                width: 60,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Palette.elementsDark,
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: const FittedBox(child: Icon(Icons.person))),
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Palette.backgroundDark,
      body: WillPopScope(
        child: Stack(children: [
          history == null ? const SizedBox() : _buildOffStage(0, history!),
          _buildOffStage(1, workoutList),
          excercises == null ? const SizedBox() : _buildOffStage(2, excercises!)
        ]),
        onWillPop: () async {
          if (Constants.pageStack.length > 1) {
            int index;
            Constants.pageStack.removeLast();
            index = Constants.pageStack.last;
            _currentPageName = pageKeys[index];
            Constants.pageIndex = index;

            setState(() {});
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
      bottomNavigationBar: BottomNavBar(
        [
          NavBarItem("History", Icons.schedule, () {
            if (Constants.pageIndex != 0) {
              //if something notified that the history was updated
              //we rebuild it in order to reload the content of the history
              if (Constants.didUpdateHistory) {
                history = History(key: GlobalKey());
                _selectTab(0);
                return;
              }
              history ??= const History();
              _selectTab(0);
            }
          }),
          NavBarItem("Workouts", Icons.add_outlined, () {
            if (Constants.pageIndex != 1) {
              _selectTab(1);
            }
          }),
          NavBarItem("Excercises", Icons.fitness_center, () {
            if (Constants.pageIndex != 2) {
              excercises ??= const Excercises();
              _selectTab(2);
            }
          })
        ],
        key: navBarKey,
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar(this.bottomNavItems, {Key? key}) : super(key: key);
  final List<NavBarItem> bottomNavItems;

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> buildAppBarRow() {
    List<Widget> list = [];
    BoxDecoration? dec;
    for (int i = 0; i < widget.bottomNavItems.length; i++) {
      if (i == Constants.pageIndex) {
        dec = const BoxDecoration(
          color: Color.fromARGB(200, 80, 36, 12),
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
              if (Constants.pageIndex == i) {
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
