import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import '../../../dto/institution_dto.dart';
import '../../../dto/area_dto.dart';
import '../../../database/dao/institution_dao.dart';
import '../../../database/dao/area_dao.dart';

class WidgetAddInstitution extends StatefulWidget {
  const WidgetAddInstitution({super.key});

  @override
  State<WidgetAddInstitution> createState() => _WidgetAddInstitutionState();
}

class _WidgetAddInstitutionState extends State<WidgetAddInstitution> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final InstitutionDao _institutionDao = InstitutionDao();
  final AreaDao _areaDao = AreaDao();
  String? _tipoSelecionado;
  int? _selectedAreaId; // Change the type of _selectedAreaId to int?
  bool _isLoading = false;
  bool _isLoadingAreas = true;
  List<AreaDto> _areas = [];

  final List<String> tipos = ['Pública', 'Privada', 'Sistema S', 'Internacional'];

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final areas = await _areaDao.findAll();
      setState(() {
        _areas = areas;
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

  Future<void> _saveInstitution() async {
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

        final institution = InstitutionDto(
          name: _nomeController.text,
          state: _estadoController.text,
          city: _cidadeController.text,
          area: selectedArea.name, // Use the area name instead of ID
          type: _tipoSelecionado!,
        );

        await _institutionDao.insert(institution);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Instituição cadastrada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar instituição: $e'),
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
        title: Text("Cadastrar instituição", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
      ),
      body: Center(
        child: SizedBox(
          width: 287,
          child: Form(
            key: _formKey,
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
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
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
                                  value: area.id,  // area.id is already an int
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
                      labelText: 'Tipo de instituição',
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
                const SizedBox(height: 16),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _saveInstitution,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          fixedSize: const Size(287, 53),
                        ),
                        child: Text(
                          "Cadastrar instituição",
                          style: TextStyle(color: AppColors.white, fontSize: 20),
                        ),
                      ),
              ],
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
