import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

/// Permisos que cubre el Equipo 1: 1.1 Calendario, 1.3 Contactos, 1.11 Storage.
enum AppPermission { calendar, contacts, storage }

extension AppPermissionX on AppPermission {
  String get title {
    switch (this) {
      case AppPermission.calendar:
        return 'Calendario';
      case AppPermission.contacts:
        return 'Contactos';
      case AppPermission.storage:
        return 'Almacenamiento';
    }
  }

  String get rationale {
    switch (this) {
      case AppPermission.calendar:
        return 'Necesitamos acceso al calendario para leer y crear eventos.';
      case AppPermission.contacts:
        return 'Necesitamos acceso a tus contactos para listarlos y crear uno.';
      case AppPermission.storage:
        return 'Necesitamos acceso al almacenamiento para leer y guardar archivos.';
    }
  }
}

/// Estado simplificado, independiente del plugin (facilita pruebas).
enum PermState { granted, denied, permanentlyDenied, restricted, limited }

extension PermStateX on PermState {
  String get label {
    switch (this) {
      case PermState.granted:
        return 'Concedido';
      case PermState.denied:
        return 'Denegado';
      case PermState.permanentlyDenied:
        return 'Denegado permanentemente';
      case PermState.restricted:
        return 'Restringido';
      case PermState.limited:
        return 'Limitado';
    }
  }

  bool get isGranted => this == PermState.granted || this == PermState.limited;
}

/// Convierte el estado del plugin permission_handler a [PermState].
PermState mapPermissionStatus(PermissionStatus status) {
  switch (status) {
    case PermissionStatus.granted:
    case PermissionStatus.provisional:
      return PermState.granted;
    case PermissionStatus.denied:
      return PermState.denied;
    case PermissionStatus.permanentlyDenied:
      return PermState.permanentlyDenied;
    case PermissionStatus.restricted:
      return PermState.restricted;
    case PermissionStatus.limited:
      return PermState.limited;
  }
}

abstract class PermissionGateway {
  Future<PermState> status(AppPermission permission);
  Future<PermState> request(AppPermission permission);
  Future<bool> openSettings();
}

/// Implementacion real (Android) con permission_handler.
class PermissionHandlerGateway implements PermissionGateway {
  int? _sdk;

  Future<int> _androidSdk() async {
    if (_sdk != null) return _sdk!;
    if (!kIsWeb && Platform.isAndroid) {
      _sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    } else {
      _sdk = 0;
    }
    return _sdk!;
  }

  Future<Permission> _map(AppPermission p) async {
    switch (p) {
      case AppPermission.calendar:
        return Permission.calendar;
      case AppPermission.contacts:
        return Permission.contacts;
      case AppPermission.storage:
        // Android 13+ (API 33) ya no usa READ_EXTERNAL_STORAGE.
        return (await _androidSdk()) >= 33
            ? Permission.photos
            : Permission.storage;
    }
  }

  @override
  Future<PermState> status(AppPermission permission) async =>
      mapPermissionStatus(await (await _map(permission)).status);

  @override
  Future<PermState> request(AppPermission permission) async =>
      mapPermissionStatus(await (await _map(permission)).request());

  @override
  Future<bool> openSettings() => openAppSettings();
}

/// Implementacion simulada: se usa en Chrome (web) y en las pruebas.
class SimulatedPermissionGateway implements PermissionGateway {
  SimulatedPermissionGateway({
    this.initial = PermState.denied,
    this.requestResult = PermState.granted,
  });

  final PermState initial;
  final PermState requestResult;
  final Map<AppPermission, PermState> _states = {};
  bool settingsOpened = false;

  @override
  Future<PermState> status(AppPermission permission) async =>
      _states[permission] ?? initial;

  @override
  Future<PermState> request(AppPermission permission) async {
    final current = _states[permission] ?? initial;
    if (current == PermState.granted) return current;
    _states[permission] = requestResult;
    return requestResult;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened = true;
    return true;
  }
}
