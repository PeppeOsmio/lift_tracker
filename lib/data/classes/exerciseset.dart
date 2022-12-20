class ExerciseSet {
  ExerciseSet(
      {required this.weight,
      required this.reps,
      this.rpe,
      this.has1RMRecord = 0,
      this.hasWeightRecord = 0,
      this.hasRepsRecord = 0});

  double weight;
  int reps;
  int? rpe;
  int has1RMRecord;
  int hasWeightRecord;
  int hasRepsRecord;

  int volume() {
    return (reps * weight).round();
  }

  double oneRM() {
    if (rpe != null) {
      return double.parse((weight / (1.0278 - (0.0278 * (reps + 10 - rpe!))))
          .toStringAsFixed(2));
    }
    return double.parse(
        (weight / (1.0278 - (0.0278 * reps))).toStringAsFixed(2));
  }

  Map<String, dynamic> toMap() {
    return {
      'weight': weight.toString(),
      'reps': reps.toString(),
      'rpe': rpe.toString(),
      'has1RMRecord': has1RMRecord,
      'hasWeightRecord': hasWeightRecord,
      'hasRepsRecord': hasRepsRecord
    };
  }
}
