import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';

class WidgetLogin extends StatelessWidget {
  const WidgetLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "SkillHub",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(width: 287, child: Column(children: [

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                style: TextStyle(color: AppColors.white),
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ), 
                  labelText: 'Email ou usuário',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                style: TextStyle(color: AppColors.white),
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ), 
                  labelText: 'Senha',
                ),
              ),
            ),
            ],))
          ],
        ),
      ),
    );
  }
}
