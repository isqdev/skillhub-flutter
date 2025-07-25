class CertificateDto {
  final int? id;
  final String name;
  final String institution;
  final String type;
  final int hours;
  final List<String> tags;

  const CertificateDto({
    this.id,
    required this.name,
    required this.institution,
    required this.type,
    required this.hours,
    required this.tags,
  });

  // Constructor to create from JSON
  factory CertificateDto.fromJson(Map<String, dynamic> json) {
    return CertificateDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      institution: json['institution'] as String,
      type: json['type'] as String,
      hours: json['hours'] as int,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'institution': institution,
      'type': type,
      'hours': hours,
      'tags': tags,
    };
  }

  // Method to create a copy with modifications
  CertificateDto copyWith({
    int? id,
    String? name,
    String? institution,
    String? type,
    int? hours,
    List<String>? tags,
  }) {
    return CertificateDto(
      id: id ?? this.id,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      type: type ?? this.type,
      hours: hours ?? this.hours,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'CertificateDto(id: $id, name: $name, institution: $institution, type: $type, hours: $hours, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CertificateDto &&
        other.id == id &&
        other.name == name &&
        other.institution == institution &&
        other.type == type &&
        other.hours == hours &&
        other.tags == tags;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        institution.hashCode ^
        type.hashCode ^
        hours.hashCode ^
        tags.hashCode;
  }
}