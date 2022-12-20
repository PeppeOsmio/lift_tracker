import 'package:lift_tracker/data/classes/exercisedata.dart';

class Exercise {
  int id;
  int workoutId;
  ExerciseData exerciseData;
  int reps;
  int sets;
  double? bestWeight;
  double? best1RM;
  int? bestReps;
  String? notes;

  Exercise(
      {required this.workoutId,
      required this.id,
      required this.sets,
      required this.reps,
      required this.exerciseData,
      this.bestWeight,
      this.best1RM,
      this.bestReps,
      this.notes});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseData': exerciseData.toMap(),
      'reps': reps,
      'sets': sets,
      'bestWeight': bestWeight,
      'best1RM': best1RM,
      'bestReps': bestReps,
      'notes': notes
    };
  }
}
