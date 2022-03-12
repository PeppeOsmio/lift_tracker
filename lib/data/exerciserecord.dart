import 'package:lift_tracker/data/exercise.dart';

class ExerciseRecord {
  ExerciseRecord(this.exerciseName, this.reps_weight_rpe,
      {required this.exerciseId});
  final String exerciseName;
  final List<Map<String, dynamic>> reps_weight_rpe;
  final int exerciseId;
}
