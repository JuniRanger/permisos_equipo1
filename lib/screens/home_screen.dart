import 'package:flutter/material.dart';

import '../app_services.dart';
import '../widgets/permission_gate.dart';
import 'calendar_screen.dart';
import 'contacts_screen.dart';
import 'storage_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.services});
  final AppServices services;

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permisos en Flutter - Equipo 1')),
      body: ListView(
        children: [
          if (services.isSimulated) const SimulatedBanner(),
          ListTile(
            key: const Key('tile-calendar'),
            leading: const Icon(Icons.calendar_month),
            title: const Text('1.1 Calendario'),
            subtitle: const Text('Leer y crear eventos'),
            onTap: () => _open(context, CalendarScreen(services: services)),
          ),
          ListTile(
            key: const Key('tile-contacts'),
            leading: const Icon(Icons.contacts),
            title: const Text('1.3 Contactos'),
            subtitle: const Text('Listar y crear contactos'),
            onTap: () => _open(context, ContactsScreen(services: services)),
          ),
          ListTile(
            key: const Key('tile-storage'),
            leading: const Icon(Icons.sd_storage),
            title: const Text('1.11 Storage'),
            subtitle: const Text('Leer y guardar archivos'),
            onTap: () => _open(context, StorageScreen(services: services)),
          ),
        ],
      ),
    );
  }
}
