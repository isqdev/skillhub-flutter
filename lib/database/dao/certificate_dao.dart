import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/certificate_dto.dart';

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

  // Inserir certificado
  Future<int> insert(CertificateDto certificate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final certificates = await findAll();
      
      // Gerar ID único
      final nextId = prefs.getInt(_nextIdKey) ?? 1;
      final newCertificate = certificate.copyWith(id: nextId);
      
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
      if (certificate.id == null) {
        throw Exception('ID não pode ser nulo para atualização');
      }
      
      final certificates = await findAll();
      final index = certificates.indexWhere((c) => c.id == certificate.id);
      
      if (index == -1) {
        throw Exception('Certificado não encontrado');
      }
      
      certificates[index] = certificate;
      await _saveCertificates(certificates);
      
      return certificate.id!;
    } catch (e) {
      print('Erro ao atualizar certificado: $e');
      throw Exception('Erro ao atualizar certificado');
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
  Future<List<CertificateDto>> searchByInstitution(String institution) async {
    try {
      final certificates = await findAll();
      return certificates.where((certificate) => 
        certificate.institution.toLowerCase().contains(institution.toLowerCase())
      ).toList();
    } catch (e) {
      print('Erro ao buscar certificados por instituição: $e');
      return [];
    }
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
    final certificatesJson = certificates.map((certificate) => jsonEncode(certificate.toJson())).toList();
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
      await insert(CertificateDto(
        name: 'Curso de Flutter',
        institution: 'Instituto de Tecnologia',
        type: 'Curso',
        hours: 40,
        tags: ['flutter', 'mobile', 'desenvolvimento'],
      ));
      await insert(CertificateDto(
        name: 'Workshop de Dart',
        institution: 'Academia Digital',
        type: 'Workshop',
        hours: 16,
        tags: ['dart', 'programação'],
      ));
      await insert(CertificateDto(
        name: 'Certificação em Desenvolvimento Web',
        institution: 'Universidade Online',
        type: 'Certificação',
        hours: 80,
        tags: ['web', 'frontend', 'backend'],
      ));
    }
  }
}
