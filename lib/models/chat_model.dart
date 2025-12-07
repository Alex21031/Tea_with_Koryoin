// lib/models/chat_model.dart
class ChatRoom {
  final int id;
  final String otherName;
  final int otherId;

  ChatRoom({required this.id, required this.otherName, required this.otherId});

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['room_id'],
      otherName: json['other_name'],
      otherId: json['other_id'],
    );
  }
}

class ChatMessage {
  final int id;
  final int senderId;
  final String content;
  final String createdAt;

  ChatMessage({required this.id, required this.senderId, required this.content, required this.createdAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }
}