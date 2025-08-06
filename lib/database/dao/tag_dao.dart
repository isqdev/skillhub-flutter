import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/tag_dto.dart';

class TagDao {
  static const String _tagsKey = 'tags_list';
  static const String _nextIdKey = 'next_tag_id';

  // Buscar todas as tags
  Future<List<TagDto>> findAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagsJson = prefs.getStringList(_tagsKey) ?? [];
      return tagsJson.map((json) => TagDto.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Erro ao buscar tags: $e');
      return [];
    }
  }

  // Inserir tag
  Future<int> insert(TagDto tag) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tags = await findAll();
      
      // Gerar ID único
      final nextId = prefs.getInt(_nextIdKey) ?? 1;
      final newTag = tag.copyWith(id: nextId);
      
      tags.add(newTag);
      await _saveTags(tags);
      await prefs.setInt(_nextIdKey, nextId + 1);
      
      return nextId;
    } catch (e) {
      print('Erro ao inserir tag: $e');
      throw Exception('Erro ao salvar tag');
    }
  }

  // Atualizar tag
  Future<int> update(TagDto tag) async {
    try {
      final tags = await findAll();
      final index = tags.indexWhere((t) => t.id == tag.id);
      
      if (index != -1) {
        tags[index] = tag;
        await _saveTags(tags);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Erro ao atualizar tag: $e');
      throw Exception('Erro ao atualizar tag');
    }
  }

  // Deletar tag
  Future<int> delete(int id) async {
    try {
      final tags = await findAll();
      final initialLength = tags.length;
      tags.removeWhere((tag) => tag.id == id);
      await _saveTags(tags);
      return initialLength - tags.length;
    } catch (e) {
      print('Erro ao deletar tag: $e');
      throw Exception('Erro ao deletar tag');
    }
  }

  // Buscar por nome
  Future<TagDto?> findByName(String name) async {
    try {
      final tags = await findAll();
      return tags.cast<TagDto?>().firstWhere(
        (tag) => tag?.name == name,
        orElse: () => null,
      );
    } catch (e) {
      print('Erro ao buscar tag por nome: $e');
      return null;
    }
  }

  // Verificar se nome existe
  Future<bool> nameExists(String name) async {
    final tag = await findByName(name);
    return tag != null;
  }

  // Método privado para salvar tags
  Future<void> _saveTags(List<TagDto> tags) async {
    final prefs = await SharedPreferences.getInstance();
    final tagsJson = tags.map((tag) => jsonEncode(tag.toJson())).toList();
    await prefs.setStringList(_tagsKey, tagsJson);
  }

  // Limpar todos os dados
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tagsKey);
    await prefs.remove(_nextIdKey);
  }

  // Método para adicionar dados de exemplo
  Future<void> addSampleData() async {
    final tags = await findAll();
    if (tags.isEmpty) {
      await insert(TagDto(name: 'Flutter'));
      await insert(TagDto(name: 'Dart'));
      await insert(TagDto(name: 'Mobile'));
      await insert(TagDto(name: 'Desenvolvimento'));
      await insert(TagDto(name: 'Programação'));
      await insert(TagDto(name: 'Web'));
      await insert(TagDto(name: 'Backend'));
      await insert(TagDto(name: 'Frontend'));
      await insert(TagDto(name: 'React'));
      await insert(TagDto(name: 'Vue.js'));
      await insert(TagDto(name: 'Angular'));
      await insert(TagDto(name: 'Node.js'));
      await insert(TagDto(name: 'Python'));
      await insert(TagDto(name: 'Java'));
      await insert(TagDto(name: 'JavaScript'));
      await insert(TagDto(name: 'TypeScript'));
      await insert(TagDto(name: 'UI/UX'));
      await insert(TagDto(name: 'Design'));
      await insert(TagDto(name: 'Data Science'));
      await insert(TagDto(name: 'Machine Learning'));
    }
  }
}