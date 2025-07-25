import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import 'package:flutter/services.dart';
import '../../database/dao/certificate_dao.dart';
import '../../dto/certificate_dto.dart';

class WidgetAddCertificate extends StatefulWidget {
  final bool isEditing;
  final CertificateDto? certificate;

  const WidgetAddCertificate({
    super.key,
    this.isEditing = false,
    this.certificate,
  });

  @override
  State<WidgetAddCertificate> createState() => _WidgetAddCertificateState();
}

class _WidgetAddCertificateState extends State<WidgetAddCertificate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _instituicaoController = TextEditingController();
  final TextEditingController _horasController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _tipoSelecionado;
  bool _isLoading = false;
  
  final CertificateDao _certificateDao = CertificateDao();
  final List<String> tipos = ['Curso', 'Minicurso', 'Evento'];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.certificate != null) {
      // Preencha os campos com os dados do certificado
      _nomeController.text = widget.certificate!.name;
      _instituicaoController.text = widget.certificate!.institution;
      _horasController.text = widget.certificate!.hours.toString();
      _tagsController.text = widget.certificate!.tags.join(', ');
      _tipoSelecionado = widget.certificate!.type;
    }
  }

  Future<void> _saveCertificate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final certificate = CertificateDto(
        id: widget.isEditing ? widget.certificate!.id : null,
        name: _nomeController.text,
        institution: _instituicaoController.text,
        type: _tipoSelecionado!,
        hours: int.parse(_horasController.text),
        tags: tagsList,
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  style: TextStyle(color: AppColors.white),
                  controller: _instituicaoController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    labelText: 'Instituição',
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
                    labelText: 'Selecione o tipo',
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
                child: TextFormField(
                  style: TextStyle(color: AppColors.white),
                  controller: _tagsController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    labelText: 'Tags',
                    hintText: 'Ex: Flutter, Mobile, Desenvolvimento',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo obrigatório' : null,
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
}