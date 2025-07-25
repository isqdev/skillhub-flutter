import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/certificate_type_dto.dart';

class CertificateTypeDao {
  static const String _certificateTypesKey = 'certificate_types_list';
  static const String _nextIdKey = 'next_certificate_type_id';

  // Buscar todos os tipos de certificado
  Future<List<CertificateTypeDto>> findAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typesJson = prefs.getStringList(_certificateTypesKey) ?? [];
      return typesJson.map((json) => CertificateTypeDto.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Erro ao buscar tipos de certificado: $e');
      return [];
    }
  }

  // Inserir tipo de certificado
  Future<int> insert(CertificateTypeDto type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final types = await findAll();
      
      // Gerar ID único
      final nextId = prefs.getInt(_nextIdKey) ?? 1;
      final newType = type.copyWith(id: nextId);
      
      types.add(newType);
      await _saveTypes(types);
      await prefs.setInt(_nextIdKey, nextId + 1);
      
      return nextId;
    } catch (e) {
      print('Erro ao inserir tipo de certificado: $e');
      throw Exception('Erro ao salvar tipo de certificado');
    }
  }

  // Atualizar tipo de certificado
  Future<int> update(CertificateTypeDto type) async {
    try {
      final types = await findAll();
      final index = types.indexWhere((t) => t.id == type.id);
      
      if (index != -1) {
        types[index] = type;
        await _saveTypes(types);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Erro ao atualizar tipo de certificado: $e');
      throw Exception('Erro ao atualizar tipo de certificado');
    }
  }

  // Deletar tipo de certificado
  Future<int> delete(int id) async {
    try {
      final types = await findAll();
      final initialLength = types.length;
      types.removeWhere((type) => type.id == id);
      await _saveTypes(types);
      return initialLength - types.length;
    } catch (e) {
      print('Erro ao deletar tipo de certificado: $e');
      throw Exception('Erro ao deletar tipo de certificado');
    }
  }

  // Buscar por nome
  Future<CertificateTypeDto?> findByName(String name) async {
    try {
      final types = await findAll();
      return types.cast<CertificateTypeDto?>().firstWhere(
        (type) => type?.name == name,
        orElse: () => null,
      );
    } catch (e) {
      print('Erro ao buscar tipo de certificado por nome: $e');
      return null;
    }
  }

  // Buscar por nome (busca parcial)
  Future<List<CertificateTypeDto>> searchByName(String name) async {
    try {
      final types = await findAll();
      return types.where((type) => 
        type.name.toLowerCase().contains(name.toLowerCase())
      ).toList();
    } catch (e) {
      print('Erro ao buscar tipos de certificado por nome: $e');
      return [];
    }
  }

  // Buscar por descrição
  Future<List<CertificateTypeDto>> searchByDescription(String description) async {
    try {
      final types = await findAll();
      return types.where((type) => 
        type.description.toLowerCase().contains(description.toLowerCase())
      ).toList();
    } catch (e) {
      print('Erro ao buscar tipos de certificado por descrição: $e');
      return [];
    }
  }

  // Verificar se nome existe
  Future<bool> nameExists(String name) async {
    final type = await findByName(name);
    return type != null;
  }

  // Obter todos os nomes dos tipos
  Future<List<String>> getAllTypeNames() async {
    final types = await findAll();
    return types.map((type) => type.name).toList()..sort();
  }

  // Encontrar ou criar tipo
  Future<CertificateTypeDto> findOrCreate(String name, String description) async {
    CertificateTypeDto? existingType = await findByName(name);
    
    if (existingType != null) {
      return existingType;
    }
    
    final newType = CertificateTypeDto(name: name, description: description);
    final id = await insert(newType);
    return newType.copyWith(id: id);
  }

  // Método privado para salvar tipos
  Future<void> _saveTypes(List<CertificateTypeDto> types) async {
    final prefs = await SharedPreferences.getInstance();
    final typesJson = types.map((type) => jsonEncode(type.toJson())).toList();
    await prefs.setStringList(_certificateTypesKey, typesJson);
  }

  // Limpar todos os dados (útil para testes)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_certificateTypesKey);
    await prefs.remove(_nextIdKey);
  }

  // Método para adicionar dados de exemplo (para testes)
  Future<void> addSampleData() async {
    final types = await findAll();
    if (types.isEmpty) {
      await insert(CertificateTypeDto(name: 'Curso', description: 'Certificados de cursos de longa duração'));
      await insert(CertificateTypeDto(name: 'Minicurso', description: 'Certificados de cursos rápidos'));
      await insert(CertificateTypeDto(name: 'Workshop', description: 'Certificados de workshops práticos'));
      await insert(CertificateTypeDto(name: 'Palestra', description: 'Certificados de participação em palestras'));
    }
  }
}
