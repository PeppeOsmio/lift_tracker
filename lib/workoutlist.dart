import 'package:flutter/material.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({ Key? key }) : super(key: key);

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

List<String> excercises = ["Chest press", "Flies","Bench press", "French press", "Bent-over row", "Pull-ups"];

class _WorkoutListState extends State<WorkoutList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                color: Colors.black, 
                borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.search_outlined, color: Colors.white,),
                  ),
                  Expanded(child: TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                    style: TextStyle(color: Colors.white,fontSize: 25), )),
                  
                ],),
              ),
            ),
            
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children:  [
              
              Padding(padding: const EdgeInsets.all(16),
              child: WorkoutCard("Petto", excercises)),
              Padding(padding: const EdgeInsets.all(16),
              child: WorkoutCard("Gambe", excercises)),
              Padding(padding: const EdgeInsets.all(16),
              child: WorkoutCard("Petto", excercises)),
              
                      ],),
            ),
          ],
        ),
      );
  }
}

class WorkoutCard extends StatefulWidget {
 const WorkoutCard(this.workoutName, this.excercises, {Key? key}) : super(key: key);

  final String workoutName;
  final List<String> excercises;

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {

  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> exc = [];
    int stop;
    if(isOpen){
      stop = excercises.length;
    }else{
      stop = 1;
    }
    for(int i=0;i<stop;i++){
      exc.add(Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Text(widget.excercises[i], style: const TextStyle(fontSize: 15, color: Colors.white)),
      ));
    }
    if(!isOpen){
      exc.add(const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Text("...", style: TextStyle(fontSize: 15, color: Colors.white)),
      ));
    }
    return GestureDetector(
      onTap: (){
        isOpen = !isOpen;
          setState(() {});
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 50, 50, 50), 
          borderRadius: BorderRadius.all(Radius.circular(20))),
        child: AnimatedSize(
          curve: Curves.linear,
          duration: const Duration(milliseconds: 100),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: Row(children: [
                  Text(widget.workoutName, style: const TextStyle(fontSize: 24, color: Colors.white)),
                  const Spacer(),
                  isOpen ? const Icon(Icons.expand_less_outlined, color: Colors.white,)
                         : const Icon(Icons.expand_more_outlined, color: Colors.white,)
                ],),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: exc),
                ),
              )
            ],),
          ),
        ),
      ),
    );
  }
}