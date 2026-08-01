enum BookViewMode { covers, spines }

class LibraryViewSettings {
  final BookViewMode bookViewMode;
  final bool showReadingStatusBadges;

  const LibraryViewSettings({
    this.bookViewMode = BookViewMode.covers,
    this.showReadingStatusBadges = false,
  });

  factory LibraryViewSettings.fromStoredValues({
    String? bookViewModeName,
    bool? showReadingStatusBadges,
  }) {
    final bookViewMode = BookViewMode.values.firstWhere(
      (mode) => mode.name == bookViewModeName,
      orElse: () => BookViewMode.covers,
    );

    return LibraryViewSettings(
      bookViewMode: bookViewMode,
      showReadingStatusBadges: showReadingStatusBadges ?? false,
    );
  }
}
