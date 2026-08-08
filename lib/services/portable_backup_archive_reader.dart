import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/library_backup.dart';
import '../models/portable_backup_archive_data.dart';
import '../models/portable_backup_manifest.dart';
import 'library_backup_validator.dart';

/// Lukee ja tarkistaa siirrettävän My Shelf -ZIP-varmuuskopion.
///
/// Palvelu ei kirjoita tiedostoja levylle eikä muuta sovelluksen nykyistä
/// kirjastoa. Kaikki sisältö palautetaan muistissa.
class PortableBackupArchiveReader {
  /// Pakatun ZIP-tiedoston enimmäiskoko.
  static const int maxArchiveSizeBytes = 100 * 1024 * 1024;

  /// Arkiston kaikkien purettujen tiedostojen yhteinen enimmäiskoko.
  static const int maxTotalUncompressedSizeBytes = 250 * 1024 * 1024;

  /// Manifestitiedoston enimmäiskoko.
  static const int maxManifestSizeBytes = 64 * 1024;

  /// Kirjaston JSON-tiedoston enimmäiskoko.
  static const int maxLibrarySizeBytes = 25 * 1024 * 1024;

  /// Yksittäisen kansikuvan enimmäiskoko.
  static const int maxCoverSizeBytes = 25 * 1024 * 1024;

  /// Arkiston tiedostojen ja hakemistojen enimmäismäärä.
  static const int maxEntryCount = 2000;

  final LibraryBackupValidator _validator;

  const PortableBackupArchiveReader({
    LibraryBackupValidator validator = const LibraryBackupValidator(),
  }) : _validator = validator;

  /// Lukee ZIP-arkiston ja palauttaa tarkistetun sisällön.
  PortableBackupArchiveData decode(Uint8List source) {
    if (source.isEmpty) {
      throw const FormatException('Varmuuskopioarkisto on tyhjä.');
    }

    if (source.length > maxArchiveSizeBytes) {
      throw const FormatException('Varmuuskopioarkisto on liian suuri.');
    }

    final archive = _decodeZip(source);

    if (archive.length > maxEntryCount) {
      throw const FormatException(
        'Varmuuskopioarkisto sisältää liian monta tiedostoa.',
      );
    }

    final entriesByName = <String, ArchiveFile>{};
    final coverEntries = <String, ArchiveFile>{};

    var declaredTotalSize = 0;

    for (final entry in archive) {
      _validateArchiveEntryName(entry.name);

      if (entry.isSymbolicLink) {
        throw FormatException(
          'Varmuuskopioarkisto sisältää symbolisen linkin: '
          '"${entry.name}".',
        );
      }

      if (entriesByName.containsKey(entry.name)) {
        throw FormatException(
          'Varmuuskopioarkisto sisältää saman tiedoston useita kertoja: '
          '"${entry.name}".',
        );
      }

      entriesByName[entry.name] = entry;

      if (entry.isDirectory) {
        if (entry.name != '${PortableBackupManifest.coversDirectoryName}/') {
          throw FormatException(
            'Varmuuskopioarkisto sisältää tuntemattoman hakemiston: '
            '"${entry.name}".',
          );
        }

        continue;
      }

      if (!entry.isFile) {
        throw FormatException(
          'Varmuuskopioarkisto sisältää tuntemattoman merkinnän: '
          '"${entry.name}".',
        );
      }

      _validateDeclaredFileSize(entry);

      declaredTotalSize += entry.size;

      if (declaredTotalSize > maxTotalUncompressedSizeBytes) {
        throw const FormatException(
          'Varmuuskopioarkiston purettu sisältö on liian suuri.',
        );
      }

      if (entry.name == PortableBackupManifest.manifestFileName) {
        _validateMaximumSize(
          entry,
          maxSize: maxManifestSizeBytes,
          description: 'Manifesti',
        );
        continue;
      }

      if (entry.name == PortableBackupManifest.libraryFileName) {
        _validateMaximumSize(
          entry,
          maxSize: maxLibrarySizeBytes,
          description: 'Kirjastotiedosto',
        );
        continue;
      }

      final coverFileName = _coverFileNameFromEntry(entry.name);

      _validateCoverFileName(coverFileName);

      _validateMaximumSize(
        entry,
        maxSize: maxCoverSizeBytes,
        description: 'Kansikuvatiedosto "$coverFileName"',
      );

      coverEntries[coverFileName] = entry;
    }

    final manifestEntry =
        entriesByName[PortableBackupManifest.manifestFileName];

    if (manifestEntry == null || !manifestEntry.isFile) {
      throw const FormatException(
        'Varmuuskopioarkistosta puuttuu manifest.json.',
      );
    }

    final libraryEntry = entriesByName[PortableBackupManifest.libraryFileName];

    if (libraryEntry == null || !libraryEntry.isFile) {
      throw const FormatException(
        'Varmuuskopioarkistosta puuttuu library.json.',
      );
    }

    final manifestBytes = _readEntryBytes(
      manifestEntry,
      maxSize: maxManifestSizeBytes,
    );

    final libraryBytes = _readEntryBytes(
      libraryEntry,
      maxSize: maxLibrarySizeBytes,
    );

    final manifest = PortableBackupManifest.decode(
      _decodeUtf8(manifestBytes, description: 'manifest.json'),
    );

    final backup = LibraryBackup.decode(
      _decodeUtf8(libraryBytes, description: 'library.json'),
    );

    _validator.validate(backup);

    if (manifest.createdAt != backup.createdAt) {
      throw const FormatException(
        'Manifestin ja kirjastotiedoston luontiajat eivät vastaa toisiaan.',
      );
    }

    final referencedCoverFileNames = _collectReferencedCoverFileNames(backup);

    final archivedCoverFileNames = coverEntries.keys.toSet();

    final missingCoverFileNames =
        referencedCoverFileNames.difference(archivedCoverFileNames).toList()
          ..sort();

    if (missingCoverFileNames.isNotEmpty) {
      throw FormatException(
        'Varmuuskopioarkistosta puuttuu kansikuvatiedosto: '
        '${missingCoverFileNames.join(', ')}.',
      );
    }

    final unusedCoverFileNames =
        archivedCoverFileNames.difference(referencedCoverFileNames).toList()
          ..sort();

    if (unusedCoverFileNames.isNotEmpty) {
      throw FormatException(
        'Varmuuskopioarkisto sisältää käyttämättömän kansikuvatiedoston: '
        '${unusedCoverFileNames.join(', ')}.',
      );
    }

    final coverFiles = <String, Uint8List>{};
    var actualTotalSize = manifestBytes.length + libraryBytes.length;

    final sortedCoverFileNames = referencedCoverFileNames.toList()..sort();

    for (final fileName in sortedCoverFileNames) {
      final bytes = _readEntryBytes(
        coverEntries[fileName]!,
        maxSize: maxCoverSizeBytes,
      );

      if (bytes.isEmpty) {
        throw FormatException('Kansikuvatiedosto "$fileName" on tyhjä.');
      }

      actualTotalSize += bytes.length;

      if (actualTotalSize > maxTotalUncompressedSizeBytes) {
        throw const FormatException(
          'Varmuuskopioarkiston purettu sisältö on liian suuri.',
        );
      }

      coverFiles[fileName] = bytes;
    }

    return PortableBackupArchiveData(
      manifest: manifest,
      backup: backup,
      coverFiles: coverFiles,
    );
  }

