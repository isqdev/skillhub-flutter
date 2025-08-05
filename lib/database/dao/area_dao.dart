import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/area_dto.dart';

class AreaDao {
  static const String _areasKey = 'areas_list';
  static const String _nextIdKey = 'next_area_id';

  // Buscar todas as áreas
  Future<List<AreaDto>> findAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final areasJson = prefs.getStringList(_areasKey) ?? [];
      return areasJson.map((json) => AreaDto.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Erro ao buscar áreas: $e');
      return [];
    }
  }

  // Inserir área
  Future<int> insert(AreaDto area) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final areas = await findAll();
      
      // Gerar ID único
      final nextId = prefs.getInt(_nextIdKey) ?? 1;
      final newArea = area.copyWith(id: nextId);
      
      areas.add(newArea);
      await _saveAreas(areas);
      await prefs.setInt(_nextIdKey, nextId + 1);
      
      return nextId;
    } catch (e) {
      print('Erro ao inserir área: $e');
      throw Exception('Erro ao salvar área');
    }
  }

  // Atualizar área
  Future<int> update(AreaDto area) async {
    try {
      final areas = await findAll();
      final index = areas.indexWhere((a) => a.id == area.id);
      
      if (index != -1) {
        areas[index] = area;
        await _saveAreas(areas);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Erro ao atualizar área: $e');
      throw Exception('Erro ao atualizar área');
    }
  }

  // Deletar área
  Future<int> delete(int id) async {
    try {
      final areas = await findAll();
      final initialLength = areas.length;
      areas.removeWhere((area) => area.id == id);
      await _saveAreas(areas);
      return initialLength - areas.length;
    } catch (e) {
      print('Erro ao deletar área: $e');
      throw Exception('Erro ao deletar área');
    }
  }

  // Buscar por nome
  Future<AreaDto?> findByName(String name) async {
    try {
      final areas = await findAll();
      return areas.cast<AreaDto?>().firstWhere(
        (area) => area?.name.toLowerCase() == name.toLowerCase(),
        orElse: () => null,
      );
    } catch (e) {
      print('Erro ao buscar área por nome: $e');
      return null;
    }
  }

  // Método privado para salvar áreas
  Future<void> _saveAreas(List<AreaDto> areas) async {
    final prefs = await SharedPreferences.getInstance();
    final areasJson = areas.map((area) => jsonEncode(area.toJson())).toList();
    await prefs.setStringList(_areasKey, areasJson);
  }

  // Limpar todos os dados
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_areasKey);
    await prefs.remove(_nextIdKey);
  }

  // Método para adicionar dados de exemplo
  Future<void> addSampleData() async {
    final areas = await findAll();
    if (areas.isEmpty) {
      await insert(AreaDto(
        name: 'Tecnologia da Informação',
        description: 'Desenvolvimento de software e sistemas',
      ));
      await insert(AreaDto(
        name: 'Engenharia',
        description: 'Engenharias diversas',
      ));
      await insert(AreaDto(
        name: 'Administração',
        description: 'Gestão e administração empresarial',
      ));
    }
  }
}
