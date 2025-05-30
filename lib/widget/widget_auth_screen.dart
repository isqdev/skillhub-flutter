import 'package:flutter/material.dart';
import '../app_colors.dart';

class WidgetAuthScreen extends StatelessWidget {
  const WidgetAuthScreen({super.key});

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  fixedSize: const Size(287, 53),
                ),
                child: Text(
                  "Fazer login",
                  style: TextStyle(color: AppColors.white, fontSize: 20),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gray500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: AppColors.white, width: 1.0, style: BorderStyle.solid)
                ),
                fixedSize: const Size(287, 53),
              ),
              child: Text(
                "Criar conta",
                style: TextStyle(color: AppColors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
