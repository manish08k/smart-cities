import '../core/api_client.dart';
import '../models/chat_message.dart';

class ChatbotService {
  final ApiClient _client = ApiClient.instance;

  // ── Send message, get AI reply ────────────────────────────
  Future<ChatMessage> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final historyPayload = history
        .where((m) => !m.isLoading)
        .map((m) => m.toJson())
        .toList();

    final response = await _client.post(
      '/chat/message',
      data: {
        'message': message,
        'history': historyPayload,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return ChatMessage(
      id:        data['id']      as String,
      role:      MessageRole.assistant,
      content:   data['content'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
    );
  }

  // ── Get suggested quick-actions ───────────────────────────
  Future<List<String>> getSuggestions() async {
    final response = await _client.get('/chat/suggestions');
    return (response.data as List<dynamic>).cast<String>();
  }

  // ── Clear conversation on server ──────────────────────────
  Future<void> clearHistory(String sessionId) async {
    await _client.delete('/chat/history/$sessionId');
  }
}