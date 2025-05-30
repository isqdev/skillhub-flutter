import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import 'package:meu_app/widget/widget_add_certificate.dart';
import 'package:meu_app/widget/widget_auth_screen.dart';
import 'package:meu_app/widget/widget_login.dart';
import 'package:meu_app/widget/widget_perfil.dart';

class MyApp extends StatelessWidget {
  const MyApp({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillHub',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.gray500
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      
      routes: {
        '/' : (context) => WidgetAuthScreen(),
        '/login' : (context) => WidgetLogin(),
        '/perfil' : (context) => WidgetPerfil(),
        '/certificado/cadastro' : (context) => WidgetAddCertificate()
      }
    );
  }
}