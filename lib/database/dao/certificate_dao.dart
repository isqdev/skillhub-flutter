import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meu_app/dto/tag_dto.dart';
import '../../dto/certificate_dto.dart';
import 'tag_dao.dart';
import 'institution_dao.dart';

class CertificateDao {
  static const String _certificatesKey = 'certificates_list';
  static const String _nextIdKey = 'next_certificate_id';

  // Buscar todos os certificados
  Future<List<CertificateDto>> findAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final certificatesJson = prefs.getStringList(_certificatesKey) ?? [];
      return certificatesJson.map((json) => CertificateDto.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Erro ao buscar certificados: $e');
      return [];
    }
  }

  // Buscar certificados por usuário
  Future<List<CertificateDto>> findByUserId(int userId) async {
    try {
      final certificates = await findAll();
      return certificates.where((cert) => cert.userId == userId).toList();
    } catch (e) {
      print('Erro ao buscar certificados por usuário: $e');
      return [];
    }
  }

  // Buscar certificados sem usuário associado
  Future<List<CertificateDto>> findUnassigned() async {
    try {
      final certificates = await findAll();
      return certificates.where((cert) => cert.userId == null).toList();
    } catch (e) {
      print('Erro ao buscar certificados não associados: $e');
      return [];
    }
  }

  // Inserir certificado
  Future<int> insert(CertificateDto certificate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final certificates = await findAll();
      
      // Gerar ID único
      final nextId = prefs.getInt(_nextIdKey) ?? 1;
      final newCertificate = certificate.copyWith(id: nextId);
      
      // Save any new tags that don't exist yet
      final tagDao = TagDao();
      for (var tag in certificate.tags) {
        if (tag.id == null) {
          await tagDao.insert(tag);
        }
      }

      certificates.add(newCertificate);
      await _saveCertificates(certificates);
      await prefs.setInt(_nextIdKey, nextId + 1);
      
      return nextId;
    } catch (e) {
      print('Erro ao inserir certificado: $e');
      throw Exception('Erro ao salvar certificado');
    }
  }

  // Atualizar certificado
  Future<int> update(CertificateDto certificate) async {
    try {
      final certificates = await findAll();
      final index = certificates.indexWhere((c) => c.id == certificate.id);
      
      if (index != -1) {
        // Save any new tags that don't exist yet
        final tagDao = TagDao();
        for (var tag in certificate.tags) {
          if (tag.id == null) {
            await tagDao.insert(tag);
          }
        }

        certificates[index] = certificate;
        await _saveCertificates(certificates);
        return certificate.id!;
      }
      
      throw Exception('Certificado não encontrado');
    } catch (e) {
      print('Erro ao atualizar certificado: $e');
      throw Exception('Erro ao atualizar certificado');
    }
  }

  // Associar certificado a um usuário
  Future<int> associateToUser(int certificateId, int userId) async {
    try {
      final certificates = await findAll();
      final index = certificates.indexWhere((cert) => cert.id == certificateId);
      
      if (index != -1) {
        final updatedCert = certificates[index].copyWith(userId: userId);
        certificates[index] = updatedCert;
        await _saveCertificates(certificates);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Erro ao associar certificado ao usuário: $e');
      throw Exception('Erro ao associar certificado');
    }
  }

  // Desassociar certificado de um usuário
  Future<int> disassociateFromUser(int certificateId) async {
    try {
      final certificates = await findAll();
      final index = certificates.indexWhere((cert) => cert.id == certificateId);
      
      if (index != -1) {
        final updatedCert = certificates[index].copyWith(userId: null);
        certificates[index] = updatedCert;
        await _saveCertificates(certificates);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Erro ao desassociar certificado: $e');
      throw Exception('Erro ao desassociar certificado');
    }
  }

  // Contar certificados por usuário
  Future<int> countByUserId(int userId) async {
    try {
      final certificates = await findByUserId(userId);
      return certificates.length;
    } catch (e) {
      print('Erro ao contar certificados: $e');
      return 0;
    }
  }

  // Obter total de horas por usuário
  Future<int> getTotalHoursByUserId(int userId) async {
    try {
      final certificates = await findByUserId(userId);
      return certificates.fold<int>(0, (sum, certificate) => sum + certificate.hours);
    } catch (e) {
      print('Erro ao calcular total de horas por usuário: $e');
      return 0;
    }
  }

  // Buscar usuários com certificados
  Future<List<int>> getUsersWithCertificates() async {
    try {
      final certificates = await findAll();
      final userIds = certificates
          .where((cert) => cert.userId != null)
          .map((cert) => cert.userId!)
          .toSet()
          .toList();
      return userIds;
    } catch (e) {
      print('Erro ao buscar usuários com certificados: $e');
      return [];
    }
  }

  // Deletar certificado
  Future<int> delete(int id) async {
    try {
      final certificates = await findAll();
      final initialLength = certificates.length;
      certificates.removeWhere((certificate) => certificate.id == id);
      await _saveCertificates(certificates);
      return initialLength - certificates.length;
    } catch (e) {
      print('Erro ao deletar certificado: $e');
      throw Exception('Erro ao deletar certificado');
    }
  }

  // Buscar por nome
  Future<CertificateDto?> findByName(String name) async {
    try {
      final certificates = await findAll();
      return certificates.cast<CertificateDto?>().firstWhere(
        (certificate) => certificate?.name == name,
        orElse: () => null,
      );
    } catch (e) {
      print('Erro ao buscar certificado por nome: $e');
      return null;
    }
  }

  // Buscar por nome (busca parcial)
  Future<List<CertificateDto>> searchByName(String name) async {
    try {
      final certificates = await findAll();
      return certificates.where((certificate) => 
        certificate.name.toLowerCase().contains(name.toLowerCase())
      ).toList();
    } catch (e) {
      print('Erro ao buscar certificados por nome: $e');
      return [];
    }
  }

  // Buscar por instituição
  Future<List<CertificateDto>> findByInstitution(String institution) async {
    final certificates = await findAll();
    return certificates
        .where((certificate) =>
            certificate.institution.name.toLowerCase().contains(
                  institution.toLowerCase(),
                ))
        .toList();
  }

  // Buscar por tipo
  Future<List<CertificateDto>> searchByType(String type) async {
    try {
      final certificates = await findAll();
      return certificates.where((certificate) => 
        certificate.type.toLowerCase() == type.toLowerCase()
      ).toList();
    } catch (e) {
      print('Erro ao buscar certificados por tipo: $e');
      return [];
    }
  }

  // Buscar por tag
  Future<List<CertificateDto>> searchByTag(String tag) async {
    try {
      final certificates = await findAll();
      return certificates.where((certificate) => 
        certificate.tags.any((t) => t.toLowerCase().contains(tag.toLowerCase()))
      ).toList();
    } catch (e) {
      print('Erro ao buscar certificados por tag: $e');
      return [];
    }
  }

  // Obter total de horas
  Future<int> getTotalHours() async {
    try {
      final certificates = await findAll();
      return certificates.fold<int>(0, (sum, certificate) => sum + certificate.hours);
    } catch (e) {
      print('Erro ao calcular total de horas: $e');
      return 0;
    }
  }

  // Método privado para salvar certificados
  Future<void> _saveCertificates(List<CertificateDto> certificates) async {
    final prefs = await SharedPreferences.getInstance();
    final certificatesJson = certificates
        .map((certificate) => jsonEncode(certificate.toJson()))
        .toList();
    await prefs.setStringList(_certificatesKey, certificatesJson);
  }

  // Limpar todos os dados (útil para testes)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_certificatesKey);
    await prefs.remove(_nextIdKey);
  }

  // Método para adicionar dados de exemplo (para testes)
  Future<void> addSampleData() async {
    final certificates = await findAll();
    if (certificates.isEmpty) {
      final institutionDao = InstitutionDao();
      await institutionDao.addSampleData();
      final institutions = await institutionDao.findAll();
      
      if (institutions.isNotEmpty) {
        await insert(CertificateDto(
          name: 'Curso de Flutter',
          institution: institutions[0],
          type: 'Curso',
          hours: 40,
          tags: [TagDto(name: 'flutter'), TagDto(name: 'mobile'), TagDto(name: 'desenvolvimento')],
          userId: 1,
        ));
        
        await insert(CertificateDto(
          name: 'Minicurso de Dart',
          institution: institutions[1],
          type: 'Minicurso',
          hours: 16,
          tags: [TagDto(name: 'dart'), TagDto(name: 'programação')],
          userId: 2,
        ));
        
        await insert(CertificateDto(
          name: 'Evento de Desenvolvimento Web',
          institution: institutions[2],
          type: 'Evento',
          hours: 80,
          tags: [TagDto(name: 'web'), TagDto(name: 'frontend'), TagDto(name: 'backend')],
          userId: 1,
        ));
      }
    }
  }
}
