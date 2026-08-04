class BookApiException implements Exception {
  final String message;

  const BookApiException(this.message);

  @override
  String toString() => message;
}
