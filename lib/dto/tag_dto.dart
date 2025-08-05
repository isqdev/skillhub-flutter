class TagDto {
  final int? id;
  final String name;

  const TagDto({
    this.id,
    required this.name,
  });

  // Convert from JSON
  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: json['id'] as int?,
      name: json['name'] as String,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Add copyWith method
  TagDto copyWith({
    int? id,
    String? name,
  }) {
    return TagDto(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  // Add toLowerCase method
  String toLowerCase() {
    return name.toLowerCase();
  }

  // Add static fromStringList method
  static List<TagDto> fromStringList(List<String> strings) {
    return strings.map((str) => TagDto(name: str)).toList();
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagDto && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
