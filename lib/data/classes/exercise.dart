import 'package:lift_tracker/data/classes/exercisedata.dart';

class Exercise {
  int id;
  int workoutId;
  ExerciseData exerciseData;
  int reps;
  int sets;
  double? bestWeight;
  int? bestVolume;
  int? bestReps;
  String? notes;

  Exercise(
      {required this.workoutId,
      required this.id,
      required this.sets,
      required this.reps,
      required this.exerciseData,
      this.bestWeight,
      this.bestVolume,
      this.bestReps,
      this.notes});
}
