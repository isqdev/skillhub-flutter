import 'dart:convert';
import 'package:meu_app/dto/index.dart';
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
      final tagDao = TagDao();
      
      await institutionDao.addSampleData();
      await tagDao.addSampleData();
      
      final institutions = await institutionDao.findAll();
      
      if (institutions.isNotEmpty) {
        // Buscar tags existentes ao invés de criar novas
        final flutterTag = await tagDao.findByName('Flutter');
        final mobileTag = await tagDao.findByName('Mobile');
        final desenvolvimentoTag = await tagDao.findByName('Desenvolvimento');
        final dartTag = await tagDao.findByName('Dart');
        final programacaoTag = await tagDao.findByName('Programação');
        final webTag = await tagDao.findByName('Web');
        final frontendTag = await tagDao.findByName('Frontend');
        final backendTag = await tagDao.findByName('Backend');
        final reactTag = await tagDao.findByName('React');
        final vueTag = await tagDao.findByName('Vue.js');
        final angularTag = await tagDao.findByName('Angular');
        final nodeTag = await tagDao.findByName('Node.js');
        final pythonTag = await tagDao.findByName('Python');
        final javaTag = await tagDao.findByName('Java');
        final jsTag = await tagDao.findByName('JavaScript');
        final tsTag = await tagDao.findByName('TypeScript');
        final uiuxTag = await tagDao.findByName('UI/UX');
        final designTag = await tagDao.findByName('Design');
        final dataTag = await tagDao.findByName('Data Science');
        final mlTag = await tagDao.findByName('Machine Learning');

        // 30 certificados variados
        final certificatesData = [
          {
            'name': 'Curso Completo de Flutter',
            'institution': institutions[0],
            'type': 'Curso',
            'hours': 120,
            'tags': [flutterTag, dartTag, mobileTag, desenvolvimentoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'React Native para Iniciantes',
            'institution': institutions[1],
            'type': 'Curso',
            'hours': 80,
            'tags': [reactTag, mobileTag, jsTag, frontendTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Python para Data Science',
            'institution': institutions[2],
            'type': 'Certificação',
            'hours': 200,
            'tags': [pythonTag, dataTag, mlTag, programacaoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Angular Avançado',
            'institution': institutions[3],
            'type': 'Curso',
            'hours': 60,
            'tags': [angularTag, frontendTag, tsTag, webTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Node.js e Express',
            'institution': institutions[4],
            'type': 'Workshop',
            'hours': 40,
            'tags': [nodeTag, backendTag, jsTag, webTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Vue.js Fundamentals',
            'institution': institutions[5],
            'type': 'Curso',
            'hours': 50,
            'tags': [vueTag, frontendTag, jsTag, webTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Java Spring Boot',
            'institution': institutions[6],
            'type': 'Certificação',
            'hours': 160,
            'tags': [javaTag, backendTag, webTag, programacaoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Design Thinking e UX',
            'institution': institutions[7],
            'type': 'Workshop',
            'hours': 30,
            'tags': [uiuxTag, designTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'TypeScript Essentials',
            'institution': institutions[8],
            'type': 'Curso',
            'hours': 35,
            'tags': [tsTag, jsTag, webTag, programacaoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Machine Learning com Python',
            'institution': institutions[9],
            'type': 'Certificação',
            'hours': 180,
            'tags': [mlTag, pythonTag, dataTag, programacaoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Desenvolvimento Web Full Stack',
            'institution': institutions[0],
            'type': 'Bootcamp',
            'hours': 300,
            'tags': [webTag, frontendTag, backendTag, jsTag, reactTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Mobile Development com Flutter',
            'institution': institutions[1],
            'type': 'Especialização',
            'hours': 250,
            'tags': [flutterTag, dartTag, mobileTag, desenvolvimentoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'React Hooks e Context API',
            'institution': institutions[2],
            'type': 'Curso',
            'hours': 45,
            'tags': [reactTag, frontendTag, jsTag, webTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Backend com Node.js e MongoDB',
            'institution': institutions[3],
            'type': 'Curso',
            'hours': 90,
            'tags': [nodeTag, backendTag, jsTag, webTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'UI Design Moderno',
            'institution': institutions[4],
            'type': 'Workshop',
            'hours': 25,
            'tags': [designTag, uiuxTag, frontendTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'DevOps com Docker e Kubernetes',
            'institution': institutions[5],
            'type': 'Certificação',
            'hours': 140,
            'tags': [backendTag, desenvolvimentoTag, programacaoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Algoritmos e Estruturas de Dados',
            'institution': institutions[6],
            'type': 'Curso',
            'hours': 100,
            'tags': [programacaoTag, javaTag, pythonTag, desenvolvimentoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Progressive Web Apps',
            'institution': institutions[7],
            'type': 'Workshop',
            'hours': 20,
            'tags': [webTag, frontendTag, jsTag, mobileTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Análise de Dados com Python',
            'institution': institutions[8],
            'type': 'Curso',
            'hours': 75,
            'tags': [pythonTag, dataTag, programacaoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'GraphQL e Apollo',
            'institution': institutions[9],
            'type': 'Curso',
            'hours': 55,
            'tags': [backendTag, webTag, jsTag, desenvolvimentoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Micro Frontend Architecture',
            'institution': institutions[0],
            'type': 'Especialização',
            'hours': 85,
            'tags': [frontendTag, webTag, reactTag, angularTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Cybersecurity Fundamentals',
            'institution': institutions[1],
            'type': 'Certificação',
            'hours': 120,
            'tags': [backendTag, desenvolvimentoTag, programacaoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Blockchain Development',
            'institution': institutions[2],
            'type': 'Curso',
            'hours': 110,
            'tags': [desenvolvimentoTag, programacaoTag, webTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'AWS Cloud Practitioner',
            'institution': institutions[3],
            'type': 'Certificação',
            'hours': 95,
            'tags': [backendTag, webTag, desenvolvimentoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Selenium WebDriver',
            'institution': institutions[4],
            'type': 'Curso',
            'hours': 65,
            'tags': [javaTag, programacaoTag, webTag, desenvolvimentoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Agile e Scrum Master',
            'institution': institutions[5],
            'type': 'Certificação',
            'hours': 40,
            'tags': [desenvolvimentoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Firebase para Mobile',
            'institution': institutions[6],
            'type': 'Workshop',
            'hours': 30,
            'tags': [mobileTag, flutterTag, backendTag, desenvolvimentoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'Next.js e Server-Side Rendering',
            'institution': institutions[7],
            'type': 'Curso',
            'hours': 70,
            'tags': [reactTag, frontendTag, webTag, jsTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
          {
            'name': 'Game Development com Unity',
            'institution': institutions[8],
            'type': 'Curso',
            'hours': 150,
            'tags': [desenvolvimentoTag, programacaoTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 1,
          },
          {
            'name': 'REST API Design Best Practices',
            'institution': institutions[9],
            'type': 'Workshop',
            'hours': 35,
            'tags': [backendTag, webTag, desenvolvimentoTag, nodeTag].where((t) => t != null).cast<TagDto>().toList(),
            'userId': 2,
          },
        ];

        // Inserir todos os certificados
        for (var certData in certificatesData) {
          await insert(CertificateDto(
            name: certData['name'] as String,
            institution: certData['institution'] as InstitutionDto,
            type: certData['type'] as String,
            hours: certData['hours'] as int,
            tags: certData['tags'] as List<TagDto>,
            userId: certData['userId'] as int,
          ));
        }
      }
    }
  }
}
