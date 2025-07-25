import 'package:sqflite/sqflite.dart';
import '../sqlite/conection.dart';
import '../../dto/tag_dto.dart';
import 'base_dao.dart';

class TagDao extends BaseDao<TagDto> {
  @override
  String get tableName => 'tags';

  @override
  Future<Database> get database => ConexaoSQLite.database;

  @override
  TagDto fromMap(Map<String, dynamic> map) {
    return TagDto(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(TagDto entity) {
    return {
      'id': entity.id,
      'name': entity.name,
    };
  }

  // Métodos específicos para Tag
  Future<TagDto?> findByName(String name) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );
    
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  Future<List<TagDto>> searchByName(String name) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<bool> nameExists(String name) async {
    final tag = await findByName(name);
    return tag != null;
  }

  Future<List<String>> getAllTagNames() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT name FROM $tableName ORDER BY name');
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<TagDto> findOrCreate(String name) async {
    TagDto? existingTag = await findByName(name);
    
    if (existingTag != null) {
      return existingTag;
    }
    
    final newTag = TagDto(name: name);
    final id = await insert(newTag);
    return newTag.copyWith(id: id);
  }

  Future<List<TagDto>> findOrCreateMultiple(List<String> names) async {
    List<TagDto> tags = [];
    
    for (String name in names) {
      final tag = await findOrCreate(name.trim());
      tags.add(tag);
    }
    
    return tags;
  }
}
