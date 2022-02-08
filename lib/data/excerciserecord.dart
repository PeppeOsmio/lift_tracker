import 'package:lift_tracker/data/excercise.dart';

class ExcerciseRecord {
  ExcerciseRecord(this.excercise, this.reps_weight);
  final Excercise excercise;
  final List<Map<String, int>> reps_weight;
}
