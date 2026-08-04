/// Kirjatietoja palauttava tietolähde.
enum BookDataSource { finna, googleBooks, openLibrary }

/// Yhden kirjatietopalvelun palauttamat tiedot.
///
/// Kentät ovat tarkoituksella valinnaisia. Näin yhden palvelun
/// puuttuvat tiedot voidaan täydentää toisesta palvelusta ilman
/// keinotekoisia oletusarvoja.
class BookSearchResult {
  final BookDataSource source;
  final String isbn;
  final String? title;
  final String? author;
  final int? pageCount;
  final String? coverUrl;

  const BookSearchResult({
    required this.source,
    required this.isbn,
    this.title,
    this.author,
    this.pageCount,
    this.coverUrl,
  });

  /// Kertoo, sisältääkö tulos mitään käyttökelpoista kirjatietoa.
  bool get hasAnyData {
    return title != null ||
        author != null ||
        pageCount != null ||
        coverUrl != null;
  }
}
