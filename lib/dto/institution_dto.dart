class InstitutionDto {
  final int? id;
  final String name;
  final String state;
  final String city;
  final String area;
  final String type;

  const InstitutionDto({
    this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.area,
    required this.type,
  });

  // Construtor para criar a partir de JSON
  factory InstitutionDto.fromJson(Map<String, dynamic> json) {
    return InstitutionDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      area: json['area'] as String,
      type: json['type'] as String,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'city': city,
      'area': area,
      'type': type,
    };
  }

  // Método para criar uma cópia com modificações
  InstitutionDto copyWith({
    int? id,
    String? name,
    String? state,
    String? city,
    String? area,
    String? type,
  }) {
    return InstitutionDto(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      city: city ?? this.city,
      area: area ?? this.area,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'InstitutionDto(id: $id, name: $name, state: $state, city: $city, area: $area, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstitutionDto &&
        other.id == id &&
        other.name == name &&
        other.state == state &&
        other.city == city &&
        other.area == area &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           name.hashCode ^ 
           state.hashCode ^ 
           city.hashCode ^ 
           area.hashCode ^ 
           type.hashCode;
  }
}
