class InstitutionDto {
  final int? id;
  final String name;
  final String state;
  final String city;
  final String type;
  final String area;

  const InstitutionDto({
    this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.type,
    required this.area,
  });

  factory InstitutionDto.fromJson(Map<String, dynamic> json) {
    return InstitutionDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      type: json['type'] as String,
      area: json['area'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'city': city,
      'type': type,
      'area': area,
    };
  }

  InstitutionDto copyWith({
    int? id,
    String? name,
    String? state,
    String? city,
    String? type,
    String? area,
  }) {
    return InstitutionDto(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      city: city ?? this.city,
      type: type ?? this.type,
      area: area ?? this.area,
    );
  }

  @override
  String toString() => name;
}
