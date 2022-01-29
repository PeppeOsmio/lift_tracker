import 'package:flutter/material.dart';

class NewWorkout extends StatefulWidget {
  const NewWorkout({ Key? key }) : super(key: key);

  @override
  _NewWorkoutState createState() => _NewWorkoutState();
}

class _NewWorkoutState extends State<NewWorkout> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
        appBar: AppBar(elevation: 0, backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(children: 
        [
        Material(
          color: const Color.fromARGB(255, 31, 31, 31),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 35,
            width: 35,
            child: InkWell(
            radius: 17.5,
            borderRadius: BorderRadius.circular(10),
            onTap: (){Navigator.pop(context);},
            child:
            const Icon(Icons.chevron_left_outlined))),
        ),
          const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Text("New workout"),
        )
        ],),
      ),
      toolbarHeight: 79,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: Column(children: [
          const Text("Workout name", style: TextStyle(fontSize: 25, color: Colors.white),)
        ],),
      ),
    ));
  }
}