import 'package:lift_tracker/data/excercise.dart';

class ExcerciseRecord {
  ExcerciseRecord(this.excerciseName, this.reps_weight_rpe);
  final String excerciseName;
  final List<Map<String, dynamic>> reps_weight_rpe;
}
