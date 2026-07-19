import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import '../models/book.dart';
import '../models/library_backup.dart';
import '../models/shelf.dart';

/// Varmuuskopion vientitoiminnon lopputulos.
enum BackupExportOutcome {
  /// Käyttäjä valitsi jakovalikosta jonkin toiminnon.
  shared,

  /// Käyttäjä sulki jakovalikon tekemättä valintaa.
  dismissed,

  /// Alusta ei pystynyt ilmoittamaan käyttäjän tekemää valintaa.
  statusUnavailable,
}

/// Muodostaa kirjaston JSON-varmuuskopion ja avaa laitteen jakovalikon.
class BackupExportService {
  const BackupExportService();

  Future<BackupExportOutcome> exportBackup({
    required List<Book> books,
    required List<Shelf> shelves,
    Rect? sharePositionOrigin,
  }) async {
    final backup = LibraryBackup.create(books: books, shelves: shelves);

    final jsonText = backup.encode();

    final jsonBytes = Uint8List.fromList(utf8.encode(jsonText));

    final fileName = _buildFileName(backup.createdAt.toLocal());

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

    switch (result.status) {
      case ShareResultStatus.success:
        return BackupExportOutcome.shared;

      case ShareResultStatus.dismissed:
        return BackupExportOutcome.dismissed;

      case ShareResultStatus.unavailable:
        return BackupExportOutcome.statusUnavailable;
    }
  }

  String _buildFileName(DateTime createdAt) {
    final year = createdAt.year.toString();
    final month = _twoDigits(createdAt.month);
    final day = _twoDigits(createdAt.day);
    final hour = _twoDigits(createdAt.hour);
    final minute = _twoDigits(createdAt.minute);
    final second = _twoDigits(createdAt.second);

    return 'my_shelf_backup_'
        '$year-$month-${day}_'
        '$hour-$minute-$second.json';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
