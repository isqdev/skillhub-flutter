import 'package:sqflite/sqflite.dart';
import '../sqlite/conection.dart';
import '../../dto/institution_dto.dart';
import 'base_dao.dart';

class InstitutionDao extends BaseDao<InstitutionDto> {
  @override
  String get tableName => 'institutions';

  @override
  Future<Database> get database => ConexaoSQLite.database;

  @override
  InstitutionDto fromMap(Map<String, dynamic> map) {
    return InstitutionDto(
      id: map['id'] as int?,
      name: map['name'] as String,
      state: map['state'] as String,
      city: map['city'] as String,
      area: map['area'] as String,
      type: map['type'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(InstitutionDto entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'state': entity.state,
      'city': entity.city,
      'area': entity.area,
      'type': entity.type,
    };
  }

  // Métodos específicos para Institution
  Future<List<InstitutionDto>> findByState(String state) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'state = ?',
      whereArgs: [state],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<InstitutionDto>> findByType(String type) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'type = ?',
      whereArgs: [type],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<InstitutionDto>> findByArea(String area) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'area LIKE ?',
      whereArgs: ['%$area%'],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<InstitutionDto>> findByCity(String city) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'city = ?',
      whereArgs: [city],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<List<String>> getDistinctStates() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT DISTINCT state FROM $tableName ORDER BY state');
    return maps.map((map) => map['state'] as String).toList();
  }

  Future<List<String>> getDistinctTypes() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT DISTINCT type FROM $tableName ORDER BY type');
    return maps.map((map) => map['type'] as String).toList();
  }
}
