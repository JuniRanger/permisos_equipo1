import 'package:flutter/material.dart';

import '../app_services.dart';
import '../permissions/permission_gateway.dart';
import '../repositories/contacts_repository.dart';
import '../widgets/permission_gate.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key, required this.services});
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1.3 Contactos')),
      body: Column(
        children: [
          if (services.isSimulated) const SimulatedBanner(),
          Expanded(
            child: PermissionGate(
              gateway: services.gateway,
              permission: AppPermission.contacts,
              grantedBuilder: (_) => _ContactsBody(repo: services.contacts),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactsBody extends StatefulWidget {
  const _ContactsBody({required this.repo});
  final ContactsRepository repo;

  @override
  State<_ContactsBody> createState() => _ContactsBodyState();
}

class _ContactsBodyState extends State<_ContactsBody> {
  List<AppContact> _contacts = [];
  String? _message;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = await widget.repo.list();
      if (!mounted) return;
      setState(() {
        _contacts = c;
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _message = 'Error al leer contactos: $err';
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    try {
      await widget.repo.createDemoContact();
      _message = 'Contacto creado correctamente.';
    } catch (err) {
      _message = 'Error al crear contacto: $err';
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              FilledButton.icon(
                key: const Key('btn-create-contact'),
                onPressed: _create,
                icon: const Icon(Icons.person_add),
                label: const Text('Crear contacto de prueba'),
              ),
              const SizedBox(width: 12),
              Text('Contactos: ${_contacts.length}',
                  key: const Key('contacts-count')),
            ],
          ),
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_message!, key: const Key('contacts-message')),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (_, i) {
                    final c = _contacts[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(c.name),
                      subtitle: Text(c.phone ?? 'Sin teléfono'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
