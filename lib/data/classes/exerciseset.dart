class ExerciseSet {
  ExerciseSet(
      {required this.weight,
      required this.reps,
      this.rpe,
      this.hasVolumeRecord = 0,
      this.hasWeightRecord = 0,
      this.hasRepsRecord = 0});

  double weight;
  int reps;
  int? rpe;
  int hasVolumeRecord;
  int hasWeightRecord;
  int hasRepsRecord;
}
