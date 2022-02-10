import 'package:lift_tracker/data/excercise.dart';

class ExcerciseRecord {
  ExcerciseRecord(this.excercise, this.reps_weight_rpe);
  final Excercise excercise;
  final List<Map<String, double>> reps_weight_rpe;
}
