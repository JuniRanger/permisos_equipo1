import 'package:flutter_contacts/flutter_contacts.dart';

class AppContact {
  const AppContact({required this.name, this.phone});
  final String name;
  final String? phone;
}

abstract class ContactsRepository {
  Future<List<AppContact>> list();
  Future<void> createDemoContact();
}

const String kDemoContactName = 'Demo Equipo 1';
const String kDemoContactPhone = '9991234567';

/// Implementacion real con flutter_contacts (Android).
class DeviceContactsRepository implements ContactsRepository {
  @override
  Future<List<AppContact>> list() async {
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    return contacts
        .map((c) => AppContact(
              name: c.displayName,
              phone: c.phones.isNotEmpty ? c.phones.first.number : null,
            ))
        .toList();
  }

  @override
  Future<void> createDemoContact() async {
    final contact = Contact()
      ..name.first = kDemoContactName
      ..phones = [Phone(kDemoContactPhone)];
    await contact.insert();
  }
}

/// Implementacion en memoria (Chrome / pruebas).
class SimulatedContactsRepository implements ContactsRepository {
  final List<AppContact> _contacts = [
    const AppContact(name: 'Ana Demo', phone: '9990000001'),
    const AppContact(name: 'Luis Demo', phone: '9990000002'),
  ];

  @override
  Future<List<AppContact>> list() async => List<AppContact>.of(_contacts);

  @override
  Future<void> createDemoContact() async {
    _contacts.add(const AppContact(
        name: kDemoContactName, phone: kDemoContactPhone));
  }
}
