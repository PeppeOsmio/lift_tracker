import 'package:lift_tracker/data/classes/exercise.dart';

class Workout {
  List<Exercise> exercises;
  String name;
  int id;
  int hasCache;
  bool hasHistory;

  Workout(this.id, this.name, this.exercises,
      {this.hasCache = 0, this.hasHistory = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hasCache': hasCache,
      'exercises': exercises.map((e) => e.toMap()).toList()
    };
  }
}
