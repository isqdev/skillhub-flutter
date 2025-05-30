import 'package:flutter/material.dart';

class FormPessoa extends StatefulWidget {
  @override
  _FormPessoaState createState() => _FormPessoaState();
}

class _FormPessoaState extends State<FormPessoa> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  // Campos de seleção
  String? _cidade;
  String? _estado;
  bool? _isAtivo;

  // Dados pré-definidos para as opções
  final List<String> cidades = [
    'São Paulo',
    'Rio de Janeiro',
    'Belo Horizonte'
  ];
  final List<String> estados = ['SP', 'RJ', 'MG'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Pessoa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nomeController, 'Nome'),
              _buildTextField(_sobrenomeController, 'Sobrenome'),
              _buildTextField(_telefoneController, 'Telefone'),
              _buildTextField(_emailController, 'E-mail'),
              _buildTextField(_cpfController, 'CPF'),
              _buildDropdownField('Cidade', cidades, (value) {
                setState(() {
                  _cidade = value;
                });
              }),
              _buildDropdownField('Estado', estados, (value) {
                setState(() {
                  _estado = value;
                });
              }),
              _buildSwitchField('Ativo', (value) {
                setState(() {
                  _isAtivo = value;
                });
              }),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Processar o cadastro
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Cadastro realizado com sucesso!')));
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label é obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        value: label == 'Cidade' ? _cidade : _estado,
        onChanged: onChanged,
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return '$label é obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSwitchField(String label, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SwitchListTile(
        title: Text(label),
        value: _isAtivo ?? false,
        onChanged: onChanged,
        activeColor: Colors.green,
        inactiveThumbColor: Colors.red,
      ),
    );
  }
}
