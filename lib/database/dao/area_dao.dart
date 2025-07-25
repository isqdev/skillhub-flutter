import 'package:sqflite/sqflite.dart';
import '../sqlite/conection.dart';
import '../../dto/area_dto.dart';
import 'base_dao.dart';

class AreaDao extends BaseDao<AreaDto> {
  @override
  String get tableName => 'areas';

  @override
  Future<Database> get database => ConexaoSQLite.database;

  @override
  AreaDto fromMap(Map<String, dynamic> map) {
    return AreaDto(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(AreaDto entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'description': entity.description,
    };
  }

  // Métodos específicos para Area
  Future<AreaDto?> findByName(String name) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );
    
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  Future<List<AreaDto>> searchByName(String name) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<AreaDto>> searchByDescription(String description) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'description LIKE ?',
      whereArgs: ['%$description%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<bool> nameExists(String name) async {
    final area = await findByName(name);
    return area != null;
  }

  Future<List<String>> getAllAreaNames() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT name FROM $tableName ORDER BY name');
    return maps.map((map) => map['name'] as String).toList();
  }
}
