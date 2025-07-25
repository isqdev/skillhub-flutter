import 'package:sqflite/sqflite.dart';
import '../sqlite/conection.dart';
import '../../dto/event_dto.dart';
import 'base_dao.dart';

class EventDao extends BaseDao<EventDto> {
  @override
  String get tableName => 'events';

  @override
  Future<Database> get database => ConexaoSQLite.database;

  @override
  EventDto fromMap(Map<String, dynamic> map) {
    final tagsString = map['tags'] as String? ?? '';
    final tagsList = tagsString.isEmpty 
        ? <String>[] 
        : tagsString.split(',').map((tag) => tag.trim()).toList();
    
    return EventDto(
      id: map['id'] as int?,
      name: map['name'] as String,
      institution: map['institution'] as String,
      description: map['description'] as String,
      tags: tagsList,
    );
  }

  @override
  Map<String, dynamic> toMap(EventDto entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'institution': entity.institution,
      'description': entity.description,
      'tags': entity.tags.join(','),
    };
  }

  // Métodos específicos para Event
  Future<List<EventDto>> findByInstitution(String institution) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'institution LIKE ?',
      whereArgs: ['%$institution%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<EventDto>> findByTag(String tag) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<EventDto>> searchByName(String name) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<EventDto>> searchByDescription(String description) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'description LIKE ?',
      whereArgs: ['%$description%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<String>> getDistinctInstitutions() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT DISTINCT institution FROM $tableName ORDER BY institution');
    return maps.map((map) => map['institution'] as String).toList();
  }
}
