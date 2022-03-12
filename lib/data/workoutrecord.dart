import 'package:lift_tracker/data/workout.dart';

import 'exerciserecord.dart';

class WorkoutRecord {
  WorkoutRecord(this.id, this.day, this.workoutName, this.exerciseRecords,
      {required this.workoutId});
  int id;
  final DateTime day;
  final String workoutName;
  final int workoutId;
  final List<ExerciseRecord> exerciseRecords;
}
