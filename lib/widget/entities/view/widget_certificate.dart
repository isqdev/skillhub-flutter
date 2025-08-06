import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import '../../../database/dao/certificate_dao.dart';
import '../../../database/dao/user_dao.dart';
import '../../../database/dao/tag_dao.dart';
import '../../../dto/certificate_dto.dart';
import '../../../dto/user_dto.dart';
import '../../../dto/tag_dto.dart';
import '../add/widget_add_certificate.dart';
import '../edit/widget_edit_certificate.dart';

class WidgetCertificate extends StatefulWidget {
  const WidgetCertificate({super.key});

  @override
  State<WidgetCertificate> createState() => _WidgetCertificateState();
}

class _WidgetCertificateState extends State<WidgetCertificate> {
  final CertificateDao _certificateDao = CertificateDao();
  final UserDao _userDao = UserDao();
  final TagDao _tagDao = TagDao();
  List<CertificateDto> _certificates = [];
  List<CertificateDto> _filteredCertificates = [];
  List<UserDto> _users = [];
  List<TagDto> _availableTags = [];
  List<TagDto> _selectedTags = [];
  bool _isLoading = true;
  
  // Adicione o ScrollController
  late ScrollController _tagScrollController;

  @override
  void initState() {
    super.initState();
    _tagScrollController = ScrollController();
    _loadData();
  }

