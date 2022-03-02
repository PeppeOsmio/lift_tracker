import 'package:flutter/material.dart';
import 'workoutlist/workoutlist.dart';

class Excercises extends StatefulWidget {
  const Excercises({Key? key}) : super(key: key);

  @override
  _ExcercisesState createState() => _ExcercisesState();
}

class _ExcercisesState extends State<Excercises> {
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
                    child: Icon(
                      Icons.search_outlined,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  )),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: const [
                Padding(padding: EdgeInsets.all(16), child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
