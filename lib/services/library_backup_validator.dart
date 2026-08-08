import '../models/library_backup.dart';

/// Tarkistaa kirjaston varmuuskopion tietojen keskinäisen eheyden.
class LibraryBackupValidator {
  const LibraryBackupValidator();

  void validate(LibraryBackup backup) {
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
