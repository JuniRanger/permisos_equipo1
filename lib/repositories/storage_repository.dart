import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppFile {
  const AppFile({required this.name, required this.bytes});
  final String name;
  final int bytes;
}

abstract class StorageRepository {
  Future<void> saveNote(String fileName, String content);
  Future<String> readNote(String fileName);
  Future<List<AppFile>> listFiles();

  /// Intenta listar el almacenamiento compartido (carpeta Download).
  Future<String> probeSharedStorage();
}

const String kNoteFileName = 'nota_equipo1.txt';

/// Implementacion real: archivos en el directorio de documentos de la app y
/// prueba de lectura en almacenamiento compartido.
class LocalStorageRepository implements StorageRepository {
  Future<File> _file(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name');
  }

  @override
  Future<void> saveNote(String fileName, String content) async {
    await (await _file(fileName)).writeAsString(content);
  }

  @override
  Future<String> readNote(String fileName) async =>
      (await _file(fileName)).readAsString();

  @override
  Future<List<AppFile>> listFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final out = <AppFile>[];
    await for (final e in dir.list()) {
      if (e is File) {
        out.add(AppFile(
          name: e.uri.pathSegments.last,
          bytes: await e.length(),
        ));
      }
    }
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  @override
  Future<String> probeSharedStorage() async {
    const path = '/storage/emulated/0/Download';
    try {
      final entries = await Directory(path).list().toList();
      return 'OK: $path -> ${entries.length} entradas visibles.';
    } catch (e) {
      return 'Sin acceso a $path: $e';
    }
  }
}

/// Implementacion en memoria (Chrome / pruebas).
class SimulatedStorageRepository implements StorageRepository {
  final Map<String, String> _files = {};

  @override
  Future<void> saveNote(String fileName, String content) async {
    _files[fileName] = content;
  }

  @override
  Future<String> readNote(String fileName) async {
    final v = _files[fileName];
    if (v == null) throw StateError('Archivo no encontrado: $fileName');
    return v;
  }

  @override
  Future<List<AppFile>> listFiles() async {
    final out = _files.entries
        .map((e) => AppFile(name: e.key, bytes: utf8.encode(e.value).length))
        .toList();
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  @override
  Future<String> probeSharedStorage() async =>
      'SIMULADO: el almacenamiento compartido no existe en web.';
}
