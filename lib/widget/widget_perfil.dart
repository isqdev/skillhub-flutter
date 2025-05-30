import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';

class WidgetPerfil extends StatelessWidget {
  const WidgetPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meu perfil", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white), // Cor dos ícones
        centerTitle: true,
        backgroundColor: AppColors.gray500,
        actions: [
          IconButton(icon: Icon(Icons.menu), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/certificado/cadastro'),
            tooltip: 'Adicionar certificado',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WidgetCertificate(name: "Graduação Soft Eng"),
                  WidgetCertificate(name: "Graduação Soft Eng"),
                  WidgetCertificate(name: "Graduação Soft Eng"),
                  WidgetCertificate(name: "Graduação Soft Eng"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetCertificate extends StatelessWidget {
  final String name;
  final String instituition;
  final String type;

  const WidgetCertificate({
    super.key,
    this.name = "Nome certificado",
    this.instituition = "Instituição",
    this.type = "Tipo",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(width: 20),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              width: 150,
              height: 150,
              child: Image.network(
                "https://marketplace.canva.com/EAFYPPj1Lsk/1/0/1600w/canva-certificado-de-conclus%C3%A3o-simples-azul-GSpXqEfjO7Y.jpg",
              ),
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  instituition,
                  style: TextStyle(color: AppColors.white, fontSize: 16),

                  textAlign: TextAlign.left,
                ),
                Text(
                  type,
                  style: TextStyle(color: AppColors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
