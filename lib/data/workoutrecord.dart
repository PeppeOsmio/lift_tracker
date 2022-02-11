import 'package:lift_tracker/data/workout.dart';

import 'excerciserecord.dart';

class WorkoutRecord {
  WorkoutRecord(this.day, this.workoutName, this.excerciseRecords);

  final DateTime day;
  final String workoutName;
  final List<ExcerciseRecord> excerciseRecords;
}
