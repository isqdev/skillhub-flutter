class EventDto {
  final int? id;
  final String name;
  final String institution;
  final String description;
  final List<String> tags;

  const EventDto({
    this.id,
    required this.name,
    required this.institution,
    required this.description,
    required this.tags,
  });

  // Construtor para criar a partir de JSON
  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      institution: json['institution'] as String,
      description: json['description'] as String,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'institution': institution,
      'description': description,
      'tags': tags,
    };
  }

  // Método para criar uma cópia com modificações
  EventDto copyWith({
    int? id,
    String? name,
    String? institution,
    String? description,
    List<String>? tags,
  }) {
    return EventDto(
      id: id ?? this.id,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }

  // Helper para converter tags de string separada por vírgula
  factory EventDto.fromTagsString(String tagsString) {
    final tagsList = tagsString.split(',').map((tag) => tag.trim()).toList();
    return EventDto(
      name: '',
      institution: '',
      description: '',
      tags: tagsList,
    );
  }

  // Helper para converter tags para string separada por vírgula
  String get tagsAsString => tags.join(', ');

  @override
  String toString() {
    return 'EventDto(id: $id, name: $name, institution: $institution, description: $description, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventDto &&
        other.id == id &&
        other.name == name &&
        other.institution == institution &&
        other.description == description &&
        _listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           name.hashCode ^ 
           institution.hashCode ^ 
           description.hashCode ^ 
           tags.hashCode;
  }

  // Helper para comparar listas
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
