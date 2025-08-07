class PostDto {
  final int? id;
  final List<int> userIds; // IDs dos usuários que publicaram
  final String description;
  final String? imageUrl;
  final DateTime createdAt;

  PostDto({
    this.id,
    required this.userIds,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });

  PostDto copyWith({
    int? id,
    List<int>? userIds,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return PostDto(
      id: id ?? this.id,
      userIds: userIds ?? this.userIds,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userIds': userIds,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'],
      userIds: List<int>.from(json['userIds'] ?? []),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}