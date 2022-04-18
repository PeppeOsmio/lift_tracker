class Exercise {
  int id;
  int workoutId;
  String name;
  int jsonId;
  int reps;
  int sets;
  String type;

  Exercise(
      {required this.workoutId,
      required this.jsonId,
      required this.id,
      required this.name,
      required this.sets,
      required this.reps,
      required this.type});
}
