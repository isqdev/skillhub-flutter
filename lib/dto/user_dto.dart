class UserDto {
  final int? id;
  final String name;
  final String email;
  final String profession;

  const UserDto({
    this.id,
    required this.name,
    required this.email,
    required this.profession,
  });

  // Construtor para criar a partir de JSON
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      profession: json['profession'] as String,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profession': profession,
    };
  }

  // ✅ ADICIONANDO: Métodos para SQLite (mobile)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profession': profession,
    };
  }

  factory UserDto.fromMap(Map<String, dynamic> map) {
    return UserDto(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      profession: map['profession'] as String,
    );
  }

  // Método para criar uma cópia com modificações
  UserDto copyWith({
    int? id,
    String? name,
    String? email,
    String? profession,
  }) {
    return UserDto(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profession: profession ?? this.profession,
    );
  }

  @override
  String toString() {
    return 'UserDto(id: $id, name: $name, email: $email, profession: $profession)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDto &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.profession == profession;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ email.hashCode ^ profession.hashCode;
  }
}
