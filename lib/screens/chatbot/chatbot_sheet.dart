import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/chat_provider.dart';
import '../../core/theme.dart';
import 'message_bubble.dart';

class ChatbotSheet extends StatefulWidget {
  const ChatbotSheet({super.key});

  @override
  State<ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<ChatbotSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputCtrl    = TextEditingController();
  final ScrollController       _scrollCtrl  = ScrollController();
  final FocusNode              _focusNode   = FocusNode();

  late AnimationController _sheetController;
  late Animation<double>   _sheetAnim;

  bool _inputHasText = false;

  @override
  void initState() {
    super.initState();

    _sheetController = AnimationController(
      duration: const Duration(milliseconds: 400), vsync: this,
    );
    _sheetAnim = CurvedAnimation(
      parent: _sheetController, curve: Curves.easeOut,
    );
    _sheetController.forward();

    _inputCtrl.addListener(() {
      final has = _inputCtrl.text.trim().isNotEmpty;
      if (has != _inputHasText) setState(() => _inputHasText = has);
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send(ChatProvider provider) {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || provider.isSending) return;
    _inputCtrl.clear();
    setState(() => _inputHasText = false);
    provider.sendMessage(text);
    HapticFeedback.selectionClick();
    _scrollToBottom();
  }

  void _sendSuggestion(ChatProvider provider, String suggestion) {
    provider.sendMessage(suggestion);
    HapticFeedback.selectionClick();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedBuilder(
      animation: _sheetAnim,
      builder: (_, child) => FadeTransition(
        opacity: _sheetAnim,
        child:   child,
      ),
      child: Consumer<ChatProvider>(
        builder: (_, provider, __) {
          // Auto-scroll when messages change
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            curve:    Curves.easeOut,
            padding:  EdgeInsets.only(bottom: bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFF0a0a0a),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                children: [
                  // ── Handle ────────────────────────────────────
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color:        Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Header ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color:        Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: Colors.black, size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI ASSISTANT',
                                style: GoogleFonts.spaceGrotesk(
                                  color:      Colors.white,
                                  fontSize:   16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 5, height: 5,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.accentGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text('POWERED BY CLAUDE',
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white38, fontSize: 8, letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Clear button
                        GestureDetector(
                          onTap: () {
                            provider.clearMessages();
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              border:       Border.all(color: Colors.white12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('CLEAR',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white38, fontSize: 8, letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white38, size: 20),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.white10),

                  // ── Message list ──────────────────────────────
                  Expanded(
                    child: provider.messages.isEmpty
                        ? _EmptyState()
                        : ListView.separated(
                      controller:      _scrollCtrl,
                      padding:         const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount:       provider.messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => MessageBubble(
                        message: provider.messages[i],
                      ),
                    ),
                  ),

                  // ── Suggestions ───────────────────────────────
                  if (provider.suggestions.isNotEmpty && !provider.isSending)
                    _SuggestionRow(
                      suggestions: provider.suggestions,
                      onTap: (s) => _sendSuggestion(provider, s),
                    ),

                  // ── Input bar ─────────────────────────────────
                  _InputBar(
                    controller:  _inputCtrl,
                    focusNode:   _focusNode,
                    hasText:     _inputHasText,
                    isSending:   provider.isSending,
                    onSend:      () => _send(provider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Suggestion chips ───────────────────────────────────────────

class _SuggestionRow extends StatelessWidget {
  final List<String>           suggestions;
  final ValueChanged<String>   onTap;
  const _SuggestionRow({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:         const EdgeInsets.symmetric(horizontal: 16),
        itemCount:       suggestions.length,
        itemBuilder: (_, i) {
          final s = suggestions[i];
          return GestureDetector(
            onTap: () => onTap(s),
            child: Container(
              margin:  const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border:       Border.all(color: Colors.white12),
              ),
              child: Center(
                child: Text(s,
                  style: GoogleFonts.spaceGrotesk(
                    color:      Colors.white54,
                    fontSize:   11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Input bar ──────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final bool                  hasText;
  final bool                  isSending;
  final VoidCallback          onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border:       Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller:    controller,
                focusNode:     focusNode,
                style:         GoogleFonts.spaceGrotesk(
                  color: Colors.white, fontSize: 13,
                ),
                maxLines:      null,
                keyboardType:  TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText:       'Ask about city data...',
                  hintStyle:      GoogleFonts.spaceGrotesk(
                    color: Colors.white24, fontSize: 13,
                  ),
                  border:         InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: hasText && !isSending ? onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  48, height: 48,
              decoration: BoxDecoration(
                color:        hasText && !isSending
                    ? AppTheme.accent
                    : Colors.white12,
                borderRadius: BorderRadius.circular(14),
              ),
              child: isSending
                  ? const Center(
                child: SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2,
                  ),
                ),
              )
                  : Icon(
                Icons.arrow_upward_rounded,
                color: hasText ? Colors.black : Colors.white24,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.05),
              shape:        BoxShape.circle,
              border:       Border.all(color: Colors.white12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded, color: Colors.white38, size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text('ASK ME ANYTHING',
            style: GoogleFonts.spaceGrotesk(
              color:      Colors.white38,
              fontSize:   13,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 6),
          Text('Parking · Traffic · Road Damage · City Stats',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white24, fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}