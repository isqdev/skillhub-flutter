import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/event_dto.dart';
import 'package:meu_app/database/dao/institution_dao.dart';
import '../../dto/institution_dto.dart';

class EventDao {
  static const String _eventsKey = 'events_list';
  static const String _nextIdKey = 'next_event_id';

  final InstitutionDao _institutionDao = InstitutionDao();

  // Buscar todos os eventos
  Future<List<EventDto>> findAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList(_eventsKey) ?? [];
      return eventsJson.map((json) => EventDto.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Erro ao buscar eventos: $e');
      return [];
    }
  }

  // Inserir evento
  Future<int> insert(EventDto event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = await findAll();
      
      // Gerar ID único
      final nextId = prefs.getInt(_nextIdKey) ?? 1;
      final newEvent = event.copyWith(id: nextId);
      
      events.add(newEvent);
      await _saveEvents(events);
      await prefs.setInt(_nextIdKey, nextId + 1);
      
      return nextId;
    } catch (e) {
      print('Erro ao inserir evento: $e');
      throw Exception('Erro ao salvar evento');
    }
  }

  // Atualizar evento
  Future<int> update(EventDto event) async {
    try {
      final events = await findAll();
      final index = events.indexWhere((e) => e.id == event.id);
      
      if (index != -1) {
        events[index] = event;
        await _saveEvents(events);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Erro ao atualizar evento: $e');
      throw Exception('Erro ao atualizar evento');
    }
  }

  // Deletar evento
  Future<int> delete(int id) async {
    try {
      final events = await findAll();
      final initialLength = events.length;
      events.removeWhere((event) => event.id == id);
      await _saveEvents(events);
      return initialLength - events.length;
    } catch (e) {
      print('Erro ao deletar evento: $e');
      throw Exception('Erro ao deletar evento');
    }
  }

  // Buscar por nome
  Future<EventDto?> findByName(String name) async {
    try {
      final events = await findAll();
      return events.cast<EventDto?>().firstWhere(
        (event) => event?.name == name,
        orElse: () => null,
      );
    } catch (e) {
      print('Erro ao buscar evento por nome: $e');
      return null;
    }
  }

  // Buscar por instituição
  Future<List<EventDto>> findByInstitution(String institution) async {
    try {
      final events = await findAll();
      return events.where((event) => 
        event.institution.toLowerCase().contains(institution.toLowerCase())
      ).toList();
    } catch (e) {
      print('Erro ao buscar eventos por instituição: $e');
      return [];
    }
  }

  // Método privado para salvar eventos
  Future<void> _saveEvents(List<EventDto> events) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = events.map((event) => jsonEncode(event.toJson())).toList();
    await prefs.setStringList(_eventsKey, eventsJson);
  }

  // Limpar todos os dados
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
    await prefs.remove(_nextIdKey);
  }

  // Método para adicionar dados de exemplo
  Future<void> addSampleData() async {
    try {
      final events = await findAll();
      if (events.isEmpty) {
        // Garantir que instituições existam primeiro
        await _institutionDao.addSampleData();
        
        // Buscar instituições existentes do banco de dados
        final institutions = await _institutionDao.findAll();
        
        if (institutions.isNotEmpty) {
          // Usar instituições reais do banco de dados
          await insert(EventDto(
            name: 'Flutter Dev Week',
            institution: institutions[0].name, // UFMG
            description: 'Semana de desenvolvimento Flutter',
            profession: 'Desenvolvimento'
          ));
          
          await insert(EventDto(
            name: 'Workshop UX/UI',
            institution: institutions[1].name, // ITA
            description: 'Workshop de design de interfaces',
            profession: 'Design'
          ));
          
          await insert(EventDto(
            name: 'Hackathon 2025',
            institution: institutions[2].name, // SENAI
            description: 'Maratona de programação',
            profession: 'Desenvolvimento'
          ));
          
          // Adicionar mais eventos se houver mais instituições
          if (institutions.length > 3) {
            await insert(EventDto(
              name: 'Semana da Tecnologia',
              institution: institutions[0].name,
              description: 'Evento anual de tecnologia e inovação',
              profession: 'Tecnologia'
            ));
          }
        }
      }
    } catch (e) {
      print('Erro ao adicionar dados de exemplo: $e');
    }
  }
}