import 'package:lift_tracker/data/excercise.dart';

class Workout {
  List<Excercise> excercises;
  String name;
  int id;

  Workout(this.id, this.name, this.excercises);
}
