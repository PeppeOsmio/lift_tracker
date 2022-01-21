import 'package:flutter/material.dart';
import 'package:lift_tracker/history.dart';
import 'workoutlist.dart';
import 'excercises.dart';

int currentPageIndex = 1;

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late int nextScreen;
  late String currentPageName = "Workouts";
  late Widget currentPage;
  late Widget workoutList;
  Widget? excercises;
  Widget? history;
  List<int> pageStack = [1];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    workoutList = const WorkoutList();
    currentPage = workoutList;
    currentPageIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    print(pageStack);
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: const Color.fromARGB(255, 31, 31, 31),
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16),
        child: Text(currentPageName),
      ),
      toolbarHeight: 79,
      actions: [Padding(
        padding: EdgeInsets.only(right: 16, top: 16),
        child: Container(
          height: 6,
          width: 60,
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
                color: Color.fromARGB(255, 50, 50, 50), 
                borderRadius: BorderRadius.all(Radius.circular(20))),
          child: const FittedBox(child: Icon(Icons.person))),
      )],
      ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: currentPageIndex==1 
        ? Container(
          padding: EdgeInsets.all(18),
          height: 65,
          width: 65,
          decoration: const BoxDecoration(
                color: Colors.black, 
                borderRadius: BorderRadius.all(Radius.circular(20))),
          child: FittedBox(child: Icon(Icons.add_outlined, color: Colors.white,))
        )
        : null,
        /*Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Container(
                decoration: const BoxDecoration(
                color: Colors.black, 
                borderRadius: BorderRadius.all(Radius.circular(20))),
                child: const ListTile(leading: Icon(Icons.search_outlined, color: Colors.white,), 
                title: Text("Search", style: TextStyle(color: Colors.white, fontSize: 25),),),
              ),
            ),*/
      backgroundColor: const Color.fromARGB(255, 31, 31, 31),
      body: WillPopScope(child: currentPage, onWillPop: ()async{
        int index;
        
        if(pageStack.length>1){
          pageStack.removeLast();
          index = pageStack.last;
          switch (index) {
          case 0:
            currentPage = history!;
            currentPageName = "History";
            currentPageIndex = 0;
            break;
          case 1:
            currentPage = workoutList;
            currentPageName = "Workouts";
            currentPageIndex = 1;
            break;
          case 2:
            currentPage = excercises!;
            currentPageName = "Excercises";
            currentPageIndex = 2;
            break;
          default:
            break;
        }
        setState(() {
        });
        }
        return false;},),
      bottomNavigationBar: BottomNavBar(
            [NavBarItem("History", Icons.schedule, (){
              if(currentPageIndex != 0){
                
                setState(() {
                  currentPageName = "History";
                  history ??= const History();
                  pageStack.add(0);
                  currentPageIndex = 0;
                });
              }
            }),
            NavBarItem("Workouts", Icons.add_outlined, (){
              if(currentPageIndex != 1){
                
                setState(() {
                  currentPageName = "Workouts";
                  currentPage = workoutList;
                  pageStack.add(1);
                  currentPageIndex = 1;
                });
              }
            }),
            NavBarItem("Excercises", Icons.fitness_center, (){

              if(currentPageIndex != 2){
                
                setState(() {
                  currentPageName = "Excercises";
                  excercises ??= const Excercises();
                  currentPage = excercises!;
                  pageStack.add(2);
                  currentPageIndex = 2;
                });
                
                }
              
            })],
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

  List<Widget> buildAppBarRow(){
    List<Widget> list = [];
    BoxDecoration? dec;
    for(int i=0;i<widget.bottomNavItems.length;i++){
      if(i==currentPageIndex){
        dec = const BoxDecoration(
        color: Color.fromARGB(255, 31, 31, 31), 
        borderRadius: BorderRadius.all(Radius.circular(20)),);
      }else{
        dec = const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(20)));
      }
      NavBarItem item = widget.bottomNavItems[i];
      list.add(Expanded(child: 
      
        
      Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, top: 6, bottom: 6),
        child: GestureDetector(
          onTap: () {
          if(currentPageIndex==i){
            return;
          }else{
            
            item.onPressed.call();
            }
          },
          child: AnimatedContainer(
          curve: Curves.decelerate,
          duration: const Duration(milliseconds: 500),
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
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
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
  const NavBarItem(this.title, this.icon, this.onPressed, {Key? key}) : super(key: key);
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
          Icon(
            widget.icon,
            color: defaultColorDark),
          Text(widget.title, style: TextStyle(color: defaultColorDark),)
        ],),
        
    );
  }
}

