import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';

class ExerciseRecord {
  ExerciseRecord(
      {required this.exerciseData,
      required this.sets,
      required this.exerciseId,
      required this.type,
      this.temp = false});
  final ExerciseData exerciseData;
  final List<ExerciseSet> sets;
  final int exerciseId;
  final String type;
  bool temp;

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
      'jsonId': exerciseData.id,
      'sets': sets.map((e) => e.toMap()).toList(),
      'exId': exerciseId,
      'type': type,
    };
  }
}
