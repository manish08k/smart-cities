import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

enum WsState { disconnected, connecting, connected, error }

class WebSocketClient {
  static WebSocketClient? _instance;
  WebSocketChannel? _channel;
  WsState _state = WsState.disconnected;

  final StreamController<Map<String, dynamic>> _messageController =
  StreamController.broadcast();

  Timer? _reconnectTimer;
  String? _currentPath;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  WebSocketClient._internal();

  static WebSocketClient get instance {
    _instance ??= WebSocketClient._internal();
    return _instance!;
  }

  Stream<Map<String, dynamic>> get stream => _messageController.stream;
  WsState get state => _state;

  // ── Connect ───────────────────────────────────────────────
  void connect(String path) {
    _currentPath = path;
    _reconnectAttempts = 0;
    _connect();
  }

  void _connect() {
    final wsBase = dotenv.env['WS_URL'] ?? 'ws://localhost:8000';
    final uri    = Uri.parse('$wsBase$_currentPath');

    _state = WsState.connecting;
    // ignore: avoid_print
    print('[WS] Connecting to $uri');

    try {
      _channel = WebSocketChannel.connect(uri);
      _state   = WsState.connected;
      _reconnectAttempts = 0;
      // ignore: avoid_print
      print('[WS] Connected');

      _channel!.stream.listen(
            (data) {
          try {
            final decoded = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (_) {}
        },
        onError: (error) {
          // ignore: avoid_print
          print('[WS] Error: $error');
          _state = WsState.error;
          _scheduleReconnect();
        },
        onDone: () {
          // ignore: avoid_print
          print('[WS] Connection closed');
          _state = WsState.disconnected;
          _scheduleReconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[WS] Connection failed: $e');
      _state = WsState.error;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: (2 * (_reconnectAttempts + 1)).clamp(2, 30));
    _reconnectAttempts++;
    // ignore: avoid_print
    print('[WS] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');
    _reconnectTimer = Timer(delay, _connect);
  }

  // ── Send ──────────────────────────────────────────────────
  void send(Map<String, dynamic> data) {
    if (_state == WsState.connected && _channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  // ── Disconnect ────────────────────────────────────────────
  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close(ws_status.goingAway);
    _state = WsState.disconnected;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}