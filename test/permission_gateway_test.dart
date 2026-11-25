import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permisos_equipo1/permissions/permission_gateway.dart';

void main() {
  group('mapPermissionStatus', () {
    test('granted y provisional -> granted', () {
      expect(mapPermissionStatus(PermissionStatus.granted), PermState.granted);
      expect(mapPermissionStatus(PermissionStatus.provisional), PermState.granted);
    });
    test('denied -> denied', () {
      expect(mapPermissionStatus(PermissionStatus.denied), PermState.denied);
    });
    test('permanentlyDenied -> permanentlyDenied', () {
      expect(mapPermissionStatus(PermissionStatus.permanentlyDenied),
          PermState.permanentlyDenied);
    });
    test('restricted y limited', () {
      expect(mapPermissionStatus(PermissionStatus.restricted), PermState.restricted);
      expect(mapPermissionStatus(PermissionStatus.limited), PermState.limited);
    });
  });

  group('PermState', () {
    test('isGranted', () {
      expect(PermState.granted.isGranted, isTrue);
      expect(PermState.limited.isGranted, isTrue);
      expect(PermState.denied.isGranted, isFalse);
      expect(PermState.permanentlyDenied.isGranted, isFalse);
      expect(PermState.restricted.isGranted, isFalse);
    });
    test('labels en español', () {
      expect(PermState.granted.label, 'Concedido');
      expect(PermState.denied.label, 'Denegado');
    });
  });

  group('AppPermission', () {
    test('titulos', () {
      expect(AppPermission.calendar.title, 'Calendario');
      expect(AppPermission.contacts.title, 'Contactos');
      expect(AppPermission.storage.title, 'Almacenamiento');
    });
  });

  group('SimulatedPermissionGateway', () {
    test('inicia denegado y request concede', () async {
      final gw = SimulatedPermissionGateway();
      expect(await gw.status(AppPermission.calendar), PermState.denied);
      expect(await gw.request(AppPermission.calendar), PermState.granted);
      expect(await gw.status(AppPermission.calendar), PermState.granted);
      // otro permiso sigue denegado
      expect(await gw.status(AppPermission.contacts), PermState.denied);
    });
    test('request puede ser rechazado', () async {
      final gw = SimulatedPermissionGateway(requestResult: PermState.permanentlyDenied);
      expect(await gw.request(AppPermission.storage), PermState.permanentlyDenied);
    });
    test('openSettings se registra', () async {
      final gw = SimulatedPermissionGateway();
      expect(gw.settingsOpened, isFalse);
      await gw.openSettings();
      expect(gw.settingsOpened, isTrue);
    });
  });
}
