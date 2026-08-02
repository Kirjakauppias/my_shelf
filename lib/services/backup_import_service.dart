import 'package:file_selector/file_selector.dart';

import '../models/library_backup.dart';
import 'library_backup_validator.dart';

/// Sisältää käyttäjän valitseman varmuuskopiotiedoston tiedot.
class BackupImportSelection {
  final String fileName;
  final LibraryBackup backup;

  const BackupImportSelection({required this.fileName, required this.backup});
}

/// Valitsee, lukee ja tarkistaa JSON-varmuuskopion.
class BackupImportService {
  final LibraryBackupValidator _validator;

  const BackupImportService({
    LibraryBackupValidator validator = const LibraryBackupValidator(),
  }) : _validator = validator;

  static const XTypeGroup _jsonTypeGroup = XTypeGroup(
    label: 'My Shelf JSON-varmuuskopio',
    extensions: <String>['json'],
    mimeTypes: <String>['application/json'],
    uniformTypeIdentifiers: <String>['public.json'],
  );

  /// Avaa tiedostonvalitsimen.
  ///
  /// Palauttaa null-arvon, jos käyttäjä peruuttaa valinnan.
  Future<BackupImportSelection?> pickBackup() async {
    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_jsonTypeGroup],
      confirmButtonText: 'Valitse varmuuskopio',
    );

    if (file == null) {
      return null;
    }

    final source = await file.readAsString();
    final backup = decodeAndValidate(source);

    return BackupImportSelection(fileName: file.name, backup: backup);
  }

  /// Muuntaa JSON-merkkijonon varmuuskopioksi ja tarkistaa
  /// tietojen keskinäisen eheyden.
  LibraryBackup decodeAndValidate(String source) {
    final backup = LibraryBackup.decode(source);

    _validator.validate(backup);

    return backup;
  }
}
