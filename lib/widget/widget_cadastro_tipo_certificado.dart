import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_app/app_colors.dart';

class WidgetCadastroTipoCertificado extends StatefulWidget {
  const WidgetCadastroTipoCertificado({super.key});

  @override
  State<WidgetCadastroTipoCertificado> createState() => _WidgetCadastroTipoCertificadoState();
}

class _WidgetCadastroTipoCertificadoState extends State<WidgetCadastroTipoCertificado> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _duracaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Tipo de Certificado')),
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
                    controller: _tipoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      labelText: 'Tipo de Certificado',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    controller: _descricaoController,
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    controller: _duracaoController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      labelText: 'Duração (horas)',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tipo de Certificado salvo!')),
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
                    "Salvar Tipo",
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
