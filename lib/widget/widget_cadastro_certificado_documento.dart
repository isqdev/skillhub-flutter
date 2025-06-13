import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class WidgetCadastroCertificadoDocumento extends StatefulWidget {
  const WidgetCadastroCertificadoDocumento({super.key});

  @override
  State<WidgetCadastroCertificadoDocumento> createState() => _WidgetCadastroCertificadoDocumentoState();
}

class _WidgetCadastroCertificadoDocumentoState extends State<WidgetCadastroCertificadoDocumento> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  String? _arquivoNome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificado e Documento Digital')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Certificado'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _arquivoNome ?? 'Nenhum arquivo selecionado',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
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
                onPressed: () {},
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
