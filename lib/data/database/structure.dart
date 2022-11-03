import 'dart:developer';

import 'package:sqflite/sqflite.dart';

class Structure {
  static final instance = Structure._init();

  Structure._init();

  final Map<String, String> queries = {
    'workout': '''
    CREATE TABLE workout(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(33) NOT NULL,
      has_cache BIT DEFAULT 0
    );
    ''',
    'exercise': '''
    CREATE TABLE exercise(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      json_id INTEGER NOT NULL,
      type VARCHAR(20) NOT NULL,
      sets INTEGER NOT NULL,
      reps INTEGER NOT NULL,
      order_number INTEGER NOT NULL,
      notes VARCHAR(300),
      best_weight DOUBLE(5,2),
      best_volume INTEGER,
      best_reps INTEGER,
      fk_workout_id INTEGER NOT NULL,
      FOREIGN KEY (fk_workout_id) REFERENCES workout(id)
    );
    ''',
    'best_weight_volume_reps': '''
    CREATE TABLE best_weight_volume_reps(
      json_id INTEGER PRIMARY KEY,
      best_weight DOUBLE(5,2),
      best_volume INTEGER,
      best_reps INTEGER
    );
    ''',
    'workout_record': '''
    CREATE TABLE workout_record(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      day INTEGER NOT NULL,
      workout_name VARCHAR(33) NOT NULL,
      fk_workout_id INTEGER NOT NULL,
      is_cache BIT DEFAULT 0,
      FOREIGN KEY (fk_workout_id) REFERENCES workout(id)
    );
    ''',
    'exercise_record': '''
    CREATE TABLE exercise_record(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      json_id INTEGER NOT NULL,
      fk_workout_record_id INTEGER NOT NULL,
      fk_exercise_id INTEGER NOT NULL,
      position_in_workout_record INTEGER NOT NULL,
      type VARCHAR(20) NOT NULL,
      FOREIGN KEY (fk_workout_record_id) REFERENCES workout_record(id),
      FOREIGN KEY (fk_exercise_id) REFERENCES exercise(id)
    );
    ''',
    'exercise_set': '''
    CREATE TABLE exercise_set(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      reps INTEGER NOT NULL,
      weight DOUBLE(5,2) NOT NULL,
      rpe INTEGER,
      fk_exercise_record_id INTEGER NOT NULL,
      has_weight_record BIT NOT NULL DEFAULT 0,
      has_volume_record BIT NOT NULL DEFAULT 0,
      has_reps_record BIT NOT NULL DEFAULT 0,
      FOREIGN KEY (fk_exercise_record_id) REFERENCES exercise_record(id)
    );
    '''
  };

  final List<String> tables = [
    'workout',
    'exercise',
    'best_weight_volume_reps',
    'workout_record',
    'exercise_record',
    'exercise_set'
  ];

  Future createDB(Database db, int version) async {
    await db.execute(queries['workout']!);

    await db.execute(queries['exercise']!);

    await db.execute(queries['best_weight_volume_reps']!);

    await db.execute(queries['workout_record']!);

    await db.execute(queries['exercise_record']!);

    await db.execute(queries['exercise_set']!);
  }
}
