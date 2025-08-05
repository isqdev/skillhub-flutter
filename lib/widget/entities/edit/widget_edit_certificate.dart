import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_app/app_colors.dart';
import 'package:meu_app/dto/index.dart';
import '../../../database/dao/user_dao.dart';
import '../../../database/dao/tag_dao.dart';
import '../../../dto/user_dto.dart';
import '../../../dto/tag_dto.dart';
import '../../../dto/certificate_dto.dart';
import '../../../database/dao/certificate_dao.dart';
import '../../components/institution_dropdown.dart';
import '../../../database/dao/institution_dao.dart';
import '../../../dto/institution_dto.dart';


class WidgetEditCertificate extends StatefulWidget {
  final CertificateDto certificate;
  
  const WidgetEditCertificate({super.key, required this.certificate});

  @override
  State<WidgetEditCertificate> createState() => _WidgetEditCertificateState();
}

class _WidgetEditCertificateState extends State<WidgetEditCertificate> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _horasController;
  late final TextEditingController _tagsController;
  String? _tipoSelecionado;
  InstitutionDto? _selectedInstitution;
  bool _isLoading = false;
  final TagDao _tagDao = TagDao();
  bool _isLoadingTags = true;
  final CertificateDao _certificateDao = CertificateDao();
  final InstitutionDao _institutionDao = InstitutionDao();
  final List<String> tipos = ['Curso', 'Minicurso', 'Evento'];
  List<TagDto> _allTags = [];
  List<TagDto> _selectedTags = [];
  List<InstitutionDto> _institutions = [];
  bool _isLoadingInstitutions = true;

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
    _loadTags();
    // Initialize controllers with current certificate data
    _nomeController = TextEditingController(text: widget.certificate.name);
    _horasController = TextEditingController(text: widget.certificate.hours.toString());
    _tagsController = TextEditingController(
      text: widget.certificate.tags.map((t) => t.name).join(', ')
    );
    _tipoSelecionado = widget.certificate.type;
    _selectedInstitution = widget.certificate.institution;
    _selectedTags = List.from(widget.certificate.tags);
  }

  Future<void> _loadInstitutions() async {
    try {
      final institutions = await _institutionDao.findAll();
      setState(() {
        _institutions = institutions;
        final match = institutions.where(
          (inst) => inst.id == widget.certificate.institution.id,
        );
        _selectedInstitution = match.isNotEmpty ? match.first : institutions.isNotEmpty ? institutions.first : null;
        _isLoadingInstitutions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInstitutions = false;
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

  Future<void> _loadTags() async {
    try {
      final tags = await _tagDao.findAll();
      setState(() {
        _allTags = tags;
        _isLoadingTags = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTags = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar tags: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateCertificate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedCertificate = widget.certificate.copyWith(
          name: _nomeController.text.trim(),
          institution: _selectedInstitution!,
          type: _tipoSelecionado!,
          hours: int.parse(_horasController.text),
          tags: _selectedTags,
        );

        await _certificateDao.update(updatedCertificate);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificado atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar certificado: $e'),
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
        title: Text("Editar certificado", 
          style: TextStyle(color: AppColors.white)
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // igual ao add
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
                        labelText: 'Nome do certificado',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),

                  // Instituição
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _isLoadingInstitutions
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                            ),
                          )
                        : DropdownButtonFormField<InstitutionDto>(
                            value: _selectedInstitution,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelText: 'Instituição',
                              labelStyle: TextStyle(color: AppColors.white),
                            ),
                            dropdownColor: AppColors.gray500,
                            style: TextStyle(color: AppColors.white),
                            items: _institutions.map((institution) {
                              return DropdownMenuItem<InstitutionDto>(
                                value: institution,
                                child: Text(
                                  institution.name,
                                  style: TextStyle(color: AppColors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (InstitutionDto? newValue) {
                              setState(() {
                                _selectedInstitution = newValue;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Selecione uma instituição' : null,
                          ),
                  ),

                  // Tipo
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo',
                          style: TextStyle(color: AppColors.white),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: tipos.map((tipo) {
                            return ButtonSegment<String>(
                              value: tipo,
                              label: Text(tipo, 
                                style: TextStyle(color: AppColors.white)
                              ),
                            );
                          }).toList(),
                          selected: {_tipoSelecionado ?? ''},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _tipoSelecionado = newSelection.first;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return AppColors.teal;
                                }
                                return AppColors.gray500;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Horas
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      style: TextStyle(color: AppColors.white),
                      controller: _horasController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        labelText: 'Horas',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Digite um número válido';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Tags
                  if (!_isLoadingTags)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tags',
                            style: TextStyle(color: AppColors.white),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allTags.map((tag) {
                              final isSelected = _selectedTags.contains(tag);
                              return FilterChip(
                                label: Text(
                                  tag.name,
                                  style: TextStyle(color: AppColors.white),
                                ),
                                selected: isSelected,
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedTags.add(tag);
                                    } else {
                                      _selectedTags.remove(tag);
                                    }
                                  });
                                },
                                backgroundColor: AppColors.gray400,
                                selectedColor: AppColors.teal,
                              );
                            }).toList(),
                          ),
                        ],
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
                          onPressed: _isLoading ? null : _updateCertificate,
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
    _horasController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}