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
}
