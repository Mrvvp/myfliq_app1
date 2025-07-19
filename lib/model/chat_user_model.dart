class ChatUser {
  final String id;
  final String name;
  final String imageUrl;

  ChatUser({required this.id, required this.name, required this.imageUrl});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      imageUrl: json['profile_photo_url'] ?? '',
    );
  }

  // Optional: If you're using Japx decoded data
  factory ChatUser.fromJapx(Map<String, dynamic> japxData) {
    return ChatUser(
      id: japxData['id'].toString(),
      name: japxData['name'] ?? 'Unknown',
      imageUrl: japxData['profile_photo_url'] ?? '',
    );
  }
}
