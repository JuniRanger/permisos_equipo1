import 'package:flutter/material.dart';

import '../app_services.dart';
import '../permissions/permission_gateway.dart';
import '../repositories/calendar_repository.dart';
import '../utils/format.dart';
import '../widgets/permission_gate.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, required this.services});
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1.1 Calendario')),
      body: Column(
        children: [
          if (services.isSimulated) const SimulatedBanner(),
          Expanded(
            child: PermissionGate(
              gateway: services.gateway,
              permission: AppPermission.calendar,
              grantedBuilder: (_) => _CalendarBody(repo: services.calendar),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarBody extends StatefulWidget {
  const _CalendarBody({required this.repo});
  final CalendarRepository repo;

  @override
  State<_CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<_CalendarBody> {
  List<AppEvent> _events = [];
  String? _message;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final e = await widget.repo.upcoming();
      if (!mounted) return;
      setState(() {
        _events = e;
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _message = 'Error al leer eventos: $err';
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    try {
      await widget.repo.createDemoEvent();
      _message = 'Evento creado correctamente.';
    } catch (err) {
      _message = 'Error al crear evento: $err';
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
                key: const Key('btn-create-event'),
                onPressed: _create,
                icon: const Icon(Icons.event_available),
                label: const Text('Crear evento de prueba'),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: const Key('btn-refresh-events'),
                onPressed: () {
                  setState(() => _loading = true);
                  _load();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_message!, key: const Key('calendar-message')),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _events.isEmpty
                  ? const Center(child: Text('No hay eventos en los próximos 30 días.'))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (_, i) {
                        final e = _events[i];
                        return ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(e.title),
                          subtitle: Text(
                              '${formatDateTime(e.start)} - ${e.calendar}'),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
