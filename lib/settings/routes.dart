import 'package:meu_app/widget/widget_dashboard.dart';
import 'package:meu_app/widget/widget_cadastro_usuario.dart';
import 'package:meu_app/widget/widget_cadastro_instituicao.dart';
import 'package:meu_app/widget/widget_cadastro_tipo_certificado.dart';
import 'package:meu_app/widget/widget_cadastro_categoria.dart';
import 'package:meu_app/widget/widget_cadastro_area.dart';
import 'package:meu_app/widget/widget_auth_screen.dart';
import 'package:meu_app/widget/widget_login.dart';
import 'package:meu_app/widget/widget_perfil.dart';
import 'package:meu_app/widget/widget_add_certificate.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String auth = '/';
  static const String login = '/login';
  static const String signUp = '/cadastro';
  static const String profile = '/perfil';
  static const String certificates = '/certificados';
  static const String addCertificate = '/certificados/cadastro';
  static const String dashboard = '/dashboard';
  static const String cadastroUsuario = '/cadastro_usuario';
  static const String cadastroInstituicao = '/cadastro_instituicao';
  static const String cadastroTipoCertificado = '/cadastro_tipo_certificado';
  static const String cadastroCategoria = '/cadastro_categoria';
  static const String cadastroArea = '/cadastro_area';
}

final Map<String, WidgetBuilder> routes = {
  Routes.auth: (context) => const WidgetAuthScreen(),
  Routes.login: (context) => const WidgetLogin(),
  Routes.profile: (context) => const WidgetPerfil(),
  Routes.addCertificate: (context) => const WidgetAddCertificate(),
  Routes.dashboard: (context) => const WidgetDashboard(),
  Routes.cadastroUsuario: (context) => const WidgetCadastroUsuario(),
  Routes.cadastroInstituicao: (context) => const WidgetCadastroInstituicao(),
  Routes.cadastroTipoCertificado: (context) => const WidgetCadastroTipoCertificado(),
  Routes.cadastroCategoria: (context) => const WidgetCadastroCategoria(),
  Routes.cadastroArea: (context) => const WidgetCadastroArea(),
};