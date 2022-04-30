import 'package:lift_tracker/data/classes/workout.dart';

import 'exerciserecord.dart';

class WorkoutRecord {
  WorkoutRecord(this.id, this.day, this.workoutName, this.exerciseRecords,
      {required this.workoutId});
  int id;
  final DateTime day;
  final String workoutName;
  final int workoutId;
  final List<ExerciseRecord> exerciseRecords;

  double totalVolume() {
    double volume = 0;
    for (var exerciseRecord in exerciseRecords) {
      volume += exerciseRecord.volume();
    }
    return volume;
  }
}
