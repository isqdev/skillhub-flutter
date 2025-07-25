import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';

class WidgetFavoriteCourses extends StatelessWidget {
  const WidgetFavoriteCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cursos Favoritos", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white), // Cor dos ícones
        centerTitle: true,
        backgroundColor: AppColors.gray500,
        actions: [
          IconButton(icon: Icon(Icons.menu), onPressed: () {}),
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
                  FavoriteCourseCard(
                    name: "Curso Completo de Flutter",
                    instructor: "João Silva",
                    duration: "40 horas",
                  ),
                  FavoriteCourseCard(
                    name: "Python para Iniciantes",
                    instructor: "Maria Santos",
                    duration: "25 horas",
                  ),
                  FavoriteCourseCard(
                    name: "React Native Avançado",
                    instructor: "Carlos Oliveira",
                    duration: "60 horas",
                  ),
                  FavoriteCourseCard(
                    name: "Machine Learning com Python",
                    instructor: "Ana Costa",
                    duration: "80 horas",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteCourseCard extends StatelessWidget {
  final String name;
  final String instructor;
  final String duration;

  const FavoriteCourseCard({
    super.key,
    this.name = "Nome do curso",
    this.instructor = "Instrutor",
    this.duration = "0 horas",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal,
              ),
              child: Icon(
                Icons.favorite,
                size: 30,
                color: AppColors.white,
              ),
            ),
          ),
          Expanded(
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
                SizedBox(height: 4),
                Text(
                  instructor,
                  style: TextStyle(color: AppColors.white, fontSize: 14),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gray500,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.teal),
            color: AppColors.gray400,
            onSelected: (String value) {
              switch (value) {
                case 'editar':
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Editar $name')),
                  );
                  break;
                case 'excluir':
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.gray400,
                        title: Text(
                          'Confirmar remoção',
                          style: TextStyle(color: AppColors.white),
                        ),
                        content: Text(
                          'Deseja realmente remover "$name" dos favoritos?',
                          style: TextStyle(color: AppColors.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$name removido dos favoritos!')),
                              );
                            },
                            child: Text(
                              'Remover',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Editar',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Remover dos favoritos',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
