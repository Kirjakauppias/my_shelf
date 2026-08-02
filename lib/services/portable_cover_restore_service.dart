import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Palautettavien kansikuvien hakemiston tarjoava funktio.
///
/// Erillinen funktiotyyppi mahdollistaa väliaikaisen testihakemiston
/// käyttämisen yksikkötesteissä.
typedef CoversDirectoryProvider = Future<Directory> Function();

/// Palauttaa sovelluksen normaalin paikallisten kansikuvien hakemiston.
Future<Directory> _defaultCoversDirectoryProvider() async {
  final documentsDirectory = await getApplicationDocumentsDirectory();

  return Directory(path.join(documentsDirectory.path, 'covers'));
}

/// Valmistelee ja ottaa käyttöön ZIP-varmuuskopiosta palautettavat kansikuvat.
///
/// Palautus jää odottavaan tilaan, kunnes kutsuja suorittaa joko:
///
/// - [PortableCoverRestoreTransaction.commit]
/// - [PortableCoverRestoreTransaction.rollback]
class PortableCoverRestoreService {
  final CoversDirectoryProvider _coversDirectoryProvider;

  PortableCoverRestoreService({
    CoversDirectoryProvider? coversDirectoryProvider,
  }) : _coversDirectoryProvider =
           coversDirectoryProvider ?? _defaultCoversDirectoryProvider;

  /// Kirjoittaa palautettavat kansikuvat turvallisesti käyttöhakemistoon.
  ///
  /// Palauttaa transaktion, joka täytyy joko vahvistaa tai perua.
  Future<PortableCoverRestoreTransaction> beginRestore({
    required Map<String, Uint8List> coverFiles,
  }) async {
    final orderedFileNames = coverFiles.keys.toList()..sort();

    // Kaikki nimet ja sisällöt tarkistetaan ennen kuin tiedostojärjestelmää
    // muutetaan.
    for (final fileName in orderedFileNames) {
      _validateFileName(fileName);

      final bytes = coverFiles[fileName]!;

      if (bytes.isEmpty) {
        throw FormatException('Kansikuvatiedosto "$fileName" on tyhjä.');
      }
    }

    final coversDirectory = await _coversDirectoryProvider();
    await coversDirectory.create(recursive: true);

    final workingDirectories = await _createWorkingDirectories(coversDirectory);

    final stagingDirectory = workingDirectories.staging;
    final backupDirectory = workingDirectories.backup;

    final restoredFileNames = <String>{};
    final backedUpFileNames = <String>{};

    try {
      // Kirjoitetaan kaikki tiedostot ensin valmisteluhakemistoon.
      for (final fileName in orderedFileNames) {
        final stagingFile = File(path.join(stagingDirectory.path, fileName));

        await stagingFile.writeAsBytes(coverFiles[fileName]!, flush: true);
      }

      // Otetaan tiedostot käyttöön vasta, kun kaikki kuvat on kirjoitettu
      // onnistuneesti valmisteluhakemistoon.
      for (final fileName in orderedFileNames) {
        final targetFile = File(path.join(coversDirectory.path, fileName));

        if (await targetFile.exists()) {
          final backupFilePath = path.join(backupDirectory.path, fileName);

          await targetFile.rename(backupFilePath);
          backedUpFileNames.add(fileName);
        }

        final stagingFile = File(path.join(stagingDirectory.path, fileName));

        await stagingFile.rename(targetFile.path);
        restoredFileNames.add(fileName);
      }

      return PortableCoverRestoreTransaction._(
        coversDirectory: coversDirectory,
        stagingDirectory: stagingDirectory,
        backupDirectory: backupDirectory,
        restoredFileNames: restoredFileNames,
        backedUpFileNames: backedUpFileNames,
      );
    } on Object {
      await _rollbackFailedRestore(
        coversDirectory: coversDirectory,
        stagingDirectory: stagingDirectory,
        backupDirectory: backupDirectory,
        restoredFileNames: restoredFileNames,
        backedUpFileNames: backedUpFileNames,
      );

      rethrow;
    }
  }

