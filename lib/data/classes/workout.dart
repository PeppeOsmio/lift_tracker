import 'package:lift_tracker/data/classes/exercise.dart';

class Workout {
  List<Exercise> exercises;
  String name;
  int id;

  Workout(this.id, this.name, this.exercises);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'n': name,
      'ex': exercises.map((e) => e.toMap()).toList()
    };
  }
}
