import '../models/book.dart';

enum BookSortOption {
  custom,
  titleAscending,
  titleDescending,
  authorAscending,
  authorDescending,
  ratingDescending,
  ratingAscending,
}

enum ReadingStatusFilter { all, unread, reading, read }

enum BookContentFilter { all, rated, unrated, hasNotes }

extension ReadingStatusFilterExtension on ReadingStatusFilter {
  String get label {
    switch (this) {
      case ReadingStatusFilter.all:
        return 'Kaikki';
      case ReadingStatusFilter.unread:
        return 'Lukematta';
      case ReadingStatusFilter.reading:
        return 'Kesken';
      case ReadingStatusFilter.read:
        return 'Luettu';
    }
  }
}

extension BookContentFilterExtension on BookContentFilter {
  String get label {
    switch (this) {
      case BookContentFilter.all:
        return 'Kaikki';
      case BookContentFilter.rated:
        return 'Arvioidut';
      case BookContentFilter.unrated:
        return 'Arvioimattomat';
      case BookContentFilter.hasNotes:
        return 'Sisältää muistiinpanon';
    }
  }
}

/// Palauttaa valitun hyllyn kirjat haun, suodatusten ja lajittelun jälkeen.
///
/// Alkuperäistä kirjalistaa ei muuteta.
List<Book> queryBooks({
  required Iterable<Book> books,
  required String shelfId,
  String searchQuery = '',
  BookSortOption sortOption = BookSortOption.custom,
  ReadingStatusFilter readingStatusFilter = ReadingStatusFilter.all,
  BookContentFilter contentFilter = BookContentFilter.all,
}) {
  final normalizedQuery = searchQuery.trim().toLowerCase();

  final result = books.where((book) {
    if (book.shelfId != shelfId) {
      return false;
    }

    if (!_matchesReadingStatus(book, readingStatusFilter)) {
      return false;
    }

    if (!_matchesContentFilter(book, contentFilter)) {
      return false;
    }

    if (normalizedQuery.isEmpty) {
      return true;
    }

    final title = book.title.toLowerCase();
    final author = book.author.toLowerCase();
    final isbn = (book.isbn ?? '').toLowerCase();

    return title.contains(normalizedQuery) ||
        author.contains(normalizedQuery) ||
        isbn.contains(normalizedQuery);
  }).toList();

  // Oma järjestys säilyttää alkuperäisen listajärjestyksen.
  //
  // Pelkkää sort((a, b) => 0) -kutsua ei käytetä, koska Dartin
  // lajittelun ei tarvitse säilyttää tasavertaisten alkioiden järjestystä.
  if (sortOption == BookSortOption.custom) {
    return result;
  }

  result.sort((firstBook, secondBook) {
    switch (sortOption) {
      case BookSortOption.custom:
        return 0;

      case BookSortOption.titleAscending:
        return _compareText(firstBook.title, secondBook.title);

      case BookSortOption.titleDescending:
        return _compareText(secondBook.title, firstBook.title);

      case BookSortOption.authorAscending:
        final authorComparison = _compareText(
          firstBook.author,
          secondBook.author,
        );

        return authorComparison != 0
            ? authorComparison
            : _compareText(firstBook.title, secondBook.title);

      case BookSortOption.authorDescending:
        final authorComparison = _compareText(
          secondBook.author,
          firstBook.author,
        );

        return authorComparison != 0
            ? authorComparison
            : _compareText(firstBook.title, secondBook.title);

      case BookSortOption.ratingDescending:
        return _compareRatings(firstBook, secondBook, descending: true);

      case BookSortOption.ratingAscending:
        return _compareRatings(firstBook, secondBook, descending: false);
    }
  });

  return result;
}

bool _matchesReadingStatus(Book book, ReadingStatusFilter filter) {
  switch (filter) {
    case ReadingStatusFilter.all:
      return true;

    case ReadingStatusFilter.unread:
      return book.readingStatus == ReadingStatus.unread;

    case ReadingStatusFilter.reading:
      return book.readingStatus == ReadingStatus.reading;

    case ReadingStatusFilter.read:
      return book.readingStatus == ReadingStatus.read;
  }
}

bool _matchesContentFilter(Book book, BookContentFilter filter) {
  switch (filter) {
    case BookContentFilter.all:
      return true;

    case BookContentFilter.rated:
      return book.rating != null;

    case BookContentFilter.unrated:
      return book.rating == null;

    case BookContentFilter.hasNotes:
      return book.notes.trim().isNotEmpty;
  }
}

int _compareRatings(
  Book firstBook,
  Book secondBook, {
  required bool descending,
}) {
  final firstRating = firstBook.rating;
  final secondRating = secondBook.rating;

  if (firstRating == null && secondRating == null) {
    return _compareText(firstBook.title, secondBook.title);
  }

  // Arvioimattomat kirjat sijoitetaan aina loppuun.
  if (firstRating == null) {
    return 1;
  }

  if (secondRating == null) {
    return -1;
  }

  final ratingComparison = descending
      ? secondRating.compareTo(firstRating)
      : firstRating.compareTo(secondRating);

  if (ratingComparison != 0) {
    return ratingComparison;
  }

  return _compareText(firstBook.title, secondBook.title);
}

int _compareText(String first, String second) {
  return first.toLowerCase().compareTo(second.toLowerCase());
}
