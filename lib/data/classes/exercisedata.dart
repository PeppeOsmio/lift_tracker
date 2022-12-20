class ExerciseData {
  int id;
  String name;
  String type;
  String firstMuscle;
  String secondMuscle;
  String thirdMuscle;

  ExerciseData(
      {required this.id,
      required this.name,
      required this.type,
      this.firstMuscle = '',
      this.secondMuscle = '',
      this.thirdMuscle = ''});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'firstMuscle': firstMuscle,
      'secondMuscle': secondMuscle,
      'thirdMuscle': thirdMuscle
    };
  }
}
