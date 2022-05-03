import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';

class ExerciseRecord {
  ExerciseRecord(this.exerciseName, this.sets,
      {required this.exerciseId, required this.type, this.temp = false});
  final String exerciseName;
  final List<ExerciseSet> sets;
  final int exerciseId;
  final String type;
  final bool temp;

  int volume() {
    int volume = 0;
    if (type != 'free') {
      for (var set in sets) {
        volume += set.volume();
      }
      return volume;
    }
    for (var set in sets) {
      volume += set.reps * 70;
    }
    return volume;
  }

  Map<String, dynamic> toMap() {
    return {
      'n': exerciseName,
      'sets': sets.map((e) => e.toMap()).toList(),
      'exId': exerciseId,
      'type': type,
    };
  }
}
