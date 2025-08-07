import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import 'package:flutter/services.dart';
import '../../../database/dao/certificate_dao.dart';
import '../../../database/dao/user_dao.dart';
import '../../../database/dao/tag_dao.dart';
import '../../../dto/certificate_dto.dart';
import '../../../dto/user_dto.dart';
import '../../../dto/tag_dto.dart';
import '../../../database/dao/institution_dao.dart';
import '../../../dto/institution_dto.dart';

class WidgetAddCertificate extends StatefulWidget {
  final bool isEditing;
  final CertificateDto? certificate;
  final int? userId; // Adicionar este parâmetro

  const WidgetAddCertificate({
    super.key,
    this.isEditing = false,
    this.certificate,
    this.userId, // Adicionar este parâmetro
  });

  @override
  State<WidgetAddCertificate> createState() => _WidgetAddCertificateState();
}

class _WidgetAddCertificateState extends State<WidgetAddCertificate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _horasController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _tipoSelecionado;
  InstitutionDto? _selectedInstitution;
  bool _isLoading = false;
  final TagDao _tagDao = TagDao();
  bool _isLoadingTags = true;
  
  final CertificateDao _certificateDao = CertificateDao();
  final List<String> tipos = ['Curso', 'Minicurso', 'Evento'];
  List<UserDto> _users = [];
  List<TagDto> _allTags = [];
  List<TagDto> _selectedTags = [];
  List<InstitutionDto> _institutions = [];
  bool _isLoadingUsers = true;
  int? _selectedUserId;
  final UserDao _userDao = UserDao();

  @override
  void initState() {
    super.initState();
    _loadTags();
    _loadUsers();
    if (widget.isEditing && widget.certificate != null) {
      // Preencha os campos com os dados do certificado
      _nomeController.text = widget.certificate!.name;
      _selectedInstitution = widget.certificate!.institution;
      _horasController.text = widget.certificate!.hours.toString();
      _tagsController.text = widget.certificate!.tags.map((t) => t.name).join(', ');
      _tipoSelecionado = widget.certificate!.type;
      _selectedUserId = widget.certificate!.userId;
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

  Future<void> _loadUsers() async {
    try {
      final users = await _userDao.findAll();
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar usuários: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveCertificate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use _selectedTags em vez de _tagsController.text
      final certificate = CertificateDto(
        id: widget.isEditing ? widget.certificate!.id : null,
        name: _nomeController.text.trim(),
        institution: _selectedInstitution!,
        type: _tipoSelecionado!,
        hours: int.parse(_horasController.text),
        tags: _selectedTags, // Mudança aqui: use _selectedTags diretamente
        userId: _selectedUserId,
      );

      if (widget.isEditing) {
        await _certificateDao.update(certificate);
      } else {
        await _certificateDao.insert(certificate);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing 
                ? 'Certificado atualizado com sucesso!'
                : 'Certificado adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao ${widget.isEditing ? 'atualizar' : 'adicionar'} certificado: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? "Editar Certificado" : "Adicionar Certificado",
          style: TextStyle(color: AppColors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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

              // Usuário (moved before institution)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _isLoadingUsers
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
                      value: _selectedUserId,
                      decoration: InputDecoration(
                        labelText: 'Usuário',
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
                      items: _users.map((user) {
                        return DropdownMenuItem<int>(
                        value: user.id,
                        child: Text(
                          user.name,
                          style: TextStyle(color: AppColors.white),
                        ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                        _selectedUserId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                        return 'Por favor, selecione um usuário';
                        }
                        return null;
                      },
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
                    FormField<String>(
                      initialValue: _tipoSelecionado,
                      validator: (value) => value == null ? 'Selecione um tipo' : null,
                      builder: (FormFieldState<String> field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SegmentedButton<String>(
                              segments: tipos.map((tipo) {
                                return ButtonSegment<String>(
                                  value: tipo,
                                  label: Text(
                                    tipo,
                                    style: TextStyle(
                                      color: AppColors.white
                                    ),
                                  ),
                                );
                              }).toList(),
                              selected: {_tipoSelecionado ?? ''},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _tipoSelecionado = newSelection.first;
                                });
                                field.didChange(newSelection.first);
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
                                side: MaterialStateProperty.all(
                                  BorderSide(color: AppColors.gray400),
                                ),
                              ),
                            ),
                            if (field.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  field.errorText!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _isLoadingTags
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
                    : Column(
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
                                  style: TextStyle(
                                    color: isSelected ? AppColors.white : AppColors.white,
                                  ),
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
                                checkmarkColor: AppColors.white,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCertificate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      )
                    : Text(
                        widget.isEditing ? 'Atualizar' : 'Salvar',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
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