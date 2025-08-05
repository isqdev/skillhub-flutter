import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import '../../../database/dao/institution_dao.dart';
import '../../../dto/institution_dto.dart';
import '../add/widget_add_institution.dart';
import '../edit/widget_edit_institution.dart';

class WidgetInstitution extends StatefulWidget {
  const WidgetInstitution({super.key});

  @override
  State<WidgetInstitution> createState() => _WidgetInstitutionState();
}

class _WidgetInstitutionState extends State<WidgetInstitution> {
  final InstitutionDao _institutionDao = InstitutionDao();
  List<InstitutionDto> _institutions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }

  Future<void> _loadInstitutions() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Adicionar dados de exemplo se não existir nenhuma instituição
      await _institutionDao.addSampleData();

      final institutions = await _institutionDao.findAll();
      setState(() {
        _institutions = institutions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar instituições: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteInstitution(InstitutionDto institution) async {
    try {
      if (institution.id != null) {
        await _institutionDao.delete(institution.id!);
        await _loadInstitutions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${institution.name} excluída com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir instituição: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editInstitution(InstitutionDto institution) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetEditInstitution(
          institution: institution,
        ),
      ),
    );
    if (result == true) {
      _loadInstitutions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instituições", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadInstitutions,
            tooltip: 'Recarregar instituições',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WidgetAddInstitution(),
                ),
              );
              if (result == true) {
                _loadInstitutions();
              }
            },
            tooltip: 'Adicionar instituição',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
            )
          : _institutions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business,
                        size: 64,
                        color: AppColors.gray500,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma instituição encontrada',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Adicione a primeira instituição clicando no botão abaixo',
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
                  onRefresh: _loadInstitutions,
                  color: AppColors.teal,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: _institutions
                                .map((institution) => InstitutionCard(
                                      institution: institution,
                                      onDelete: () =>
                                          _showDeleteDialog(institution),
                                      onEdit: () => _editInstitution(institution),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WidgetAddInstitution(),
            ),
          );
          if (result == true) {
            _loadInstitutions();
          }
        },
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: Icon(Icons.add),
        label: Text(
          "Cadastrar instituição",
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showDeleteDialog(InstitutionDto institution) {
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
            'Deseja realmente excluir "${institution.name}"?',
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
                _deleteInstitution(institution);
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

class InstitutionCard extends StatelessWidget {
  final InstitutionDto institution;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InstitutionCard({
    super.key,
    required this.institution,
    this.onEdit,
    this.onDelete,
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
                Icons.business,
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
                  institution.name,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4),
                Text(
                  "${institution.state}, ${institution.city}",
                  style: TextStyle(color: AppColors.white, fontSize: 14),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        institution.type,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        institution.area,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.teal),
            color: AppColors.gray400,
            onSelected: (String value) {
              switch (value) {
                case 'editar':
                  if (onEdit != null) {
                    onEdit!();
                  }
                  break;
                case 'excluir':
                  if (onDelete != null) {
                    onDelete!();
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
