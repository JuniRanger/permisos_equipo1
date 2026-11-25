import 'package:flutter/material.dart';

import '../permissions/permission_gateway.dart';

/// Banner que avisa que se esta usando la version simulada (Chrome).
class SimulatedBanner extends StatelessWidget {
  const SimulatedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('simulated-banner'),
      width: double.infinity,
      color: Colors.amber.shade200,
      padding: const EdgeInsets.all(8),
      child: const Text(
        'MODO SIMULADO (web): los permisos y datos son de demostración. '
        'Los permisos reales solo existen en Android.',
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Muestra el estado del permiso, permite solicitarlo y, si esta concedido,
/// construye el contenido protegido.
class PermissionGate extends StatefulWidget {
  const PermissionGate({
    super.key,
    required this.gateway,
    required this.permission,
    required this.grantedBuilder,
  });

  final PermissionGateway gateway;
  final AppPermission permission;
  final WidgetBuilder grantedBuilder;

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate>
    with WidgetsBindingObserver {
  PermState? _state;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Al volver de Ajustes se vuelve a consultar el permiso.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final s = await widget.gateway.status(widget.permission);
    if (!mounted) return;
    setState(() => _state = s);
  }

  Future<void> _request() async {
    setState(() => _busy = true);
    final s = await widget.gateway.request(widget.permission);
    if (!mounted) return;
    setState(() {
      _state = s;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: ListTile(
            leading: Icon(
              (state?.isGranted ?? false) ? Icons.lock_open : Icons.lock,
            ),
            title: Text('Permiso: ${widget.permission.title}'),
            subtitle: Text(widget.permission.rationale),
            trailing: Chip(
              label: Text(
                state?.label ?? '...',
                key: const Key('perm-status-text'),
              ),
            ),
          ),
        ),
        if (state == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          )
        else if (state.isGranted)
          Expanded(child: widget.grantedBuilder(context))
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Sin permiso no se puede mostrar este módulo.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (state == PermState.permanentlyDenied ||
                    state == PermState.restricted)
                  FilledButton.icon(
                    key: const Key('btn-settings'),
                    onPressed: widget.gateway.openSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Abrir ajustes'),
                  )
                else
                  FilledButton.icon(
                    key: const Key('btn-request'),
                    onPressed: _busy ? null : _request,
                    icon: const Icon(Icons.verified_user),
                    label: const Text('Solicitar permiso'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
