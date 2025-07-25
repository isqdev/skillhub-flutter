import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import './../settings/routes.dart'; // Importar o arquivo de rotas

class WidgetDashboard extends StatelessWidget {
  const WidgetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, Routes.profile),
            tooltip: 'Meu perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  DashboardButton(
                    icon: Icons.person_add,
                    title: "Cadastro de\nUsuário",
                    onPressed: () => Navigator.pushNamed(context, Routes.user),
                  ),
                  DashboardButton(
                    icon: Icons.card_membership,
                    title: "Certificados",
                    onPressed: () => Navigator.pushNamed(context, Routes.certificates),
                  ),
                  DashboardButton(
                    icon: Icons.event,
                    title: "Eventos",
                    onPressed: () => Navigator.pushNamed(context, Routes.events),
                  ),
                  DashboardButton(
                    icon: Icons.business,
                    title: "Instituições",
                    onPressed: () => Navigator.pushNamed(context, Routes.instituition),
                  ),
                  DashboardButton(
                    icon: Icons.category,
                    title: "Áreas",
                    onPressed: () => Navigator.pushNamed(context, Routes.areas),
                  ),
                  DashboardButton(
                    icon: Icons.label,
                    title: "Tags",
                    onPressed: () => Navigator.pushNamed(context, Routes.tags),
                  ),
                  DashboardButton(
                    icon: Icons.assignment,
                    title: "Tipo de\nCertificado",
                    onPressed: () => Navigator.pushNamed(context, Routes.certificateTypes),
                  ),
                  DashboardButton(
                    icon: Icons.favorite,
                    title: "Cursos\nFavoritos",
                    onPressed: () => Navigator.pushNamed(context, Routes.favoriteCourses),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const DashboardButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: AppColors.teal,
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}