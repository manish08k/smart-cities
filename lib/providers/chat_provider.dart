import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/chatbot_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatbotService _service = ChatbotService();

  final List<ChatMessage> _messages = [
    ChatMessage(
      id:        'welcome',
      role:      MessageRole.assistant,
      content:   'Hello! I\'m your Smart City AI Assistant powered by Claude.\n\nAsk me about:\n• 🅿️ Parking availability & reservations\n• 🚦 Live traffic conditions\n• 🛣️ Road damage reports\n• 📊 City statistics',
      timestamp: DateTime.now(),
    ),
  ];

  List<String> _suggestions = [
    'How many parking slots are available?',
    'What is the current traffic status?',
    'Show me critical road damage reports',
    'Which floor has most parking?',
  ];

  bool _isSending = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────
  List<ChatMessage> get messages    => List.unmodifiable(_messages);
  List<String>      get suggestions => _suggestions;
  bool              get isSending   => _isSending;
  String?           get error       => _error;

  // ── Init ─────────────────────────────────────────────────
  Future<void> init() async {
    try {
      _suggestions = await _service.getSuggestions();
      notifyListeners();
    } catch (_) {
      // Keep default suggestions on error
    }
  }

  // ── Send ─────────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    final userMsg = ChatMessage(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      role:      MessageRole.user,
      content:   text.trim(),
      timestamp: DateTime.now(),
    );

    final loadingMsg = ChatMessage(
      id:        'loading_${DateTime.now().millisecondsSinceEpoch}',
      role:      MessageRole.assistant,
      content:   '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    _messages.add(userMsg);
    _messages.add(loadingMsg);
    _isSending = true;
    _error     = null;
    notifyListeners();

    try {
      final reply = await _service.sendMessage(
        message: text.trim(),
        history: _messages.where((m) => !m.isLoading).toList(),
      );
      // Replace loading bubble
      _messages.removeLast();
      _messages.add(reply);
    } catch (e) {
      _messages.removeLast();
      _messages.add(ChatMessage(
        id:        'err_${DateTime.now().millisecondsSinceEpoch}',
        role:      MessageRole.assistant,
        content:   'Sorry, I couldn\'t reach the server. Please check your connection.',
        timestamp: DateTime.now(),
      ));
      _error = e.toString();
    }

    _isSending = false;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}