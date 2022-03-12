import 'package:lift_tracker/data/exercise.dart';

class Workout {
  List<Exercise> exercises;
  String name;
  int id;

  Workout(this.id, this.name, this.exercises);
}
