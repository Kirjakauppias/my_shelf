import 'book_binding.dart';

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
  final int? publicationYear;
  final String? publisher;
  final BookBinding? binding;

  const BookSearchResult({
    required this.source,
    required this.isbn,
    this.title,
    this.author,
    this.pageCount,
    this.publicationYear,
    this.publisher,
    this.binding,
    this.coverUrl,
  });

  /// Kertoo, sisältääkö tulos mitään käyttökelpoista kirjatietoa.
  bool get hasAnyData {
    return title != null ||
        author != null ||
        pageCount != null ||
        publicationYear != null ||
        publisher != null ||
        binding != null ||
        coverUrl != null;
  }

  /// Luo saman hakutuloksen ilman kansikuvaa.
  BookSearchResult withoutCover() {
    return BookSearchResult(
      source: source,
      isbn: isbn,
      title: title,
      author: author,
      pageCount: pageCount,
      publicationYear: publicationYear,
      publisher: publisher,
      binding: binding,
    );
  }
}
