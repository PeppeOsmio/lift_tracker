class Excercise {
  int id;
  String name;
  int reps;
  int sets;
  double? weightRecord;
  String? type;

  Excercise(
      {required this.id,
      required this.name,
      required this.sets,
      required this.reps,
      this.weightRecord,
      this.type});
}
