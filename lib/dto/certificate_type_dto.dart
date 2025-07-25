class CertificateTypeDto {
  final int? id;
  final String name;
  final String description;

  const CertificateTypeDto({
    this.id,
    required this.name,
    required this.description,
  });

  // Construtor para criar a partir de JSON
  factory CertificateTypeDto.fromJson(Map<String, dynamic> json) {
    return CertificateTypeDto(
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

  // Método para criar uma cópia com modificações
  CertificateTypeDto copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return CertificateTypeDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'CertificateTypeDto(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CertificateTypeDto &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ description.hashCode;
  }
}
