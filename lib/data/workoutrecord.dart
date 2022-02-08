import 'package:lift_tracker/data/workout.dart';

import 'excerciserecord.dart';

class WorkoutRecord {
  WorkoutRecord(this.day, this.workout, this.excerciseRecords);

  final DateTime day;
  final Workout workout;
  final List<ExcerciseRecord> excerciseRecords;
}
