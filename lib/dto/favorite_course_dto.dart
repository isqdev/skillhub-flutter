class FavoriteCourseDto {
  final int? id;
  final String name;
  final String instructor;
  final int duration; // em horas

  const FavoriteCourseDto({
    this.id,
    required this.name,
    required this.instructor,
    required this.duration,
  });

  // Construtor para criar a partir de JSON
  factory FavoriteCourseDto.fromJson(Map<String, dynamic> json) {
    return FavoriteCourseDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      instructor: json['instructor'] as String,
      duration: json['duration'] as int,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'instructor': instructor,
      'duration': duration,
    };
  }

  // Método para criar uma cópia com modificações
  FavoriteCourseDto copyWith({
    int? id,
    String? name,
    String? instructor,
    int? duration,
  }) {
    return FavoriteCourseDto(
      id: id ?? this.id,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      duration: duration ?? this.duration,
    );
  }

  // Helper para formatar duração
  String get durationFormatted => '$duration horas';

  @override
  String toString() {
    return 'FavoriteCourseDto(id: $id, name: $name, instructor: $instructor, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteCourseDto &&
        other.id == id &&
        other.name == name &&
        other.instructor == instructor &&
        other.duration == duration;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ instructor.hashCode ^ duration.hashCode;
  }
}
