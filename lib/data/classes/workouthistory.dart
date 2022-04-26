import 'package:lift_tracker/data/classes/workout.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';

class WorkoutHistory {
  WorkoutHistory({required this.workout, required this.workoutRecords});
  Workout workout;
  List<WorkoutRecord> workoutRecords;
}
