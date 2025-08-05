import 'tag_dto.dart';
import 'institution_dto.dart'; // Import InstitutionDto

class CertificateDto {
  final int? id;
  final String name;
  final InstitutionDto institution; // Change from String to InstitutionDto
  final String type;
  final int hours;
  final List<TagDto> tags;
  final int? userId;  // Certifique-se que este campo existe

  const CertificateDto({
    this.id,
    required this.name,
    required this.institution,
    required this.type,
    required this.hours,
    required this.tags,
    this.userId,  // Adicione se não existir
  });

  // Constructor to create from JSON
  factory CertificateDto.fromJson(Map<String, dynamic> json) {
    return CertificateDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      institution: InstitutionDto.fromJson(json['institution'] as Map<String, dynamic>),
      type: json['type'] as String,
      hours: json['hours'] as int,
      userId: json['userId'] as int?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((tagJson) => TagDto.fromJson(tagJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'institution': institution.toJson(),
      'type': type,
      'hours': hours,
      'tags': tags.map((tag) => tag.toJson()).toList(),
      'userId': userId,  // Adicione esta linha
    };
  }

  // Method to create a copy with modifications
  CertificateDto copyWith({
    int? id,
    String? name,
    InstitutionDto? institution,
    String? type,
    int? hours,
    List<TagDto>? tags,
    int? userId,
  }) {
    return CertificateDto(
      id: id ?? this.id,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      type: type ?? this.type,
      hours: hours ?? this.hours,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'CertificateDto(id: $id, name: $name, institution: $institution, type: $type, hours: $hours, tags: $tags, userId: $userId)';
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
        other.tags == tags &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        institution.hashCode ^
        type.hashCode ^
        hours.hashCode ^
        tags.hashCode ^
        userId.hashCode;
  }
}