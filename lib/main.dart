import 'package:flutter/material.dart';

import 'app_services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PermisosApp(services: AppServices.forPlatform()));
}

class PermisosApp extends StatelessWidget {
  const PermisosApp({super.key, required this.services});
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permisos Equipo 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: HomeScreen(services: services),
    );
  }
}
