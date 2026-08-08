import 'package:shared_preferences/shared_preferences.dart';

import '../models/library_view_settings.dart';

class LibraryViewSettingsService {
  static const String _bookViewModeKey = 'library_book_view_mode';

  static const String _showReadingStatusBadgesKey =
      'library_show_reading_status_badges';

  final SharedPreferencesAsync _preferences;

  LibraryViewSettingsService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  Future<LibraryViewSettings> loadSettings() async {
    final bookViewModeName = await _preferences.getString(_bookViewModeKey);

    final showReadingStatusBadges = await _preferences.getBool(
      _showReadingStatusBadgesKey,
    );

    return LibraryViewSettings.fromStoredValues(
      bookViewModeName: bookViewModeName,
      showReadingStatusBadges: showReadingStatusBadges,
    );
  }

  Future<void> saveBookViewMode(BookViewMode bookViewMode) async {
    await _preferences.setString(_bookViewModeKey, bookViewMode.name);
  }

  Future<void> saveShowReadingStatusBadges(bool showReadingStatusBadges) async {
    await _preferences.setBool(
      _showReadingStatusBadgesKey,
      showReadingStatusBadges,
    );
  }
}
