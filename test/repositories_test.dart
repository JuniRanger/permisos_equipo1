import 'package:flutter_test/flutter_test.dart';
import 'package:permisos_equipo1/repositories/calendar_repository.dart';
import 'package:permisos_equipo1/repositories/contacts_repository.dart';
import 'package:permisos_equipo1/repositories/storage_repository.dart';

void main() {
  group('SimulatedCalendarRepository', () {
    test('tiene evento semilla y crea evento demo', () async {
      final repo = SimulatedCalendarRepository();
      expect((await repo.upcoming()).length, 1);
      await repo.createDemoEvent();
      final events = await repo.upcoming();
      expect(events.length, 2);
      expect(events.any((e) => e.title == kDemoEventTitle), isTrue);
    });
    test('eventos ordenados por fecha', () async {
      final repo = SimulatedCalendarRepository();
      await repo.createDemoEvent();
      final events = await repo.upcoming();
      expect(events.first.start!.isBefore(events.last.start!), isTrue);
    });
  });

  group('SimulatedContactsRepository', () {
    test('lista semilla y crea contacto demo', () async {
      final repo = SimulatedContactsRepository();
      expect((await repo.list()).length, 2);
      await repo.createDemoContact();
      final list = await repo.list();
      expect(list.length, 3);
      expect(list.last.name, kDemoContactName);
      expect(list.last.phone, kDemoContactPhone);
    });
  });

  group('SimulatedStorageRepository', () {
    test('guarda, lista y lee', () async {
      final repo = SimulatedStorageRepository();
      expect(await repo.listFiles(), isEmpty);
      await repo.saveNote(kNoteFileName, 'hola');
      final files = await repo.listFiles();
      expect(files.single.name, kNoteFileName);
      expect(files.single.bytes, 4);
      expect(await repo.readNote(kNoteFileName), 'hola');
    });
    test('leer archivo inexistente lanza error', () async {
      final repo = SimulatedStorageRepository();
      expect(() => repo.readNote('nada.txt'), throwsStateError);
    });
    test('sobrescribe el mismo archivo', () async {
      final repo = SimulatedStorageRepository();
      await repo.saveNote(kNoteFileName, 'a');
      await repo.saveNote(kNoteFileName, 'abc');
      expect((await repo.listFiles()).length, 1);
      expect(await repo.readNote(kNoteFileName), 'abc');
    });
    test('probe compartido devuelve texto simulado', () async {
      final repo = SimulatedStorageRepository();
      expect(await repo.probeSharedStorage(), contains('SIMULADO'));
    });
  });
}
