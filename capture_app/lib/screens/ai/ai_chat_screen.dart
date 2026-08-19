
import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../providers/theme_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/capture_provider.dart';
import '../../services/groq_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isChatting = false;
  bool _isTyping = false;
  final List<ChatMessage> _messages = [];

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isChatting = true;
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Fetch database captures to provide context to the AI
    final capturesAsync = ref.read(captureListNotifierProvider);
    final captures = capturesAsync.value ?? [];
    
    // Call the Groq Service
    final aiResponseText = await GroqService.sendMessage(text, captures);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: aiResponseText,
        isUser: false,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            if (!_isChatting)
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AiHeader().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                    SizedBox(height: 16),
                    const _StatsBar().animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
                    SizedBox(height: 32),
                    const _RecentConversations().animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1),
                    SizedBox(height: 32),
                    const _SuggestedForYou().animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),
                    SizedBox(height: 32),
                    const _ConnectedKnowledge().animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1),
                    SizedBox(height: 200),
                  ],
                ),
              )
            else
              Column(
                children: [
                  const _AiHeader(),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 200),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return const _TypingIndicator();
                        }
                        final msg = _messages[index];
                        return _MessageBubble(message: msg);
                      },
                    ),
                  ),
                ],
              ),
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 100,
              left: 16,
              right: 16,
              child: _AiInputBar(
                controller: _controller,
                onSend: _sendMessage,
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: AppColors.orange, size: 16),
            ),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.orange : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                border: message.isUser ? null : Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? LibraryDesignSystem.textPrimary : AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) SizedBox(width: 36), // Align visual balance
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: AppColors.orange, size: 16),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot().animate(onPlay: (c) => c.repeat()).fade(duration: 400.ms).then().fade(duration: 400.ms, begin: 1, end: 0.3),
                SizedBox(width: 4),
                _Dot().animate(onPlay: (c) => c.repeat(), delay: 200.ms).fade(duration: 400.ms).then().fade(duration: 400.ms, begin: 1, end: 0.3),
                SizedBox(width: 4),
                _Dot().animate(onPlay: (c) => c.repeat(), delay: 400.ms).fade(duration: 400.ms).then().fade(duration: 400.ms, begin: 1, end: 0.3),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.textTertiary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AiHeader extends StatelessWidget {
  const _AiHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                'Capture AI',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Text(
                  'Claude 3.5 Sonnet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(icon: Icons.description_outlined, text: '247 Captures', iconColor: AppColors.orange),
            Text('•', style: TextStyle(color: AppColors.textTertiary)),
            _StatItem(icon: Icons.graphic_eq, text: '89 Voice Notes', iconColor: AppColors.green),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _StatItem({required this.icon, required this.text, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


class _RecentConversations extends StatelessWidget {
  const _RecentConversations();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Conversations', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
              Text('View all', style: TextStyle(color: AppColors.textTertiary, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: 16),
          _ConversationItem(query: 'What startup ideas have I saved?', subtitle: '2h ago · Startup'),
          _ConversationItem(query: 'Compare Cursor vs Windsurf', subtitle: 'Yesterday · Research'),
        ],
      ),
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final String query;
  final String subtitle;

  const _ConversationItem({required this.query, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 0.5)),
            child: Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.textTertiary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(query, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.push_pin_outlined, size: 16, color: AppColors.textTertiary),
          SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class _SuggestedForYou extends StatelessWidget {
  const _SuggestedForYou();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Suggested for you', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _SuggestionPill(icon: Icons.lightbulb_outline, iconColor: AppColors.orange, text: 'Find voice notes\nabout QuietStudio'),
              _SuggestionPill(icon: Icons.description_outlined, iconColor: AppColors.blue, text: 'What did I learn\nthis week?'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _SuggestionPill({required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          SizedBox(width: 8),
          Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.2)),
        ],
      ),
    );
  }
}

class _ConnectedKnowledge extends StatelessWidget {
  const _ConnectedKnowledge();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Connected Knowledge', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
              Text('View all', style: TextStyle(color: AppColors.textTertiary, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _KnowledgeChip(icon: Icons.menu_book_outlined, iconColor: AppColors.violet, title: 'Research Notes', subtitle: '89 items'),
              _KnowledgeChip(icon: Icons.graphic_eq, iconColor: AppColors.green, title: 'Voice Notes', subtitle: '38 items'),
            ],
          ),
        ),
      ],
    );
  }
}

class _KnowledgeChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _KnowledgeChip({required this.icon, required this.iconColor, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _AiInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                child: Icon(Icons.add, color: AppColors.textSecondary, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Ask your second brain...',
                    hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  final bool isEmpty = value.text.trim().isEmpty;
                  return GestureDetector(
                    onTap: isEmpty ? () => context.push('/voice') : onSend,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isEmpty ? Icons.mic : Icons.arrow_upward, 
                        color: LibraryDesignSystem.textPrimary, 
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _ActionChip(icon: Icons.grid_view_rounded, text: 'Select Context', hasDropdown: true),
              SizedBox(width: 8),
              _ActionChip(icon: Icons.public, text: 'Search the web'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasDropdown;

  const _ActionChip({required this.icon, required this.text, this.hasDropdown = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 14),
          SizedBox(width: 6),
          Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
          if (hasDropdown) ...[
            SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 14),
          ],
        ],
      ),
    );
  }
}