class Exercise {
  int id;
  int workoutId;
  String name;
  int jsonId;
  int reps;
  int sets;
  String type;
  double? bestWeight;
  int? bestVolume;
  int? bestReps;

  Exercise(
      {required this.workoutId,
      required this.jsonId,
      required this.id,
      required this.name,
      required this.sets,
      required this.reps,
      required this.type,
      this.bestWeight,
      this.bestVolume,
      this.bestReps});
}
