import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import '../../../database/dao/area_dao.dart';
import '../../../dto/area_dto.dart';
import '../add/widget_add_area.dart';
import '../edit/widget_edit_area.dart';

class WidgetArea extends StatefulWidget {
  const WidgetArea({super.key});

  @override
  State<WidgetArea> createState() => _WidgetAreaState();
}

class _WidgetAreaState extends State<WidgetArea> {
  final AreaDao _areaDao = AreaDao();
  List<AreaDto> _areas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _areaDao.addSampleData();
      final areas = await _areaDao.findAll();

      setState(() {
        _areas = areas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar áreas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteArea(AreaDto area) async {
    try {
      if (area.id != null) {
        await _areaDao.delete(area.id!);
        await _loadAreas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${area.name} excluída com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir área: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editArea(AreaDto area) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetEditArea(area: area), // Fix: pass area object instead of just ID
      ),
    );
    if (result == true) {
      _loadAreas();
    }
  }

  void _showDeleteDialog(AreaDto area) {
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
            'Deseja realmente excluir "${area.name}"?',
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
                _deleteArea(area);
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
        title: Text("Áreas", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white), // Cor dos ícones
        centerTitle: true,
        backgroundColor: AppColors.gray500,
        actions: [
          IconButton(icon: Icon(Icons.menu), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WidgetAddArea(),
                ),
              );
              if (result == true) {
                _loadAreas();
              }
            },
            tooltip: 'Adicionar área',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _areas.length,
              itemBuilder: (context, index) {
                final area = _areas[index];
                return AreaCard(
                  area: area,
                  onEdit: () => _editArea(area), // Fix: pass entire area object
                  onDelete: () => _showDeleteDialog(area),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WidgetAddArea(),
            ),
          );
          if (result == true) {
            _loadAreas();
          }
        },
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: Icon(Icons.add),
        label: Text(
          "Cadastrar área",
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class AreaCard extends StatelessWidget {
  final AreaDto area;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AreaCard({
    super.key,
    required this.area,
    required this.onDelete,
    required this.onEdit,
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
                Icons.category,
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
                  area.name,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4),
                Text(
                  area.description,
                  style: TextStyle(color: AppColors.white, fontSize: 14),
                  textAlign: TextAlign.left,
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
                  onEdit();
                  break;
                case 'excluir':
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
                          'Deseja realmente excluir "${area.name}"?',
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
                              onDelete();
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
