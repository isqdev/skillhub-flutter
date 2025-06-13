import 'package:flutter/material.dart';
import 'package:meu_app/widget/widget_cadastro_usuario.dart';
import 'package:meu_app/widget/widget_cadastro_instituicao.dart';
import 'package:meu_app/widget/widget_cadastro_tipo_certificado.dart';
import 'package:meu_app/widget/widget_cadastro_categoria.dart';
import 'package:meu_app/widget/widget_cadastro_area.dart';
import 'package:meu_app/widget/widget_cadastro_certificado_documento.dart';
import 'package:meu_app/widget/widget_associacao_usuario_certificado.dart';
import 'package:meu_app/widget/widget_associacao_certificado_categoria.dart';
import 'package:meu_app/widget/widget_associacao_certificado_area.dart';
import 'package:meu_app/widget/widget_add_certificate.dart';

class WidgetDashboard extends StatelessWidget {
  const WidgetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardButton(context, 'Cadastro de Usuário', WidgetCadastroUsuario()),
            _buildDashboardButton(context, 'Cadastro de Instituição', WidgetCadastroInstituicao()),
            _buildDashboardButton(context, 'Cadastro de Tipo de Certificado', WidgetCadastroTipoCertificado()),
            _buildDashboardButton(context, 'Cadastro de Categoria', WidgetCadastroCategoria()),
            _buildDashboardButton(context, 'Cadastro de Área', WidgetCadastroArea()),
            _buildDashboardButton(context, 'Certificado e Documento Digital', WidgetCadastroCertificadoDocumento()),
            _buildDashboardButton(context, 'Usuário x Certificado', WidgetAssociacaoUsuarioCertificado()),
            _buildDashboardButton(context, 'Certificado x Categoria', WidgetAssociacaoCertificadoCategoria()),
            _buildDashboardButton(context, 'Certificado x Área', WidgetAssociacaoCertificadoArea()),
            _buildDashboardButton(context, 'Adicionar Certificado', WidgetAddCertificate()),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, Widget targetWidget) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetWidget),
      ),
      child: Text(title, textAlign: TextAlign.center),
    );
  }
}