  @override
  void dispose() {
    _tagScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Carregue os usuários ANTES dos certificados
    await _loadUsers();
    await _loadTags();
    await _loadCertificates();
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCertificates() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Adicionar dados de exemplo se não existir nenhum certificado
      await _certificateDao.addSampleData();

      final certificates = await _certificateDao.findAll();
      setState(() {
        // Ordenar por ID decrescente (mais recentes primeiro)
        _certificates = certificates..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
        _filteredCertificates = _certificates;
        _isLoading = false;
      });
      
      // Atualizar tags disponíveis baseadas nos certificados
      _updateAvailableTags();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar certificados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userDao.findAll();
      setState(() {
        _users = users;
      });
    } catch (e) {
      setState(() {
        _users = [];
      });
    }
  }

  Future<void> _loadTags() async {
    try {
      await _tagDao.addSampleData();
      final tags = await _tagDao.findAll();
      setState(() {
        _availableTags = tags;
      });
    } catch (e) {
      setState(() {
        _availableTags = [];
      });
    }
  }

  void _updateAvailableTags() {
    // Pegar todas as tags únicas dos certificados
    Set<String> tagNames = {};
    for (var certificate in _certificates) {
      for (var tag in certificate.tags) {
        tagNames.add(tag.name);
      }
    }
    
    // Filtrar tags disponíveis que estão sendo usadas
    setState(() {
      _availableTags = _availableTags.where((tag) => tagNames.contains(tag.name)).toList();
    });
  }

  // Atualize também a função de filtro para lógica "OU"
  void _filterCertificates() {
    if (_selectedTags.isEmpty) {
      setState(() {
        _filteredCertificates = _certificates;
      });
      return;
    }

    setState(() {
      _filteredCertificates = _certificates.where((certificate) {
        // Verificar se o certificado tem QUALQUER uma das tags selecionadas (lógica OU)
        return _selectedTags.any((selectedTag) {
          return certificate.tags.any((certTag) => certTag.name == selectedTag.name);
        });
      }).toList();
    });
  }

  void _toggleTag(TagDto tag) {
    setState(() {
      if (_selectedTags.any((t) => t.name == tag.name)) {
        _selectedTags.removeWhere((t) => t.name == tag.name);
      } else {
        _selectedTags.add(tag);
      }
    });
    _filterCertificates();
  }

  void _clearFilters() {
    setState(() {
      _selectedTags.clear();
      _filteredCertificates = _certificates;
    });
  }

  String _getUserName(int? userId) {
    if (userId == null) return 'Usuário desconhecido';
    final user = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => UserDto(
        id: 0, 
        name: 'Usuário desconhecido',
        email: 'desconhecido@email.com',
        profession: 'Desconhecido',
        imageUrl: '',
      ),
    );
    return user.name;
  }

  Future<void> _deleteCertificate(CertificateDto certificate) async {
    try {
      if (certificate.id != null) {
        await _certificateDao.delete(certificate.id!);
        await _loadCertificates();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${certificate.name} excluído com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir certificado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editCertificate(CertificateDto certificate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetEditCertificate(
          certificate: certificate,
        ),
      ),
    );
    if (result == true) {
      _loadCertificates();
    }
  }

  // Adicione os métodos de scroll
  void _scrollTagsLeft() {
    _tagScrollController.animateTo(
      _tagScrollController.offset - 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollTagsRight() {
    _tagScrollController.animateTo(
      _tagScrollController.offset + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Certificados", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCertificates,
            tooltip: 'Recarregar certificados',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WidgetAddCertificate(),
                ),
              );
              if (result == true) {
                _loadCertificates();
              }
            },
            tooltip: 'Adicionar certificado',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de Tags - altura reduzida e pills menores
          if (_availableTags.isNotEmpty)
            Container(
              height: 40,
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // Seta esquerda
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: AppColors.white),
                    onPressed: _scrollTagsLeft,
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _tagScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _availableTags.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Botão "Limpar filtros" - pill menor
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: _selectedTags.isNotEmpty ? _clearFilters : null,
                              child: Container(
                                height: 28, // Altura fixa
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.gray500,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 1,
                                  ),
                                ),
                                child: Center( // Centralizar verticalmente
                                  child: Text(
                                    'Limpar',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        
                        final tag = _availableTags[index - 1];
                        final isSelected = _selectedTags.any((t) => t.name == tag.name);
                        
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _toggleTag(tag),
                            child: Container(
                              height: 28, // Altura fixa
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.teal : AppColors.gray400,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isSelected ? AppColors.teal : AppColors.gray500,
                                  width: 1,
                                ),
                              ),
                              child: Center( // Centralizar verticalmente
                                child: Text(
                                  tag.name,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Seta direita
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: AppColors.white),
                    onPressed: _scrollTagsRight,
                  ),
                ],
              ),
            ),
          
          // Contador de resultados - atualizado com quebra de linha
          if (_selectedTags.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Alinhar à esquerda
                children: [
                  Text(
                  '${_filteredCertificates.length} certificado(s) encontrado(s)',
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: 14,
                  ),
                  ),
                  SizedBox(height: 4),
                  // Tags selecionadas em linha, separadas por vírgula
                  Row(
                  children: [
                    Text(
                    'Filtrado por: ',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    ),
                    Flexible(
                    child: Text(
                      _selectedTags.map((tag) => tag.name).join(', '),
                      style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    ),
                  ],
                  ),
                ],
              ),
            ),
          
          // Lista de certificados
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                    ),
                  )
                : _filteredCertificates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description,
                              size: 64,
                              color: AppColors.gray500,
                            ),
                            SizedBox(height: 16),
                            Text(
                              _selectedTags.isEmpty 
                                  ? 'Nenhum certificado encontrado'
                                  : 'Nenhum certificado encontrado com essas tags',
                              style: TextStyle(
                                color: AppColors.gray500,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _selectedTags.isEmpty 
                                  ? 'Adicione o primeiro certificado clicando no botão abaixo'
                                  : 'Tente remover alguns filtros ou adicionar novos certificados',
                              style: TextStyle(
                                color: AppColors.gray500,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCertificates,
                        color: AppColors.teal,
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: _filteredCertificates
                                      .map((cert) => CertificateCard(
                                            certificate: cert,
                                            userName: _getUserName(cert.userId),
                                            onDelete: () => _showDeleteDialog(cert),
                                            onEdit: () => _editCertificate(cert),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WidgetAddCertificate(),
            ),
          );
          if (result == true) {
            _loadCertificates();
          }
        },
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: Icon(Icons.add),
        label: Text(
          "Cadastrar certificado",
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showDeleteDialog(CertificateDto certificate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.gray400,
          title: Text(
            'Confirmar exclusão',
            style: TextStyle(color: AppColors.white),
          ),
          content: Text(
            'Deseja realmente excluir "${certificate.name}"?',
            style: TextStyle(color: AppColors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCertificate(certificate);
              },
              child: Text(
                'Excluir',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CertificateCard extends StatelessWidget {
  final CertificateDto certificate;
  final String userName;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.userName,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal,
              ),
              child: Icon(
                Icons.description,
                size: 30,
                color: AppColors.white,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.name,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4),
                Text(
                  certificate.institution.name, // Change this line
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        certificate.type,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Spacing between type and tags
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: certificate.tags
                              .map(
                                (tag) => Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.gray500,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      tag.name,
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  userName,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.teal),
            color: AppColors.gray400,
            onSelected: (String value) {
              switch (value) {
                case 'excluir':
                  if (onDelete != null) {
                    onDelete!();
                  }
                  break;
                case 'editar':
                  if (onEdit != null) {
                    onEdit!();
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Editar',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
