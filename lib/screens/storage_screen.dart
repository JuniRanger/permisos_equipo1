import 'package:flutter/material.dart';

import '../app_services.dart';
import '../permissions/permission_gateway.dart';
import '../repositories/storage_repository.dart';
import '../widgets/permission_gate.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key, required this.services});
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1.11 Storage')),
      body: Column(
        children: [
          if (services.isSimulated) const SimulatedBanner(),
          Expanded(
            child: PermissionGate(
              gateway: services.gateway,
              permission: AppPermission.storage,
              grantedBuilder: (_) => _StorageBody(repo: services.storage),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageBody extends StatefulWidget {
  const _StorageBody({required this.repo});
  final StorageRepository repo;

  @override
  State<_StorageBody> createState() => _StorageBodyState();
}

class _StorageBodyState extends State<_StorageBody> {
  final TextEditingController _controller = TextEditingController();
  List<AppFile> _files = [];
  String? _content;
  String? _probe;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final f = await widget.repo.listFiles();
      if (!mounted) return;
      setState(() => _files = f);
    } catch (err) {
      if (!mounted) return;
      setState(() => _message = 'Error al listar archivos: $err');
    }
  }

  Future<void> _save() async {
    try {
      await widget.repo.saveNote(kNoteFileName, _controller.text);
      _message = 'Archivo guardado: $kNoteFileName';
    } catch (err) {
      _message = 'Error al guardar: $err';
    }
    await _load();
  }

  Future<void> _read(String name) async {
    try {
      final c = await widget.repo.readNote(name);
      if (!mounted) return;
      setState(() => _content = c);
    } catch (err) {
      if (!mounted) return;
      setState(() => _message = 'Error al leer: $err');
    }
  }

  Future<void> _probeShared() async {
    final r = await widget.repo.probeSharedStorage();
    if (!mounted) return;
    setState(() => _probe = r);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        TextField(
          key: const Key('field-note'),
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Texto de la nota',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.icon(
              key: const Key('btn-save-note'),
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Guardar nota'),
            ),
            OutlinedButton.icon(
              key: const Key('btn-probe'),
              onPressed: _probeShared,
              icon: const Icon(Icons.folder_open),
              label: const Text('Probar almacenamiento compartido'),
            ),
          ],
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_message!, key: const Key('storage-message')),
          ),
        if (_probe != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_probe!, key: const Key('probe-result')),
          ),
        const Divider(),
        const Text('Archivos de la app (toca uno para leerlo):'),
        for (final f in _files)
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(f.name),
            subtitle: Text('${f.bytes} bytes'),
            onTap: () => _read(f.name),
          ),
        if (_content != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Contenido: $_content', key: const Key('note-content')),
          ),
      ],
    );
  }
}
