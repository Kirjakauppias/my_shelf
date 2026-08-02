import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/library_backup.dart';
import '../models/portable_backup_manifest.dart';

/// Muodostaa siirrettävän My Shelf -varmuuskopion ZIP-muotoon.
///
/// Palvelu ei käsittele tiedostojärjestelmää eikä avaa jakovalikkoa.
/// Se saa kansikuvat valmiina tavuina, mikä tekee palvelusta helposti
/// yksikkötestattavan.
class PortableBackupArchiveService {
  const PortableBackupArchiveService();

  /// Muodostaa ZIP-arkiston, joka sisältää:
  ///
  /// - manifest.json
  /// - library.json
  /// - covers/-hakemiston
  /// - kirjojen käyttämät paikalliset kansikuvat
  ///
  /// [coverFiles]-mapin avain on kansikuvan tiedostonimi ja arvo kuvan
  /// sisältö tavuina.
  Uint8List encode({
    required LibraryBackup backup,
    required Map<String, Uint8List> coverFiles,
  }) {
    final referencedCoverFileNames = _collectReferencedCoverFileNames(backup);

    _validateRequiredCoverFiles(
      referencedCoverFileNames: referencedCoverFileNames,
      coverFiles: coverFiles,
    );

    final manifest = PortableBackupManifest.create(createdAt: backup.createdAt);

    final archive = Archive()
      ..add(
        ArchiveFile.string(
          PortableBackupManifest.manifestFileName,
          manifest.encode(),
        ),
      )
      ..add(
        ArchiveFile.string(
          PortableBackupManifest.libraryFileName,
          backup.encode(),
        ),
      )
      ..add(
        ArchiveFile.directory('${PortableBackupManifest.coversDirectoryName}/'),
      );

    for (final fileName in referencedCoverFileNames) {
      final bytes = coverFiles[fileName]!;

      if (bytes.isEmpty) {
        throw StateError('Kansikuvatiedosto "$fileName" on tyhjä.');
      }

      archive.add(
        ArchiveFile.bytes(
          '${PortableBackupManifest.coversDirectoryName}/$fileName',
          bytes,
        ),
      );
    }

    return ZipEncoder().encodeBytes(archive);
  }

  /// Kerää varmuuskopion kirjojen käyttämät paikalliset kansikuvat.
  ///
  /// Set estää saman kuvan lisäämisen ZIP-arkistoon useita kertoja.
  /// Lopuksi nimet järjestetään, jotta arkiston sisältö muodostuu
  /// ennustettavassa järjestyksessä.
  List<String> _collectReferencedCoverFileNames(LibraryBackup backup) {
    final fileNames = <String>{};

    for (final book in backup.books) {
      final fileName = book.customCoverFileName;

      if (fileName == null) {
        continue;
      }

      final normalizedFileName = fileName.trim();

      _validateCoverFileName(normalizedFileName, bookTitle: book.title);

      fileNames.add(normalizedFileName);
    }

    return fileNames.toList()..sort();
  }

  /// Estää polkujen ja turvattomien tiedostonimien sijoittamisen arkistoon.
  void _validateCoverFileName(String fileName, {required String bookTitle}) {
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
        'Kirjan "$bookTitle" kansikuvatiedoston nimi on virheellinen: '
        '"$fileName".',
      );
    }
  }

  /// Varmistaa, että jokaiselle JSON-datassa viitatulle kansikuvalle
  /// on annettu myös varsinainen kuvatiedosto.
  void _validateRequiredCoverFiles({
    required List<String> referencedCoverFileNames,
    required Map<String, Uint8List> coverFiles,
  }) {
    final missingFileNames = referencedCoverFileNames
        .where((fileName) => !coverFiles.containsKey(fileName))
        .toList();

    if (missingFileNames.isEmpty) {
      return;
    }

    throw StateError(
      'Varmuuskopiosta puuttuu kansikuvatiedosto: '
      '${missingFileNames.join(', ')}.',
    );
  }
}
