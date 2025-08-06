import 'package:flutter/material.dart';
import 'package:meu_app/settings/app.dart';
import 'package:meu_app/settings/initialization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await InitializationService.initialize();
  
  runApp(MyApp());
}

