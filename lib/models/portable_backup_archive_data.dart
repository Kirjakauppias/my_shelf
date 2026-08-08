import 'dart:collection';
import 'dart:typed_data';

import 'library_backup.dart';
import 'portable_backup_manifest.dart';

/// Sisältää turvallisesti luetun siirrettävän varmuuskopion tiedot.
///
/// Tässä vaiheessa tiedot ovat vain muistissa. Kansikuvia ei ole vielä
/// kirjoitettu sovelluksen omaan tallennushakemistoon.
class PortableBackupArchiveData {
  final PortableBackupManifest manifest;
  final LibraryBackup backup;
  final Map<String, Uint8List> coverFiles;

  PortableBackupArchiveData({
    required this.manifest,
    required this.backup,
    required Map<String, Uint8List> coverFiles,
  }) : coverFiles = UnmodifiableMapView(<String, Uint8List>{
         for (final entry in coverFiles.entries)
           entry.key: Uint8List.fromList(entry.value),
       });
}
