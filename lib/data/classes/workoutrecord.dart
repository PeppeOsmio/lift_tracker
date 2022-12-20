import 'exerciserecord.dart';

class WorkoutRecord {
  WorkoutRecord(this.id, this.day, this.workoutName, this.exerciseRecords,
      {required this.workoutId, this.isCache = 0});
  int id;
  final DateTime day;
  final String workoutName;
  final int workoutId;
  final List<ExerciseRecord> exerciseRecords;
  final int isCache;

  int totalVolume() {
    int volume = 0;
    for (var exerciseRecord in exerciseRecords) {
      volume += exerciseRecord.volume();
    }
    return volume;
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day.toString(),
      'workoutName': workoutName,
      'workoutId': workoutId,
      'isCache': isCache,
      'exerciseRecords': exerciseRecords.map((e) => e.toMap()).toList()
    };
  }
}
