import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import '../../../database/dao/event_dao.dart';
import '../../../dto/event_dto.dart';
import '../../../dto/institution_dto.dart';
import '../../../database/dao/institution_dao.dart';

class WidgetAddEvent extends StatefulWidget {
  const WidgetAddEvent({super.key});

  @override
  State<WidgetAddEvent> createState() => _WidgetAddEventState();
}

class _WidgetAddEventState extends State<WidgetAddEvent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final EventDao _eventDao = EventDao();
  bool _isLoading = false;

  InstitutionDto? _selectedInstitution;

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final event = EventDto(
          name: _nomeController.text,
          institution: _selectedInstitution!.name,
          description: _descricaoController.text,
          profession: 'Event',
        );

        await _eventDao.insert(event);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento cadastrado com sucesso!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar evento: $e'),
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
        title: Text("Cadastrar evento", style: TextStyle(color: AppColors.white)),
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
                      labelText: 'Nome do evento',
                      labelStyle: TextStyle(color: AppColors.white),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ),
                // Instituição
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InstitutionDropdown(
                    value: _selectedInstitution,
                    onChanged: (InstitutionDto? newValue) {
                      setState(() {
                        _selectedInstitution = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione uma instituição';
                      }
                      return null;
                    },
                  ),
                ),
                // Descrição
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    style: TextStyle(color: AppColors.white),
                    controller: _descricaoController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      labelText: 'Descrição',
                      labelStyle: TextStyle(color: AppColors.white),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                      )
                    : ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          fixedSize: const Size(287, 53),
                        ),
                        child: Text(
                          "Cadastrar evento",
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
    _descricaoController.dispose();
    super.dispose();
  }
}

// Widget InstitutionDropdown personalizado para este arquivo
class InstitutionDropdown extends StatefulWidget {
  final InstitutionDto? value;
  final ValueChanged<InstitutionDto?> onChanged;
  final String? Function(InstitutionDto?)? validator;

  const InstitutionDropdown({
    Key? key,
    this.value,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<InstitutionDropdown> createState() => _InstitutionDropdownState();
}

class _InstitutionDropdownState extends State<InstitutionDropdown> {
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
      final institutions = await _institutionDao.findAll();
      setState(() {
        _institutions = institutions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
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
        : DropdownButtonFormField<InstitutionDto>(
            value: widget.value,
            decoration: InputDecoration(
              labelText: 'Instituição',
              labelStyle: TextStyle(color: AppColors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: AppColors.gray500),
              ),
            ),
            dropdownColor: AppColors.gray500,
            style: TextStyle(color: AppColors.white),
            items: _institutions.map((InstitutionDto institution) {
              return DropdownMenuItem<InstitutionDto>(
                value: institution,
                child: Text(institution.name),
              );
            }).toList(),
            onChanged: widget.onChanged,
            validator: widget.validator,
          );
  }
}
