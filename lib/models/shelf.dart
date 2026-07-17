class Shelf {
  final String id;
  final String name;
  final int position;

  const Shelf({required this.id, required this.name, required this.position});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'position': position};
  }

  factory Shelf.fromJson(Map<String, dynamic> json) {
    return Shelf(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as int? ?? 0,
    );
  }

  Shelf copyWith({String? id, String? name, int? position}) {
    return Shelf(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Shelf && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
