import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import '../../../dto/institution_dto.dart';
import '../../../database/dao/institution_dao.dart';
import '../../../database/dao/area_dao.dart';
import '../../../dto/area_dto.dart';

class WidgetEditInstitution extends StatefulWidget {
  final InstitutionDto institution;

  const WidgetEditInstitution({
    super.key, 
    required this.institution,
  });

  @override
  State<WidgetEditInstitution> createState() => _WidgetEditInstitutionState();
}

class _WidgetEditInstitutionState extends State<WidgetEditInstitution> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _estadoController;
  late final TextEditingController _cidadeController;
  String? _tipoSelecionado;
  bool _isLoading = false;

  final AreaDao _areaDao = AreaDao();
  int? _selectedAreaId;
  bool _isLoadingAreas = true;
  List<AreaDto> _areas = [];

  final List<String> tipos = ['Pública', 'Privada', 'Sistema S', 'Internacional'];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.institution.name);
    _estadoController = TextEditingController(text: widget.institution.state);
    _cidadeController = TextEditingController(text: widget.institution.city);
    _tipoSelecionado = widget.institution.type;
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final areas = await _areaDao.findAll();
      setState(() {
        _areas = areas;
        // Find the area ID by name
        _selectedAreaId = areas
            .firstWhere(
              (area) => area.name == widget.institution.area,
              orElse: () => AreaDto(id: null, name: '', description: ''),
            )
            .id;
        _isLoadingAreas = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar áreas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoadingAreas = false;
      });
    }
  }

  Future<void> _updateInstitution() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the selected area name
        final selectedArea = _areas.firstWhere(
          (area) => area.id == _selectedAreaId,
          orElse: () => throw Exception('Área não encontrada'),
        );

        final updatedInstitution = widget.institution.copyWith(
          name: _nomeController.text,
          state: _estadoController.text,
          city: _cidadeController.text,
          area: selectedArea.name, // Use the area name instead of ID
          type: _tipoSelecionado!,
        );

        final institutionDao = InstitutionDao();
        await institutionDao.update(updatedInstitution);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Instituição atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar instituição: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar instituição", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
      ),
      body: Center(
        child: SizedBox(
          width: 287,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nome
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      style: TextStyle(color: AppColors.white),
                      controller: _nomeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        labelText: 'Nome da instituição',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                  // Tipo
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: DropdownButtonFormField<String>(
                      style: TextStyle(color: AppColors.white),
                      value: _tipoSelecionado,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        labelText: 'Tipo',
                      ),
                      dropdownColor: AppColors.gray400,
                      items: tipos
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Text(
                                tipo,
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoSelecionado = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Selecione um tipo' : null,
                    ),
                  ),
                  // Estado
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      style: TextStyle(color: AppColors.white),
                      controller: _estadoController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        labelText: 'Estado',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                  // Cidade
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      style: TextStyle(color: AppColors.white),
                      controller: _cidadeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        labelText: 'Cidade',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                  // Área
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _isLoadingAreas
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.gray500),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                              ),
                            ),
                          )
                        : DropdownButtonFormField<int>(
                            style: TextStyle(color: AppColors.white),
                            value: _selectedAreaId,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelText: 'Área de atuação',
                            ),
                            dropdownColor: AppColors.gray400,
                            items: _areas
                                .map(
                                  (area) => DropdownMenuItem(
                                    value: area.id,
                                    child: Text(
                                      area.name,
                                      style: TextStyle(color: AppColors.white),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAreaId = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Selecione uma área' : null,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gray500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            fixedSize: const Size(double.infinity, 53),
                          ),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(color: AppColors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateInstitution,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            fixedSize: const Size(double.infinity, 53),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Salvar",
                                  style: TextStyle(color: AppColors.white, fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _estadoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }
}