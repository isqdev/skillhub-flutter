import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class WidgetAddCertificate extends StatefulWidget {
  const WidgetAddCertificate({super.key});

  @override
  State<WidgetAddCertificate> createState() => _WidgetAddCertificateState();
}

class _WidgetAddCertificateState extends State<WidgetAddCertificate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _instituicaoController = TextEditingController();
  final TextEditingController _horasController = TextEditingController();
  String? _tipoSelecionado;
  String? _arquivoNome;

  final List<String> tipos = ['Curso', 'Minicurso', 'Evento'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Certificado')),
      body: Center(
        child: SizedBox(
          width: 287,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                // Arquivo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _arquivoNome ?? 'Nenhum arquivo selecionado',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file, color: AppColors.teal),
                        tooltip: 'Selecionar arquivo',
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if (result != null && result.files.isNotEmpty) {
                            setState(() {
                              _arquivoNome = result.files.single.name;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Certificado salvo!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    fixedSize: const Size(287, 53),
                  ),
                  child: Text(
                    "Adicionar certificado",
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
}