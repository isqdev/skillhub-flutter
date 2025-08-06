import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import '../../../database/dao/event_dao.dart';
import '../../../dto/event_dto.dart';
import '../../../dto/institution_dto.dart';
import '../../../database/dao/institution_dao.dart';

class WidgetEditEvent extends StatefulWidget {
  final EventDto event;
  
  const WidgetEditEvent({super.key, required this.event});

  @override
  State<WidgetEditEvent> createState() => _WidgetEditEventState();
}

class _WidgetEditEventState extends State<WidgetEditEvent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  final EventDao _eventDao = EventDao();
  bool _isLoading = false;

  // Implementação baseada no seu código
  List<InstitutionDto> institutions = [];
  String? selectedInstitution;
  final InstitutionDao institutionDao = InstitutionDao();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current event data
    _nomeController = TextEditingController(text: widget.event.name);
    _descricaoController = TextEditingController(text: widget.event.description);
    loadInstitutions();
  }

  Future<void> loadInstitutions() async {
    final loadedInstitutions = await institutionDao.findAll();

    // Garantir que o valor existe nos itens carregados
    if (!loadedInstitutions.any((inst) => inst.name == widget.event.institution)) {
      selectedInstitution = loadedInstitutions.isNotEmpty ? loadedInstitutions.first.name : null;
    } else {
      selectedInstitution = widget.event.institution;
    }

    setState(() {
      institutions = loadedInstitutions;
    });
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedEvent = EventDto(
          id: widget.event.id,
          name: _nomeController.text,
          institution: selectedInstitution!, // Usar selectedInstitution
          description: _descricaoController.text,
          profession: widget.event.profession,
        );

        await _eventDao.update(updatedEvent);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar evento: $e'),
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
    // Verificar se ainda está carregando instituições
    if (institutions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Editar evento", style: TextStyle(color: AppColors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: AppColors.gray500,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Editar evento", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                
                // Instituição - Implementação baseada no seu código
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: selectedInstitution,
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
                    items: institutions.map((institution) {
                      return DropdownMenuItem<String>(
                        value: institution.name,
                        child: Text(institution.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedInstitution = value;
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

                // Instituição como pill - Exibição visual
                if (selectedInstitution != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gray500,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          selectedInstitution!,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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

                // Descrição como texto - Exibição visual embaixo da pill
                if (_descricaoController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _descricaoController.text,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              
              const SizedBox(height: 16),
              
              // Buttons
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
                      onPressed: _isLoading ? null : _updateEvent,
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
    )
    )
    ;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
}