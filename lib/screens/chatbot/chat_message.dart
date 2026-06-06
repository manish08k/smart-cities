enum MessageRole { user, assistant }

class ChatMessage {
  final String      id;
  final MessageRole role;
  final String      content;
  final DateTime    timestamp;
  final bool        isLoading;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id:        json['id']        as String,
      role:      json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      content:   json['content']   as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':        id,
    'role':      role.name,
    'content':   content,
    'timestamp': timestamp.toIso8601String(),
  };
}
