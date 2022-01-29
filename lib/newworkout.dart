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
          child: SizedBox(
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
          child: Text("New workout",),
        )
        ],),
      ),
      toolbarHeight: 79,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text("Workout name", style: TextStyle(fontSize: 20, color: Colors.white),),
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 24),
          child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 31, 31, 31), 
                  borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: const TextField(
                      decoration: InputDecoration(border: InputBorder.none),
                      style: TextStyle(color: Colors.white,fontSize: 20), ),
                ),
        ),
        const SizedBox(height: 24),
        const Text("Excercises", style: TextStyle(fontSize: 20, color: Colors.white)),
        SizedBox(height: 48),
        Center(
          child: SizedBox(
            height: 65,
            width: 65,
            child: FloatingActionButton(
            onPressed: (){},
            backgroundColor: Color.fromARGB(255, 31, 31, 31),
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            child: const FittedBox(child: Icon(Icons.add_outlined),),),
          ),
        ),
        ],),
      ),
    ));
  }
}