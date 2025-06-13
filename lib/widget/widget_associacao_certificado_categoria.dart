import 'package:flutter/material.dart';

class WidgetAssociacaoCertificadoCategoria extends StatelessWidget {
  const WidgetAssociacaoCertificadoCategoria({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificado x Categoria')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Certificado'),
                items: const [
                  DropdownMenuItem(value: 'Certificado 1', child: Text('Certificado 1')),
                  DropdownMenuItem(value: 'Certificado 2', child: Text('Certificado 2')),
                ],
                onChanged: (value) {},
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: const [
                  DropdownMenuItem(value: 'Categoria 1', child: Text('Categoria 1')),
                  DropdownMenuItem(value: 'Categoria 2', child: Text('Categoria 2')),
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
