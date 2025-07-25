import 'package:sqflite/sqflite.dart';
import '../sqlite/conection.dart';
import '../../dto/favorite_course_dto.dart';
import 'base_dao.dart';

class FavoriteCourseDao extends BaseDao<FavoriteCourseDto> {
  @override
  String get tableName => 'favorite_courses';

  @override
  Future<Database> get database => ConexaoSQLite.database;

  @override
  FavoriteCourseDto fromMap(Map<String, dynamic> map) {
    return FavoriteCourseDto(
      id: map['id'] as int?,
      name: map['name'] as String,
      instructor: map['instructor'] as String,
      duration: map['duration'] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(FavoriteCourseDto entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'instructor': entity.instructor,
      'duration': entity.duration,
    };
  }

  // Métodos específicos para FavoriteCourse
  Future<List<FavoriteCourseDto>> findByInstructor(String instructor) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'instructor LIKE ?',
      whereArgs: ['%$instructor%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<FavoriteCourseDto>> findByMinDuration(int minDuration) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'duration >= ?',
      whereArgs: [minDuration],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<FavoriteCourseDto>> findByDurationRange(int minDuration, int maxDuration) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'duration >= ? AND duration <= ?',
      whereArgs: [minDuration, maxDuration],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<FavoriteCourseDto>> searchByName(String name) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<int> getTotalDuration() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(duration) as total FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getAverageDuration() async {
    final db = await database;
    final result = await db.rawQuery('SELECT AVG(duration) as average FROM $tableName');
    final value = result.first['average'];
    return value != null ? (value as double) : 0.0;
  }

  Future<List<String>> getDistinctInstructors() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT DISTINCT instructor FROM $tableName ORDER BY instructor');
    return maps.map((map) => map['instructor'] as String).toList();
  }

  Future<bool> isFavorite(String courseName) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [courseName],
    );
    return maps.isNotEmpty;
  }
}
