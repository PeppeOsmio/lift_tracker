import 'package:lift_tracker/data/classes/exercise.dart';
import 'package:lift_tracker/data/classes/exerciseset.dart';

class ExerciseRecord {
  ExerciseRecord(this.exerciseName, this.reps_weight_rpe,
      {required this.exerciseId, required this.type, this.temp = false});
  final String exerciseName;
  final List<ExerciseSet> reps_weight_rpe;
  final int exerciseId;
  final String type;
  final bool temp;
}
