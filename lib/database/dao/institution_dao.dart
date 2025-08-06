import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/institution_dto.dart';
import '../../database/dao/area_dao.dart';

class InstitutionDao {
  static const String _institutionsKey = 'institutions_list';
  static const String _nextIdKey = 'next_institution_id';

  final AreaDao _areaDao = AreaDao();

  // Buscar todas as instituições
  Future<List<InstitutionDto>> findAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final institutionsJson = prefs.getStringList(_institutionsKey) ?? [];
      return institutionsJson.map((json) => InstitutionDto.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Erro ao buscar instituições: $e');
      return [];
    }
  }

  // Inserir instituição
  Future<void> insert(InstitutionDto institution) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final institutions = await findAll();
      
      // Verificar se a instituição já existe
      if (!institutions.any((i) => i.name == institution.name)) {
        // Gerar ID único
        final nextId = prefs.getInt(_nextIdKey) ?? 1;
        final newInstitution = institution.copyWith(id: nextId);
        
        institutions.add(newInstitution);
        await _saveInstitutions(institutions);
        await prefs.setInt(_nextIdKey, nextId + 1);
      }
    } catch (e) {
      print('Erro ao inserir instituição: $e');
      throw Exception('Erro ao salvar instituição');
    }
  }

  // Atualizar instituição
  Future<void> update(InstitutionDto institution) async {
    try {
      final institutions = await findAll();
      final index = institutions.indexWhere((i) => i.id == institution.id);
      if (index != -1) {
        institutions[index] = institution;
        await _saveInstitutions(institutions);
      }
    } catch (e) {
      print('Erro ao atualizar instituição: $e');
      throw Exception('Erro ao atualizar instituição');
    }
  }

  // Deletar instituição
  Future<void> delete(int id) async {
    try {
      final institutions = await findAll();
      institutions.removeWhere((i) => i.id == id);
      await _saveInstitutions(institutions);
    } catch (e) {
      print('Erro ao deletar instituição: $e');
      throw Exception('Erro ao deletar instituição');
    }
  }

  // Método privado para salvar instituições
  Future<void> _saveInstitutions(List<InstitutionDto> institutions) async {
    final prefs = await SharedPreferences.getInstance();
    final institutionsJson = institutions.map((institution) => jsonEncode(institution.toJson())).toList();
    await prefs.setStringList(_institutionsKey, institutionsJson);
  }

  // Método para inicializar dados padrão
  Future<void> addSampleData() async {
  try {
    final institutions = await findAll();
    if (institutions.isEmpty) {
      final defaultInstitutions = [
        InstitutionDto(
          name: 'Universidade Federal de Minas Gerais',
          state: 'Minas Gerais',
          city: 'Belo Horizonte',
          area: 'Educação',
          type: 'Pública',
        ),
        InstitutionDto(
          name: 'Instituto Tecnológico de Aeronáutica',
          state: 'São Paulo',
          city: 'São José dos Campos',
          area: 'Tecnologia',
          type: 'Pública',
        ),
        InstitutionDto(
          name: 'SENAI',
          state: 'Rio de Janeiro',
          city: 'Rio de Janeiro',
          area: 'Educação',
          type: 'Sistema S',
        ),
        InstitutionDto(
          name: 'Universidade de São Paulo',
          state: 'São Paulo',
          city: 'São Paulo',
          area: 'Educação',
          type: 'Pública',
        ),
        InstitutionDto(
          name: 'Pontifícia Universidade Católica do Rio de Janeiro',
          state: 'Rio de Janeiro',
          city: 'Rio de Janeiro',
          area: 'Educação',
          type: 'Privada',
        ),
        InstitutionDto(
          name: 'FIAP',
          state: 'São Paulo',
          city: 'São Paulo',
          area: 'Tecnologia',
          type: 'Privada',
        ),
        InstitutionDto(
          name: 'Universidade Federal do Rio de Janeiro',
          state: 'Rio de Janeiro',
          city: 'Rio de Janeiro',
          area: 'Educação',
          type: 'Pública',
        ),
        InstitutionDto(
          name: 'Instituto Federal de São Paulo',
          state: 'São Paulo',
          city: 'São Paulo',
          area: 'Educação',
          type: 'Pública',
        ),
        InstitutionDto(
          name: 'Udemy',
          state: 'Nacional',
          city: 'Online',
          area: 'Educação',
          type: 'Privada',
        ),
        InstitutionDto(
          name: 'Coursera',
          state: 'Internacional',
          city: 'Online',
          area: 'Educação',
          type: 'Privada',
        ),
      ];

      for (var institution in defaultInstitutions) {
        await insert(institution);
      }
    }
  } catch (e) {
    print('Erro ao adicionar dados de exemplo: $e');
  }
}
}