  void _validateFileName(String fileName) {
    final trimmedFileName = fileName.trim();

    final hasWindowsDrivePrefix = RegExp(r'^[a-zA-Z]:').hasMatch(fileName);

    final baseNameWithoutExtension = path
        .basenameWithoutExtension(fileName)
        .toUpperCase();

    final reservedWindowsNames = <String>{
      'CON',
      'PRN',
      'AUX',
      'NUL',
      'COM1',
      'COM2',
      'COM3',
      'COM4',
      'COM5',
      'COM6',
      'COM7',
      'COM8',
      'COM9',
      'LPT1',
      'LPT2',
      'LPT3',
      'LPT4',
      'LPT5',
      'LPT6',
      'LPT7',
      'LPT8',
      'LPT9',
    };

    final isUnsafe =
        fileName.isEmpty ||
        fileName != trimmedFileName ||
        fileName == '.' ||
        fileName == '..' ||
        fileName.endsWith('.') ||
        fileName.contains('/') ||
        fileName.contains(r'\') ||
        fileName.contains(':') ||
        fileName.contains('\u0000') ||
        hasWindowsDrivePrefix ||
        reservedWindowsNames.contains(baseNameWithoutExtension);

    if (isUnsafe) {
      throw FormatException(
        'Kansikuvatiedoston nimi on virheellinen: "$fileName".',
      );
    }
  }

  Future<_RestoreWorkingDirectories> _createWorkingDirectories(
    Directory coversDirectory,
  ) async {
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    for (var attempt = 0; attempt < 100; attempt += 1) {
      final identifier = '${timestamp}_$attempt';

      final stagingDirectory = Directory(
        path.join(coversDirectory.path, '.restore_stage_$identifier'),
      );

      final backupDirectory = Directory(
        path.join(coversDirectory.path, '.restore_backup_$identifier'),
      );

      if (await stagingDirectory.exists() || await backupDirectory.exists()) {
        continue;
      }

      await stagingDirectory.create();
      await backupDirectory.create();

      return _RestoreWorkingDirectories(
        staging: stagingDirectory,
        backup: backupDirectory,
      );
    }

    throw StateError(
      'Kansikuvien palautuksen väliaikaishakemistoa ei voitu luoda.',
    );
  }

  Future<void> _rollbackFailedRestore({
    required Directory coversDirectory,
    required Directory stagingDirectory,
    required Directory backupDirectory,
    required Set<String> restoredFileNames,
    required Set<String> backedUpFileNames,
  }) async {
    for (final fileName in restoredFileNames.toList().reversed) {
      final targetFile = File(path.join(coversDirectory.path, fileName));

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
    }

    for (final fileName in backedUpFileNames.toList().reversed) {
      final backupFile = File(path.join(backupDirectory.path, fileName));

      if (await backupFile.exists()) {
        await backupFile.rename(path.join(coversDirectory.path, fileName));
      }
    }

    await _deleteDirectoryIfExists(stagingDirectory);
    await _deleteDirectoryIfExists(backupDirectory);
  }

  Future<void> _deleteDirectoryIfExists(Directory directory) async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

/// Odottava kansikuvien palautustapahtuma.
///
/// Kutsujan täytyy vahvistaa tapahtuma vasta kirjastotietojen tallennuksen
/// onnistuttua. Tallennusvirheessä tapahtuma voidaan perua.
class PortableCoverRestoreTransaction {
  final Directory _coversDirectory;
  final Directory _stagingDirectory;
  final Directory _backupDirectory;
  final Set<String> _restoredFileNames;
  final Set<String> _backedUpFileNames;

  bool _isActive = true;

  PortableCoverRestoreTransaction._({
    required Directory coversDirectory,
    required Directory stagingDirectory,
    required Directory backupDirectory,
    required Set<String> restoredFileNames,
    required Set<String> backedUpFileNames,
  }) : _coversDirectory = coversDirectory,
       _stagingDirectory = stagingDirectory,
       _backupDirectory = backupDirectory,
       _restoredFileNames = Set.unmodifiable(restoredFileNames),
       _backedUpFileNames = Set.unmodifiable(backedUpFileNames);

  /// Kertoo, odottaako tapahtuma vielä vahvistamista tai perumista.
  bool get isActive => _isActive;

  /// Palautuksessa käyttöön otettujen tiedostojen nimet.
  Set<String> get restoredFileNames => _restoredFileNames;

  /// Vahvistaa palautuksen ja poistaa vanhojen tiedostojen varakopiot.
  Future<void> commit() async {
    _ensureActive();

    await _deleteDirectoryIfExists(_stagingDirectory);
    await _deleteDirectoryIfExists(_backupDirectory);

    _isActive = false;
  }

  /// Peruu palautuksen.
  ///
  /// Uudet kuvat poistetaan ja aiemmat samannimiset kuvat palautetaan.
  Future<void> rollback() async {
    _ensureActive();

    for (final fileName in _restoredFileNames.toList().reversed) {
      final targetFile = File(path.join(_coversDirectory.path, fileName));

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
    }

    for (final fileName in _backedUpFileNames.toList().reversed) {
      final backupFile = File(path.join(_backupDirectory.path, fileName));

      if (!await backupFile.exists()) {
        continue;
      }

      final targetFile = File(path.join(_coversDirectory.path, fileName));

      if (await targetFile.exists()) {
        await targetFile.delete();
      }

      await backupFile.rename(targetFile.path);
    }

    await _deleteDirectoryIfExists(_stagingDirectory);
    await _deleteDirectoryIfExists(_backupDirectory);

    _isActive = false;
  }

  void _ensureActive() {
    if (!_isActive) {
      throw StateError('Kansikuvien palautustapahtuma ei ole enää aktiivinen.');
    }
  }

  Future<void> _deleteDirectoryIfExists(Directory directory) async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

class _RestoreWorkingDirectories {
  final Directory staging;
  final Directory backup;

  const _RestoreWorkingDirectories({
    required this.staging,
    required this.backup,
  });
}
