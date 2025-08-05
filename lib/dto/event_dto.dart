import 'package:flutter/foundation.dart' show listEquals;

class EventDto {
  final int? id;
  final String name;
  final String institution;
  final String description;
  final String profession;
  final List<String> tags;

  const EventDto({
    this.id,
    required this.name,
    required this.institution,
    required this.description,
    required this.profession,
    this.tags = const [],
  });

  // Construtor para criar a partir de JSON
  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      institution: json['institution'] as String,
      description: json['description'] as String,
      profession: json['profession'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'institution': institution,
      'description': description,
      'profession': profession,
      'tags': tags,
    };
  }

  // Métodos para SQLite (mobile)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'institution': institution,
      'description': description,
      'profession': profession,
      'tags': tags,
    };
  }

  factory EventDto.fromMap(Map<String, dynamic> map) {
    return EventDto(
      id: map['id'] as int?,
      name: map['name'] as String,
      institution: map['institution'] as String,
      description: map['description'] as String,
      profession: map['profession'] as String,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  // Método para criar uma cópia com modificações
  EventDto copyWith({
    int? id,
    String? name,
    String? institution,
    String? description,
    String? profession,
    List<String>? tags,
  }) {
    return EventDto(
      id: id ?? this.id,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      description: description ?? this.description,
      profession: profession ?? this.profession,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'EventDto(id: $id, name: $name, institution: $institution, description: $description, profession: $profession, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventDto &&
        other.id == id &&
        other.name == name &&
        other.institution == institution &&
        other.description == description &&
        profession == other.profession &&
        listEquals(tags, other.tags);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        institution.hashCode ^
        description.hashCode ^
        profession.hashCode ^
        tags.hashCode;
  }

  // Helper method for tags
  String tagsAsString() {
    return tags.join(', ');
  }

  // Helper method to convert string to tags list
  static List<String> fromTagsString(String tagsString) {
    if (tagsString.isEmpty) return [];
    return tagsString.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
  }
}
