import 'package:flutter/material.dart';
import 'package:lift_tracker/history.dart';
import 'workoutlist.dart';
import 'excercises.dart';
import 'newworkout.dart';

int currentPageIndex = 1;

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  List<String> pageKeys = ["History", "Workouts", "Excercises"];
  late String _currentPageName;
  bool excercises = false;
  bool history = false;
  List<int> pageStack = [];

  Widget _buildOffStage(int index){
    switch (index) {
      case 0:
        
          return Offstage(
                offstage: _currentPageName != pageKeys[index],
                child: const History()
              );
        
        
      case 1:
        return Offstage(
                offstage: _currentPageName != pageKeys[index],
                child: const WorkoutList(),
              );
       
      default:
        
          return Offstage(
                offstage: _currentPageName != pageKeys[index],
                child: const Excercises(),
              );
        
    }
  }

  void _selectTab(int index){
    
    setState(() {
      _currentPageName = pageKeys[index];
      currentPageIndex = index;
      pageStack.add(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _currentPageName = pageKeys[1];
    currentPageIndex = 1;
    pageStack.add(1);
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16),
        child: Text(_currentPageName),
      ),
      toolbarHeight: 79,
      actions: [Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: Container(
          height: 6,
          width: 60,
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
                color: Color.fromARGB(255, 31, 31, 31), 
                borderRadius: BorderRadius.all(Radius.circular(20))),
          child: const FittedBox(child: Icon(Icons.person))),
      )],
      ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: currentPageIndex==1 
        ? SizedBox(
          height: 65,
          width: 65,
          child: FloatingActionButton(onPressed: (){
            var route = MaterialPageRoute(builder: (context) => const NewWorkout());
            Navigator.push(context, route);       
          },
          backgroundColor: Colors.black,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          child: const FittedBox(child: Icon(Icons.add_outlined),),),
        )
        : null,
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      body: WillPopScope(
      child: Stack(children: [
        history == false ? const SizedBox() : _buildOffStage(0),
        _buildOffStage(1),
        excercises == false ? const SizedBox() : _buildOffStage(2)

      ]), 
      
      onWillPop: ()async{
        if(pageStack.length>1){
          int index;
          pageStack.removeLast();
          index = pageStack.last;
          _currentPageName = pageKeys[index];
          currentPageIndex = index;
          
        setState(() {
        });
        }
        return false;},),
      bottomNavigationBar: BottomNavBar(
            [NavBarItem("History", Icons.schedule, (){
              if(currentPageIndex != 0){
                history = true;
                _selectTab(0);
              }
            }),
            NavBarItem("Workouts", Icons.add_outlined, (){
              if(currentPageIndex != 1){
                
                _selectTab(1);
              }
            }),
            NavBarItem("Excercises", Icons.fitness_center, (){

              if(currentPageIndex != 2){
                excercises = true;
                _selectTab(2);
                
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

