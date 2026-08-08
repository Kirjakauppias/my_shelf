import 'dart:convert';

/// Kuvaa kansikuvat sisältävän siirrettävän varmuuskopioarkiston.
///
/// Tämä versiointi koskee ZIP-arkiston rakennetta, ei kirjaston
/// [LibraryBackup]-JSON-rakennetta.
class PortableBackupManifest {
  /// Tunniste, jolla My Shelf -varmuuskopio erotetaan muista ZIP-tiedostoista.
  static const String formatIdentifier = 'my-shelf-portable-backup';

  /// Tällä hetkellä tuettu ZIP-arkiston rakennemuoto.
  static const int currentArchiveVersion = 1;

  /// Manifestitiedoston nimi ZIP-arkistossa.
  static const String manifestFileName = 'manifest.json';

  /// Kirjaston JSON-tiedoston nimi ZIP-arkistossa.
  static const String libraryFileName = 'library.json';

  /// Kansikuvahakemiston nimi ZIP-arkistossa.
  static const String coversDirectoryName = 'covers';

  /// ZIP-arkiston rakenteen versionumero.
  final int archiveVersion;

  /// Arkiston luontiaika UTC-muodossa.
  final DateTime createdAt;

  PortableBackupManifest({
    required this.archiveVersion,
    required this.createdAt,
  });

  /// Luo manifestin uuden siirrettävän varmuuskopion vientiä varten.
  factory PortableBackupManifest.create({DateTime? createdAt}) {
    return PortableBackupManifest(
      archiveVersion: currentArchiveVersion,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
    );
  }

  /// Muuntaa manifestin JSON-rakenteeksi.
  Map<String, dynamic> toJson() {
    return {
      'format': formatIdentifier,
      'archiveVersion': archiveVersion,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Muuntaa manifestin JSON-merkkijonoksi.
  String encode({bool pretty = true}) {
    final encoder = pretty
        ? const JsonEncoder.withIndent('  ')
        : const JsonEncoder();

    return encoder.convert(toJson());
  }

  /// Muodostaa manifestin JSON-merkkijonosta.
  factory PortableBackupManifest.decode(String source) {
    final decodedValue = jsonDecode(source);

    if (decodedValue is! Map) {
      throw const FormatException(
        'Varmuuskopioarkiston manifestin täytyy olla JSON-olio.',
      );
    }

    return PortableBackupManifest.fromJson(
      Map<String, dynamic>.from(decodedValue),
    );
  }

  /// Muodostaa manifestin JSON-rakenteesta.
  factory PortableBackupManifest.fromJson(Map<String, dynamic> json) {
    final formatValue = json['format'];

    if (formatValue != formatIdentifier) {
      throw const FormatException(
        'Tiedosto ei ole My Shelf -varmuuskopioarkisto.',
      );
    }

    final archiveVersionValue = json['archiveVersion'];

    if (archiveVersionValue is! int) {
      throw const FormatException(
        'Manifestista puuttuu kelvollinen archiveVersion.',
      );
    }

    if (archiveVersionValue != currentArchiveVersion) {
      throw FormatException(
        'Varmuuskopioarkiston versiota '
        '$archiveVersionValue ei tueta.',
      );
    }

    final createdAtValue = json['createdAt'];

    if (createdAtValue is! String) {
      throw const FormatException(
        'Manifestista puuttuu kelvollinen createdAt.',
      );
    }

    try {
      return PortableBackupManifest(
        archiveVersion: archiveVersionValue,
        createdAt: DateTime.parse(createdAtValue).toUtc(),
      );
    } on FormatException {
      throw const FormatException(
        'Manifestin createdAt-aikaleima on virheellinen.',
      );
    }
  }
}
