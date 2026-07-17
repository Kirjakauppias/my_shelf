import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/shelf.dart';

class ShelfStorageService {
  static const String _shelvesKey = 'shelves';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  /// Tallentaa kaikki kirjahyllyt nykyisessä järjestyksessä.
  Future<void> saveShelves(List<Shelf> shelves) async {
    final shelvesAsJson = shelves.map((shelf) => shelf.toJson()).toList();

    final encodedShelves = jsonEncode(shelvesAsJson);

    await _preferences.setString(_shelvesKey, encodedShelves);
  }

  /// Lataa tallennetut kirjahyllyt.
  ///
  /// Jos hyllyjä ei ole vielä tallennettu, palautetaan tyhjä lista.
  Future<List<Shelf>> loadShelves() async {
    final encodedShelves = await _preferences.getString(_shelvesKey);

    if (encodedShelves == null || encodedShelves.isEmpty) {
      return [];
    }

    try {
      final decodedShelves = jsonDecode(encodedShelves) as List<dynamic>;

      return decodedShelves
          .map((item) => Shelf.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on FormatException {
      return [];
    }
  }
}
