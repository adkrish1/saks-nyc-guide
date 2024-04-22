import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatMessage {
  final types.User author;
  final int? createdAt;
  final String id;
  final String messageText;

  const ChatMessage({
    required this.author,
    required this.createdAt,
    required this.id,
    required this.messageText,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'author': author.id,
      'messageText': messageText,
    };
  }

  @override
  String toString() {
    return 'ChatMessage{id: $id, createdAt: $createdAt, author: ${author.id}, messageText: $messageText}';
  }
}
