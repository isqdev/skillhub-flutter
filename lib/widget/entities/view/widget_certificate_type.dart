import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import '../../../database/dao/certificate_type_dao.dart';
import '../../../dto/certificate_type_dto.dart';
import '../edit/widget_edit_certificate_type.dart';
import '../add/widget_add_certificate_type.dart';

class WidgetCertificateType extends StatefulWidget {
  const WidgetCertificateType({super.key});

  @override
  State<WidgetCertificateType> createState() => _WidgetCertificateTypeState();
}

class _WidgetCertificateTypeState extends State<WidgetCertificateType> {
  final CertificateTypeDao _certificateTypeDao = CertificateTypeDao();
  List<CertificateTypeDto> _certificateTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificateTypes();
  }

  Future<void> _loadCertificateTypes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _certificateTypeDao.addSampleData();
      final types = await _certificateTypeDao.findAll();

      setState(() {
        _certificateTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar tipos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // void _editCertificateType(CertificateTypeDto type) async {
  //   final result = await Navigator.push<bool>(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => WidgetEditCertificateType(certificateType: type),
  //     ),
  //   );
  //   if (result == true) {
  //     _loadCertificateTypes();
  //   }
  // }

  Future<void> _deleteCertificateType(CertificateTypeDto type) async {
    try {
      if (type.id != null) {
        await _certificateTypeDao.delete(type.id!);
        await _loadCertificateTypes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${type.name} excluído com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir tipo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(CertificateTypeDto type) {
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
            'Deseja realmente excluir "${type.name}"?',
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
                _deleteCertificateType(type);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tipos de Certificado", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const WidgetAddCertificateType(),
                ),
              );
              if (result == true) {
                _loadCertificateTypes();
              }
            },
            tooltip: 'Adicionar tipo',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
            )
          : _certificateTypes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_membership,
                        size: 64,
                        color: AppColors.gray500,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum tipo de certificado encontrado',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Adicione o primeiro tipo clicando no botão abaixo',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _certificateTypes.length,
                  padding: EdgeInsets.all(20),
                  itemBuilder: (context, index) {
                    final type = _certificateTypes[index];
                    return CertificateTypeCard(
                      certificateType: type,
                      // onEdit: () => _editCertificateType(type),
                      onDelete: () => _showDeleteDialog(type),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const WidgetAddCertificateType(),
            ),
          );
          if (result == true) {
            _loadCertificateTypes();
          }
        },
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: Icon(Icons.add),
        label: Text(
          "Cadastrar tipo",
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class CertificateTypeCard extends StatelessWidget {
  final CertificateTypeDto certificateType;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CertificateTypeCard({
    super.key,
    required this.certificateType,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificateType.name,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (certificateType.description.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    certificateType.description,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.teal),
            color: AppColors.gray400,
            onSelected: (String value) {
              switch (value) {
                case 'editar':
                  if (onEdit != null) onEdit!();
                  break;
                case 'excluir':
                  if (onDelete != null) onDelete!();
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
