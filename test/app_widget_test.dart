import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permisos_equipo1/app_services.dart';
import 'package:permisos_equipo1/main.dart';
import 'package:permisos_equipo1/permissions/permission_gateway.dart';
import 'package:permisos_equipo1/repositories/calendar_repository.dart';
import 'package:permisos_equipo1/repositories/contacts_repository.dart';
import 'package:permisos_equipo1/repositories/storage_repository.dart';
import 'package:permisos_equipo1/screens/calendar_screen.dart';
import 'package:permisos_equipo1/screens/contacts_screen.dart';
import 'package:permisos_equipo1/screens/storage_screen.dart';
import 'package:permisos_equipo1/widgets/permission_gate.dart';

AppServices granted() => AppServices.simulated(
    gateway: SimulatedPermissionGateway(initial: PermState.granted));

String statusText(WidgetTester t) =>
    t.widget<Text>(find.byKey(const Key('perm-status-text'))).data!;

void main() {
  group('PermissionGate', () {
    Widget host(SimulatedPermissionGateway gw) => MaterialApp(
          home: Scaffold(
            body: PermissionGate(
              gateway: gw,
              permission: AppPermission.calendar,
              grantedBuilder: (_) => const Text('CONTENIDO'),
            ),
          ),
        );

    testWidgets('denegado -> solicitar -> concedido', (tester) async {
      await tester.pumpWidget(host(SimulatedPermissionGateway()));
      await tester.pumpAndSettle();
      expect(statusText(tester), 'Denegado');
      expect(find.text('CONTENIDO'), findsNothing);
      await tester.tap(find.byKey(const Key('btn-request')));
      await tester.pumpAndSettle();
      expect(statusText(tester), 'Concedido');
      expect(find.text('CONTENIDO'), findsOneWidget);
    });

    testWidgets('el usuario rechaza el permiso', (tester) async {
      await tester.pumpWidget(host(
          SimulatedPermissionGateway(requestResult: PermState.denied)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn-request')));
      await tester.pumpAndSettle();
      expect(statusText(tester), 'Denegado');
      expect(find.text('CONTENIDO'), findsNothing);
      expect(find.byKey(const Key('btn-request')), findsOneWidget);
    });

    testWidgets('denegado permanente muestra Abrir ajustes', (tester) async {
      final gw = SimulatedPermissionGateway(initial: PermState.permanentlyDenied);
      await tester.pumpWidget(host(gw));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('btn-request')), findsNothing);
      await tester.tap(find.byKey(const Key('btn-settings')));
      await tester.pumpAndSettle();
      expect(gw.settingsOpened, isTrue);
    });

    testWidgets('ya concedido muestra contenido directo', (tester) async {
      await tester.pumpWidget(
          host(SimulatedPermissionGateway(initial: PermState.granted)));
      await tester.pumpAndSettle();
      expect(find.text('CONTENIDO'), findsOneWidget);
    });
  });

  group('HomeScreen', () {
    testWidgets('muestra los 3 modulos del Equipo 1 y el banner', (tester) async {
      await tester.pumpWidget(PermisosApp(services: AppServices.simulated()));
      await tester.pumpAndSettle();
      expect(find.text('1.1 Calendario'), findsOneWidget);
      expect(find.text('1.3 Contactos'), findsOneWidget);
      expect(find.text('1.11 Storage'), findsOneWidget);
      expect(find.byKey(const Key('simulated-banner')), findsOneWidget);
    });

    testWidgets('navega a cada modulo', (tester) async {
      await tester.pumpWidget(PermisosApp(services: AppServices.simulated()));
      await tester.pumpAndSettle();
      for (final entry in {
        'tile-calendar': 'Permiso: Calendario',
        'tile-contacts': 'Permiso: Contactos',
        'tile-storage': 'Permiso: Almacenamiento',
      }.entries) {
        await tester.tap(find.byKey(Key(entry.key)));
        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    });
  });

  group('CalendarScreen', () {
    testWidgets('flujo completo: pedir permiso y crear evento', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: CalendarScreen(services: AppServices.simulated())));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn-request')));
      await tester.pumpAndSettle();
      expect(find.text('Reunión de equipo (demo)'), findsOneWidget);
      expect(find.text(kDemoEventTitle), findsNothing);
      await tester.tap(find.byKey(const Key('btn-create-event')));
      await tester.pumpAndSettle();
      expect(find.text(kDemoEventTitle), findsOneWidget);
      expect(find.byKey(const Key('calendar-message')), findsOneWidget);
    });
  });

  group('ContactsScreen', () {
    testWidgets('lista y crea contacto', (tester) async {
      await tester.pumpWidget(
          MaterialApp(home: ContactsScreen(services: granted())));
      await tester.pumpAndSettle();
      expect(find.text('Contactos: 2'), findsOneWidget);
      expect(find.text('Ana Demo'), findsOneWidget);
      await tester.tap(find.byKey(const Key('btn-create-contact')));
      await tester.pumpAndSettle();
      expect(find.text('Contactos: 3'), findsOneWidget);
      expect(find.text(kDemoContactName), findsOneWidget);
    });

    testWidgets('sin permiso no muestra contactos', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ContactsScreen(services: AppServices.simulated())));
      await tester.pumpAndSettle();
      expect(find.text('Ana Demo'), findsNothing);
    });
  });

  group('StorageScreen', () {
    testWidgets('guarda nota, la lista y la lee', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
          MaterialApp(home: StorageScreen(services: granted())));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('field-note')), 'hola equipo');
      await tester.tap(find.byKey(const Key('btn-save-note')));
      await tester.pumpAndSettle();
      expect(find.text(kNoteFileName), findsOneWidget);
      await tester.tap(find.text(kNoteFileName));
      await tester.pumpAndSettle();
      expect(find.text('Contenido: hola equipo'), findsOneWidget);
    });

    testWidgets('probar almacenamiento compartido', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
          MaterialApp(home: StorageScreen(services: granted())));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn-probe')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('probe-result')), findsOneWidget);
    });
  });
}
