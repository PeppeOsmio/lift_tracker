class Exercise {
  int id;
  int workoutId;
  String name;
  int reps;
  int sets;
  double? weightRecord;
  String? type;

  Exercise(
      {required this.workoutId,
      required this.id,
      required this.name,
      required this.sets,
      required this.reps,
      this.weightRecord,
      this.type});
}
