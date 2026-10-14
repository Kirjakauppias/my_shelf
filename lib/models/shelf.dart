/// Kirjahyllyn käytettävissä olevat ulkoasuteemat.
enum ShelfTheme { classic, light, oak, walnut, dark, gray }

/// Yksittäistä kirjahyllyä kuvaava tietomalli.
class Shelf {
  final String id;
  final String name;
  final int position;

  /// Kirjahyllyn visuaalinen teema.
  ///
  /// Vanhoille hyllyille, joilla tätä tietoa ei vielä ole,
  /// käytetään oletuksena classic-teemaa.
  final ShelfTheme theme;

  const Shelf({
    required this.id,
    required this.name,
    required this.position,
    this.theme = ShelfTheme.classic,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'position': position, 'theme': theme.name};
  }

  factory Shelf.fromJson(Map<String, dynamic> json) {
    final themeValue = json['theme'];

    final theme = themeValue is String
        ? ShelfTheme.values.firstWhere(
            (value) => value.name == themeValue,
            orElse: () => ShelfTheme.classic,
          )
        : ShelfTheme.classic;

    return Shelf(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as int? ?? 0,
      theme: theme,
    );
  }

  Shelf copyWith({String? id, String? name, int? position, ShelfTheme? theme}) {
    return Shelf(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      theme: theme ?? this.theme,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Shelf && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
