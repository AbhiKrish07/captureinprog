import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/canvas_state.dart';
import 'chat_input_bar.dart';

class AiChatPanel extends ConsumerWidget {
  const AiChatPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 380, // Fixed width as requested
      decoration: BoxDecoration(
        color: LibraryDesignSystem.textPrimary,
        border: Border(
          left: BorderSide(color: LibraryDesignSystem.borderDark, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: LibraryDesignSystem.borderDark)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    ref.read(isChatOpenProvider.notifier).state = false;
                  },
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'AGI Definition and Impact', // mock thread title
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: LibraryDesignSystem.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 12, color: LibraryDesignSystem.textSecondary),
                      const SizedBox(width: 4),
                      Text('private', style: TextStyle(fontSize: 10, color: LibraryDesignSystem.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.more_horiz, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Message List Mock
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _UserMessageMock(),
                const SizedBox(height: 24),
                _AiMessageMock(),
              ],
            ),
          ),
          
          // Input Bar
          const ChatInputBar(),
        ],
      ),
    );
  }
}

class _UserMessageMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: LibraryDesignSystem.borderDark,
              child: Text('A', style: TextStyle(fontSize: 10, color: LibraryDesignSystem.textPrimary)),
            ),
            const SizedBox(width: 8),
            Text('Alan Chan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 8),
            Text('12/01/2025 8:51 AM', style: TextStyle(color: LibraryDesignSystem.textSecondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: LibraryDesignSystem.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.dashboard_outlined, size: 12, color: LibraryDesignSystem.textSecondary),
              const SizedBox(width: 4),
              Text('AGI Research', style: TextStyle(fontSize: 11, color: LibraryDesignSystem.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What is the mathematical definition of AGI, and how do AI leaders think it is going to impact the world? Give all your answers with accurate citations.',
          style: TextStyle(fontSize: 14, height: 1.5, color: LibraryDesignSystem.textPrimary),
        ),
      ],
    );
  }
}

class _AiMessageMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text('Gemini 3 Pro', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Icon(Icons.arrow_drop_down, size: 16, color: LibraryDesignSystem.textSecondary),
            const SizedBox(width: 4),
            Text('12/01/2025 8:51 AM', style: TextStyle(color: LibraryDesignSystem.textSecondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 12),
        
        // Thought completed toggle
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: LibraryDesignSystem.borderDark),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Thought completed', style: TextStyle(fontSize: 13, color: LibraryDesignSystem.textPrimary)),
              Icon(Icons.unfold_more, size: 16, color: LibraryDesignSystem.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          'I will search for the mathematical definition of AGI in the attached PDFs, specifically looking for formal definitions of universal intelligence in the works of Shane Legg and Marcus Hutter. Then, I will answer your question by synthesizing those definitions with the perspectives on AGI\'s impact from the interviews with AI leaders found in your whiteboard.',
          style: TextStyle(fontSize: 14, height: 1.5, color: LibraryDesignSystem.textPrimary),
        ),
        const SizedBox(height: 16),
        
        // Citations chips
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: LibraryDesignSystem.borderDark),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.search, size: 12, color: LibraryDesignSystem.textSecondary),
                  const SizedBox(width: 4),
                  Text('Searched in', style: TextStyle(fontSize: 12, color: LibraryDesignSystem.textPrimary)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: LibraryDesignSystem.surface,
                    child: Text('Machine Su... (P1-P200)', style: TextStyle(fontSize: 10, color: LibraryDesignSystem.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '"mathematical definition intelligence", "formal definition universal intelligence", "AIXI definition", "measure of intelligence"',
                style: TextStyle(fontSize: 12, color: LibraryDesignSystem.textSecondary),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Thinking
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: LibraryDesignSystem.borderDark),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Thinking', style: TextStyle(fontSize: 13, color: LibraryDesignSystem.textPrimary)),
              Icon(Icons.unfold_more, size: 16, color: LibraryDesignSystem.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}