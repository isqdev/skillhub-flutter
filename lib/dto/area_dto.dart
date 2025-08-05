class AreaDto {
  final int? id;
  final String name;
  final String description;

  const AreaDto({
    this.id,
    required this.name,
    required this.description,
  });

  // Construtor para criar a partir de JSON
  factory AreaDto.fromJson(Map<String, dynamic> json) {
    return AreaDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Métodos para SQLite (mobile)
  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory AreaDto.fromMap(Map<String, dynamic> map) {
    return AreaDto.fromJson(map);
  }

  // Método para criar uma cópia com modificações
  AreaDto copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return AreaDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'AreaDto(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AreaDto &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ description.hashCode;
  }
}