  Archive _decodeZip(Uint8List source) {
    try {
      return ZipDecoder().decodeBytes(source);
    } on Object {
      throw const FormatException(
        'Tiedosto ei ole kelvollinen ZIP-varmuuskopioarkisto.',
      );
    }
  }

  void _validateArchiveEntryName(String name) {
    final hasWindowsDrivePrefix = RegExp(r'^[a-zA-Z]:').hasMatch(name);

    final segments = name.split('/');

    final containsUnsafeSegment = segments.any(
      (segment) => segment == '.' || segment == '..',
    );

    if (name.isEmpty ||
        name.startsWith('/') ||
        name.startsWith(r'\') ||
        name.contains(r'\') ||
        name.contains('\u0000') ||
        hasWindowsDrivePrefix ||
        containsUnsafeSegment) {
      throw FormatException(
        'Varmuuskopioarkisto sisältää turvattoman polun: "$name".',
      );
    }
  }

  void _validateDeclaredFileSize(ArchiveFile entry) {
    if (entry.size < 0) {
      throw FormatException('Tiedoston "${entry.name}" koko on virheellinen.');
    }
  }

  void _validateMaximumSize(
    ArchiveFile entry, {
    required int maxSize,
    required String description,
  }) {
    if (entry.size > maxSize) {
      throw FormatException('$description on liian suuri.');
    }
  }

  String _coverFileNameFromEntry(String entryName) {
    final prefix = '${PortableBackupManifest.coversDirectoryName}/';

    if (!entryName.startsWith(prefix)) {
      throw FormatException(
        'Varmuuskopioarkisto sisältää tuntemattoman tiedoston: '
        '"$entryName".',
      );
    }

    final fileName = entryName.substring(prefix.length);

    if (fileName.isEmpty || fileName.contains('/')) {
      throw FormatException(
        'Kansikuvatiedoston polku on virheellinen: "$entryName".',
      );
    }

    return fileName;
  }

  void _validateCoverFileName(String fileName) {
    final isUnsafe =
        fileName.isEmpty ||
        fileName == '.' ||
        fileName == '..' ||
        fileName.contains('/') ||
        fileName.contains(r'\') ||
        fileName.contains(':') ||
        fileName.contains('\u0000');

    if (isUnsafe) {
      throw FormatException(
        'Kansikuvatiedoston nimi on virheellinen: "$fileName".',
      );
    }
  }

  Uint8List _readEntryBytes(ArchiveFile entry, {required int maxSize}) {
    try {
      final bytes = entry.readBytes();

      if (bytes == null) {
        throw FormatException('Tiedostoa "${entry.name}" ei voitu lukea.');
      }

      if (bytes.length > maxSize) {
        throw FormatException('Tiedosto "${entry.name}" on liian suuri.');
      }

      return Uint8List.fromList(bytes);
    } on FormatException {
      rethrow;
    } on Object {
      throw FormatException('Tiedostoa "${entry.name}" ei voitu purkaa.');
    }
  }

  String _decodeUtf8(Uint8List bytes, {required String description}) {
    try {
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      throw FormatException(
        'Tiedosto $description ei sisällä kelvollista UTF-8-tekstiä.',
      );
    }
  }

  Set<String> _collectReferencedCoverFileNames(LibraryBackup backup) {
    final fileNames = <String>{};

    for (final book in backup.books) {
      final storedFileName = book.customCoverFileName;

      if (storedFileName == null) {
        continue;
      }

      final fileName = storedFileName.trim();

      _validateCoverFileName(fileName);

      fileNames.add(fileName);
    }

    return fileNames;
  }
}
