import 'package:flutter/foundation.dart' show kIsWeb;

import 'permissions/permission_gateway.dart';
import 'repositories/calendar_repository.dart';
import 'repositories/contacts_repository.dart';
import 'repositories/storage_repository.dart';

/// Agrupa dependencias. En web (Chrome) y en pruebas usa versiones simuladas.
class AppServices {
  AppServices({
    required this.gateway,
    required this.calendar,
    required this.contacts,
    required this.storage,
    required this.isSimulated,
  });

  final PermissionGateway gateway;
  final CalendarRepository calendar;
  final ContactsRepository contacts;
  final StorageRepository storage;
  final bool isSimulated;

  factory AppServices.real() => AppServices(
        gateway: PermissionHandlerGateway(),
        calendar: DeviceCalendarRepository(),
        contacts: DeviceContactsRepository(),
        storage: LocalStorageRepository(),
        isSimulated: false,
      );

  factory AppServices.simulated({PermissionGateway? gateway}) => AppServices(
        gateway: gateway ?? SimulatedPermissionGateway(),
        calendar: SimulatedCalendarRepository(),
        contacts: SimulatedContactsRepository(),
        storage: SimulatedStorageRepository(),
        isSimulated: true,
      );

  factory AppServices.forPlatform() =>
      kIsWeb ? AppServices.simulated() : AppServices.real();
}
