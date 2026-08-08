import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import '../models/book.dart';
import '../models/library_backup.dart';
import '../models/shelf.dart';
import 'custom_cover_service.dart';
import 'portable_backup_archive_service.dart';

/// Kansikuvatiedoston lataamiseen käytettävä funktio.
///
/// Erillinen funktiotyyppi mahdollistaa tiedostonlatauksen korvaamisen
/// yksikkötesteissä ilman oikeaa sovellushakemistoa.
typedef CoverFileLoader = Future<File?> Function(String fileName);

/// Varmuuskopion vientitoiminnon lopputulos.
enum BackupExportOutcome {
  /// Käyttäjä valitsi jakovalikosta jonkin toiminnon.
  shared,

  /// Käyttäjä sulki jakovalikon tekemättä valintaa.
  dismissed,

  /// Alusta ei pystynyt ilmoittamaan käyttäjän tekemää valintaa.
  statusUnavailable,
}

/// Muodostaa ja jakaa My Shelf -varmuuskopioita.
///
/// Nykyinen [exportBackup] säilyttää vanhan JSON-viennin.
///
/// [exportPortableBackup] muodostaa uuden ZIP-varmuuskopion, joka sisältää
/// kirjaston JSON-datan sekä kirjojen käyttämät paikalliset kansikuvat.
class BackupExportService {
  final PortableBackupArchiveService _portableArchiveService;
  final CoverFileLoader? _coverFileLoader;

  const BackupExportService({
    PortableBackupArchiveService portableArchiveService =
        const PortableBackupArchiveService(),
    CoverFileLoader? coverFileLoader,
  }) : _portableArchiveService = portableArchiveService,
       _coverFileLoader = coverFileLoader;

  /// Muodostaa kirjaston vanhan JSON-varmuuskopion ja avaa jakovalikon.
  ///
  /// Tämä toiminto säilytetään toistaiseksi yhteensopivuutta varten.
  Future<BackupExportOutcome> exportBackup({
    required List<Book> books,
    required List<Shelf> shelves,
    Rect? sharePositionOrigin,
  }) async {
    final backup = LibraryBackup.create(books: books, shelves: shelves);

    final jsonText = backup.encode();

    final jsonBytes = Uint8List.fromList(utf8.encode(jsonText));

    final fileName = _buildFileName(
      createdAt: backup.createdAt.toLocal(),
      extension: 'json',
    );

    final result = await SharePlus.instance.share(
      ShareParams(
        title: 'My Shelf -varmuuskopio',
        subject: 'My Shelf -varmuuskopio',
        text: 'My Shelf -kirjaston JSON-varmuuskopio.',
        files: [XFile.fromData(jsonBytes, mimeType: 'application/json')],
        fileNameOverrides: [fileName],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );

    return _mapShareResult(result);
  }

  /// Muodostaa kansikuvat sisältävän ZIP-varmuuskopion ja avaa jakovalikon.
  ///
  /// Tätä ei vielä yhdistetä sovelluksen käyttöliittymään ennen kuin
  /// ZIP-varmuuskopion palautus on valmis.
  Future<BackupExportOutcome> exportPortableBackup({
    required List<Book> books,
    required List<Shelf> shelves,
    Rect? sharePositionOrigin,
  }) async {
    final backup = LibraryBackup.create(books: books, shelves: shelves);

    final zipBytes = await _encodePortableBackup(backup);

    final fileName = _buildFileName(
      createdAt: backup.createdAt.toLocal(),
      extension: 'zip',
    );

    final result = await SharePlus.instance.share(
      ShareParams(
        title: 'My Shelf -varmuuskopio',
        subject: 'My Shelf -varmuuskopio',
        text: 'My Shelf -kirjaston kansikuvat sisältävä varmuuskopio.',
        files: [XFile.fromData(zipBytes, mimeType: 'application/zip')],
        fileNameOverrides: [fileName],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );

    return _mapShareResult(result);
  }

  /// Muodostaa ZIP-varmuuskopion tavut avaamatta jakovalikkoa.
  ///
  /// Julkinen metodi tekee ZIP-viennistä yksikkötestattavan.
  Future<Uint8List> buildPortableBackupArchive({
    required List<Book> books,
    required List<Shelf> shelves,
  }) async {
    final backup = LibraryBackup.create(books: books, shelves: shelves);

    return _encodePortableBackup(backup);
  }

  Future<Uint8List> _encodePortableBackup(LibraryBackup backup) async {
    final coverFiles = await _loadReferencedCoverFiles(backup);

    return _portableArchiveService.encode(
      backup: backup,
      coverFiles: coverFiles,
    );
  }

  /// Lukee kaikki kirjaston käyttämät paikalliset kansikuvat.
  ///
  /// Sama tiedosto luetaan vain kerran, vaikka useampi kirja viittaisi siihen.
  Future<Map<String, Uint8List>> _loadReferencedCoverFiles(
    LibraryBackup backup,
  ) async {
    final coverFiles = <String, Uint8List>{};

    final loader = _coverFileLoader ?? CustomCoverService().getCoverFile;

    for (final book in backup.books) {
      final storedFileName = book.customCoverFileName;

      if (storedFileName == null) {
        continue;
      }

      final fileName = storedFileName.trim();

      if (fileName.isEmpty || coverFiles.containsKey(fileName)) {
        continue;
      }

      final file = await loader(fileName);

      if (file == null || !await file.exists()) {
        throw StateError(
          'Kirjan "${book.title}" kansikuvatiedostoa '
          '"$fileName" ei löydy.',
        );
      }

      coverFiles[fileName] = await file.readAsBytes();
    }

    return coverFiles;
  }

  BackupExportOutcome _mapShareResult(ShareResult result) {
    switch (result.status) {
      case ShareResultStatus.success:
        return BackupExportOutcome.shared;

      case ShareResultStatus.dismissed:
        return BackupExportOutcome.dismissed;

      case ShareResultStatus.unavailable:
        return BackupExportOutcome.statusUnavailable;
    }
  }

  String _buildFileName({
    required DateTime createdAt,
    required String extension,
  }) {
    final year = createdAt.year.toString();
    final month = _twoDigits(createdAt.month);
    final day = _twoDigits(createdAt.day);
    final hour = _twoDigits(createdAt.hour);
    final minute = _twoDigits(createdAt.minute);
    final second = _twoDigits(createdAt.second);

    return 'my_shelf_backup_'
        '$year-$month-${day}_'
        '$hour-$minute-$second.'
        '$extension';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
