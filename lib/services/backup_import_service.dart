import 'package:file_selector/file_selector.dart';

import '../models/library_backup.dart';

/// Sisältää käyttäjän valitseman varmuuskopiotiedoston tiedot.
class BackupImportSelection {
  final String fileName;
  final LibraryBackup backup;

  const BackupImportSelection({required this.fileName, required this.backup});
}

/// Valitsee, lukee ja tarkistaa JSON-varmuuskopion.
class BackupImportService {
  const BackupImportService();

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

    _validateBackup(backup);

    return backup;
  }

  void _validateBackup(LibraryBackup backup) {
    if (backup.shelves.isEmpty) {
      throw const FormatException(
        'Varmuuskopiossa täytyy olla vähintään yksi kirjahylly.',
      );
    }

    final shelfIds = <String>{};

    for (final shelf in backup.shelves) {
      if (shelf.id.trim().isEmpty) {
        throw const FormatException(
          'Varmuuskopio sisältää kirjahyllyn ilman tunnistetta.',
        );
      }

      if (!shelfIds.add(shelf.id)) {
        throw FormatException(
          'Varmuuskopio sisältää saman kirjahyllyn useita kertoja: '
          '${shelf.id}',
        );
      }
    }

    final bookIds = <String>{};

    for (final book in backup.books) {
      if (book.id.trim().isEmpty) {
        throw const FormatException(
          'Varmuuskopio sisältää kirjan ilman tunnistetta.',
        );
      }

      if (!bookIds.add(book.id)) {
        throw FormatException(
          'Varmuuskopio sisältää saman kirjan useita kertoja: '
          '${book.id}',
        );
      }

      if (!shelfIds.contains(book.shelfId)) {
        throw FormatException(
          'Kirjan "${book.title}" kirjahyllyä ei löydy varmuuskopiosta.',
        );
      }
    }
  }
}
