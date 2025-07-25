class TagDto {
  final int? id;
  final String name;

  const TagDto({
    this.id,
    required this.name,
  });

  // Construtor para criar a partir de JSON
  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: json['id'] as int?,
      name: json['name'] as String,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Método para criar uma cópia com modificações
  TagDto copyWith({
    int? id,
    String? name,
  }) {
    return TagDto(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'TagDto(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagDto &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}
