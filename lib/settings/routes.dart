import 'package:meu_app/widget/entities/add/widget_add_user.dart';
import 'package:meu_app/widget/entities/edit/widget_edit_user.dart';
import 'package:meu_app/widget/entities/view/widget_user.dart';
import 'package:meu_app/widget/widget_auth_screen.dart';
import 'package:meu_app/widget/widget_dashboard.dart';
import 'package:meu_app/widget/widget_login.dart';
import 'package:meu_app/widget/entities/view/widget_certificate.dart';
import 'package:meu_app/widget/entities/add/widget_add_certificate.dart';
import 'package:meu_app/widget/entities/edit/widget_edit_certificate.dart';
import 'package:meu_app/widget/entities/view/widget_event.dart';
import 'package:meu_app/widget/entities/add/widget_add_event.dart';
import 'package:meu_app/widget/entities/edit/widget_edit_event.dart';
import 'package:meu_app/widget/entities/view/widget_institution.dart';
import 'package:meu_app/widget/entities/add/widget_add_institution.dart';
import 'package:meu_app/widget/entities/edit/widget_edit_institution.dart';
import 'package:meu_app/widget/entities/view/widget_area.dart';
import 'package:meu_app/widget/entities/add/widget_add_area.dart';
import 'package:meu_app/widget/entities/edit/widget_edit_area.dart';
import 'package:meu_app/widget/entities/view/widget_tag.dart';
import 'package:meu_app/widget/entities/add/widget_add_tag.dart';
import 'package:meu_app/widget/entities/edit/widget_edit_tag.dart';
import 'package:meu_app/widget/entities/view/widget_certificate_type.dart';
import 'package:meu_app/widget/entities/add/widget_add_certificate_type.dart';
import 'package:meu_app/widget/entities/edit/widget_edit_certificate_type.dart';
import 'package:meu_app/widget/entities/view/widget_favorite_courses.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String auth = '/';
  static const String login = '/login';
  static const String signUp = '/cadastro';
  static const String profile = '/certificate';

  static const String certificates = '/certificados';
  static const String addCertificate = '/certificados/cadastro';
  static const String editCertificate = '/certificados/editar';
  
  static const String user = '/user';
  static const String addUser = '/user/cadastro';
  static const String editUser = '/user/editar';
  
  static const String events = '/eventos';
  static const String addEvents = '/evento/cadastro';
  static const String editEvent = '/evento/editar';
  
  static const String instituition = '/institucoes';
  static const String addInstituition = '/instituicao/cadastro';
  static const String editInstitution = '/instituicao/editar';
  
  static const String areas = '/areas';
  static const String addArea = '/area/cadastro';
  static const String editArea = '/area/editar';
  
  static const String tags = '/tags';
  static const String addTag = '/tag/cadastro';
  static const String editTag = '/tag/editar';
  
  static const String certificateTypes = '/tipos-certificado';
  static const String addCertificateType = '/tipo-certificado/cadastro';
  static const String editCertificateType = '/tipo-certificado/editar';
  
  static const String favoriteCourses = '/cursos-favoritos';

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
  Routes.certificates: (context) => const WidgetCertificate(),
  Routes.user: (context) => const WidgetUser(),
  Routes.addUser: (context) => const WidgetAddUser(),
  Routes.dashboard: (context) => const WidgetDashboard(),
  Routes.addCertificate: (context) => const WidgetAddCertificate(),
  Routes.events: (context) => const WidgetEvent(),
  Routes.addEvents: (context) => const WidgetAddEvent(),
  Routes.instituition: (context) => const WidgetInstitution(),
  Routes.addInstituition: (context) => const WidgetAddInstitution(),
  Routes.areas: (context) => const WidgetArea(),
  Routes.addArea: (context) => const WidgetAddArea(),
  Routes.tags: (context) => const WidgetTag(),
  Routes.addTag: (context) => const WidgetAddTag(),
  Routes.certificateTypes: (context) => const WidgetCertificateType(),
  Routes.addCertificateType: (context) => const WidgetAddCertificateType(),
  Routes.favoriteCourses: (context) => const WidgetFavoriteCourses(),
};