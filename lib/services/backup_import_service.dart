import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;

import '../models/library_backup.dart';
import 'library_backup_validator.dart';
import 'portable_backup_archive_reader.dart';

/// Valitun varmuuskopion tiedostomuoto.
enum BackupImportType {
  /// Vanha itsenäinen JSON-varmuuskopio.
  json,

  /// Kansikuvat sisältävä ZIP-varmuuskopio.
  portableZip,
}

/// Sisältää käyttäjän valitseman varmuuskopiotiedoston tiedot.
class BackupImportSelection {
  final String fileName;
  final BackupImportType type;
  final LibraryBackup backup;

  /// ZIP-varmuuskopiosta luetut paikalliset kansikuvat.
  ///
  /// JSON-varmuuskopiossa tämä map on tyhjä.
  final Map<String, Uint8List> coverFiles;

  BackupImportSelection({
    required this.fileName,
    required this.type,
    required this.backup,
    Map<String, Uint8List> coverFiles = const {},
  }) : coverFiles = Map.unmodifiable(<String, Uint8List>{
         for (final entry in coverFiles.entries)
           entry.key: Uint8List.fromList(entry.value),
       });

  bool get isPortable => type == BackupImportType.portableZip;

  bool get containsCoverFiles => coverFiles.isNotEmpty;
}

/// Valitsee, lukee ja tarkistaa JSON- tai ZIP-varmuuskopion.
class BackupImportService {
  final LibraryBackupValidator _validator;
  final PortableBackupArchiveReader _portableArchiveReader;

  const BackupImportService({
    LibraryBackupValidator validator = const LibraryBackupValidator(),
    PortableBackupArchiveReader portableArchiveReader =
        const PortableBackupArchiveReader(),
  }) : _validator = validator,
       _portableArchiveReader = portableArchiveReader;

  static const XTypeGroup _backupTypeGroup = XTypeGroup(
    label: 'My Shelf -varmuuskopio',
    extensions: <String>['json', 'zip'],
    mimeTypes: <String>[
      'application/json',
      'application/zip',
      'application/x-zip-compressed',
    ],
    uniformTypeIdentifiers: <String>['public.json', 'com.pkware.zip-archive'],
  );

  /// Avaa tiedostonvalitsimen.
  ///
  /// Palauttaa null-arvon, jos käyttäjä peruuttaa valinnan.
  Future<BackupImportSelection?> pickBackup() async {
    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_backupTypeGroup],
      confirmButtonText: 'Valitse varmuuskopio',
    );

    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();

    return decodeBackupFile(fileName: file.name, bytes: bytes);
  }

  /// Tunnistaa tiedostomuodon tiedostopäätteestä ja lukee varmuuskopion.
  ///
  /// Metodi ei kirjoita mitään laitteen tallennustilaan.
  BackupImportSelection decodeBackupFile({
    required String fileName,
    required Uint8List bytes,
  }) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.json':
        final source = _decodeJsonText(bytes);
        final backup = decodeAndValidate(source);

        return BackupImportSelection(
          fileName: fileName,
          type: BackupImportType.json,
          backup: backup,
        );

      case '.zip':
        final archiveData = _portableArchiveReader.decode(bytes);

        return BackupImportSelection(
          fileName: fileName,
          type: BackupImportType.portableZip,
          backup: archiveData.backup,
          coverFiles: archiveData.coverFiles,
        );

      default:
        throw FormatException(
          'Tiedostomuotoa "$extension" ei tueta. '
          'Valitse JSON- tai ZIP-varmuuskopio.',
        );
    }
  }

  /// Muuntaa JSON-merkkijonon varmuuskopioksi ja tarkistaa
  /// tietojen keskinäisen eheyden.
  ///
  /// Tämä metodi säilytetään myös nykyisiä testejä ja vanhoja
  /// JSON-varmuuskopioita varten.
  LibraryBackup decodeAndValidate(String source) {
    final backup = LibraryBackup.decode(source);

    _validator.validate(backup);

    return backup;
  }

  String _decodeJsonText(Uint8List bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      throw const FormatException(
        'JSON-varmuuskopio ei sisällä kelvollista UTF-8-tekstiä.',
      );
    }
  }
}
