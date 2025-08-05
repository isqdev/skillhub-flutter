import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import 'package:meu_app/database/dao/institution_dao.dart';
import '../../../database/dao/event_dao.dart';
import '../../../dto/event_dto.dart';
import '../../components/institution_dropdown.dart';
import '../../../dto/institution_dto.dart';

class WidgetAddEvent extends StatefulWidget {
  const WidgetAddEvent({super.key});

  @override
  State<WidgetAddEvent> createState() => _WidgetAddEventState();
}

class _WidgetAddEventState extends State<WidgetAddEvent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final EventDao _eventDao = EventDao();
  bool _isLoading = false;

  InstitutionDto? _selectedInstitution;
  final InstitutionDao _institutionDao = InstitutionDao();
  List<InstitutionDto> _institutions = [];
  bool _isLoadingInstitutions = true;

  Future<void> _loadInstitutions() async {
    try {
      final institutions = await _institutionDao.findAll();
      setState(() {
        _institutions = institutions;
        _isLoadingInstitutions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInstitutions = false;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final event = EventDto(
          name: _nomeController.text,
          institution: _selectedInstitution!.name, // Use the name property
          description: _descricaoController.text,
          profession: 'Event', // Default profession for events
          tags: EventDto.fromTagsString(_tagsController.text),
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
  void initState() {
    super.initState();
    _loadInstitutions();
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
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ),
                // Instituição
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _isLoadingInstitutions
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
                      : InstitutionDropdown(
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
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ),
                // Tags
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    style: TextStyle(color: AppColors.white),
                    controller: _tagsController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      labelText: 'Tags',
                      hintText: 'Ex: tecnologia, programação, flutter',
                    ),
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
    _tagsController.dispose();
    super.dispose();
  }
}
