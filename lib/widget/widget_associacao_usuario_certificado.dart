import 'package:flutter/material.dart';

class WidgetAssociacaoUsuarioCertificado extends StatelessWidget {
  const WidgetAssociacaoUsuarioCertificado({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuário x Certificado')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Usuário'),
                items: const [
                  DropdownMenuItem(value: 'Usuário 1', child: Text('Usuário 1')),
                  DropdownMenuItem(value: 'Usuário 2', child: Text('Usuário 2')),
                ],
                onChanged: (value) {},
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Certificado'),
                items: const [
                  DropdownMenuItem(value: 'Certificado 1', child: Text('Certificado 1')),
                  DropdownMenuItem(value: 'Certificado 2', child: Text('Certificado 2')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Associar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
