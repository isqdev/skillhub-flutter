import 'package:sqflite/sqflite.dart';

abstract class BaseDao<T> {
  String get tableName;
  
  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T entity);

  Future<Database> get database;

  Future<int> insert(T entity) async {
    final db = await database;
    final map = toMap(entity);
    map.remove('id'); // Remove ID para auto-increment
    return await db.insert(tableName, map);
  }

  Future<List<T>> findAll() async {
    final db = await database;
    final maps = await db.query(tableName);
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<T?> findById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  Future<int> update(T entity) async {
    final db = await database;
    final map = toMap(entity);
    final id = map['id'];
    map.remove('id');
    
    return await db.update(
      tableName,
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
