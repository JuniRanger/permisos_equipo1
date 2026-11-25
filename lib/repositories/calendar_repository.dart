import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class AppEvent {
  const AppEvent({
    required this.title,
    required this.start,
    required this.end,
    required this.calendar,
  });
  final String title;
  final DateTime? start;
  final DateTime? end;
  final String calendar;
}

abstract class CalendarRepository {
  Future<List<AppEvent>> upcoming();
  Future<void> createDemoEvent();
}

const String kDemoEventTitle = 'Entrega práctica 12 - Equipo 1';

/// Implementacion real con device_calendar (Android).
class DeviceCalendarRepository implements CalendarRepository {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  bool _tzReady = false;

  void _initTz() {
    if (!_tzReady) {
      tzdata.initializeTimeZones();
      _tzReady = true;
    }
  }

  Future<List<Calendar>> _calendars() async {
    final res = await _plugin.retrieveCalendars();
    return res.data ?? <Calendar>[];
  }

  @override
  Future<List<AppEvent>> upcoming() async {
    _initTz();
    final now = DateTime.now();
    final end = now.add(const Duration(days: 30));
    final out = <AppEvent>[];
    for (final c in await _calendars()) {
      if (c.id == null) continue;
      final res = await _plugin.retrieveEvents(
        c.id,
        RetrieveEventsParams(startDate: now, endDate: end),
      );
      for (final e in res.data ?? <Event>[]) {
        out.add(AppEvent(
          title: e.title ?? '(sin título)',
          start: e.start?.toLocal(),
          end: e.end?.toLocal(),
          calendar: c.name ?? '',
        ));
      }
    }
    out.sort((a, b) => (a.start ?? now).compareTo(b.start ?? now));
    return out;
  }

  @override
  Future<void> createDemoEvent() async {
    _initTz();
    String? calendarId;
    for (final c in await _calendars()) {
      if (c.isReadOnly == false && c.id != null) {
        calendarId = c.id;
        break;
      }
    }
    if (calendarId == null) {
      throw StateError('No hay un calendario editable en el dispositivo.');
    }
    final start = DateTime.now().add(const Duration(hours: 1));
    final event = Event(
      calendarId,
      title: kDemoEventTitle,
      description: 'Evento creado desde la app de permisos.',
      start: tz.TZDateTime.from(start, tz.UTC),
      end: tz.TZDateTime.from(start.add(const Duration(hours: 1)), tz.UTC),
    );
    final res = await _plugin.createOrUpdateEvent(event);
    if (res == null || !res.isSuccess) {
      throw StateError('No se pudo crear el evento.');
    }
  }
}

/// Implementacion en memoria (Chrome / pruebas).
class SimulatedCalendarRepository implements CalendarRepository {
  final List<AppEvent> _events = [
    AppEvent(
      title: 'Reunión de equipo (demo)',
      start: DateTime.now().add(const Duration(days: 1)),
      end: DateTime.now().add(const Duration(days: 1, hours: 1)),
      calendar: 'Calendario simulado',
    ),
  ];

  @override
  Future<List<AppEvent>> upcoming() async {
    final list = List<AppEvent>.of(_events);
    list.sort((a, b) => a.start!.compareTo(b.start!));
    return list;
  }

  @override
  Future<void> createDemoEvent() async {
    final start = DateTime.now().add(const Duration(hours: 1));
    _events.add(AppEvent(
      title: kDemoEventTitle,
      start: start,
      end: start.add(const Duration(hours: 1)),
      calendar: 'Calendario simulado',
    ));
  }
}
