import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/chat_message.dart';
import '../../../core/theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) return const _TypingIndicator();

    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize:     MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            _AvatarDot(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:        _isUser
                    ? Colors.white
                    : const Color(0xFF141414),
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(16),
                  topRight:    const Radius.circular(16),
                  bottomLeft:  Radius.circular(_isUser ? 16 : 4),
                  bottomRight: Radius.circular(_isUser ? 4  : 16),
                ),
                border: _isUser
                    ? null
                    : Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:       MainAxisSize.min,
                children: [
                  _buildContent(),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.spaceGrotesk(
                      color:    _isUser ? Colors.black38 : Colors.white24,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUser) ...[
            const SizedBox(width: 8),
            _UserDot(),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Render markdown-lite: bold **text**, bullet lines starting with •/-
    final lines = message.content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize:       MainAxisSize.min,
      children: lines.map((line) => _RichLine(line: line, isUser: _isUser)).toList(),
    );
  }

  String _formatTime(DateTime dt) {
    final h   = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$h:$min';
  }
}

// ── Rich line renderer ─────────────────────────────────────────

class _RichLine extends StatelessWidget {
  final String line;
  final bool   isUser;
  const _RichLine({required this.line, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final baseColor = isUser ? Colors.black : Colors.white70;

    // Bullet line
    if (line.trimLeft().startsWith('•') || line.trimLeft().startsWith('-')) {
      final text = line.trimLeft().replaceFirst(RegExp(r'^[•\-]\s*'), '');
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ',
              style: GoogleFonts.spaceGrotesk(
                color: isUser ? Colors.black54 : AppTheme.accent,
                fontSize: 12, height: 1.5,
              ),
            ),
            Flexible(child: _buildRichText(text, baseColor)),
          ],
        ),
      );
    }

    // Empty line → small gap
    if (line.trim().isEmpty) return const SizedBox(height: 4);

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child:   _buildRichText(line, baseColor),
    );
  }

  /// Parses **bold** markers inline.
  Widget _buildRichText(String text, Color base) {
    final spans  = <TextSpan>[];
    final regex  = RegExp(r'\*\*(.+?)\*\*');
    int   cursor = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text:  text.substring(cursor, match.start),
          style: GoogleFonts.spaceGrotesk(color: base, fontSize: 13, height: 1.5),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: GoogleFonts.spaceGrotesk(
          color:      base,
          fontSize:   13,
          fontWeight: FontWeight.w900,
          height:     1.5,
        ),
      ));
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(
        text:  text.substring(cursor),
        style: GoogleFonts.spaceGrotesk(color: base, fontSize: 13, height: 1.5),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ── Typing indicator ──────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 900), vsync: this,
    )..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AvatarDot(),
          const SizedBox(width: 8),
          Container(
            padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:        const Color(0xFF141414),
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(16),
                topRight:    Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft:  Radius.circular(4),
              ),
              border: Border.all(color: Colors.white10),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay  = i / 3;
                  final val    = ((_anim.value - delay) % 1.0).clamp(0.0, 1.0);
                  final offset = val < 0.5
                      ? val * 2
                      : 1.0 - (val - 0.5) * 2;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Transform.translate(
                      offset: Offset(0, -5 * offset),
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color:  Colors.white38,
                          shape:  BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar dots ───────────────────────────────────────────────

class _AvatarDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        color:        const Color(0xFF1a1a1a),
        shape:        BoxShape.circle,
        border:       Border.all(color: Colors.white12),
      ),
      child: const Icon(Icons.smart_toy_rounded, color: Colors.white54, size: 13),
    );
  }
}

class _UserDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        color:  Colors.white,
        shape:  BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.black, size: 13),
    );
  }
}