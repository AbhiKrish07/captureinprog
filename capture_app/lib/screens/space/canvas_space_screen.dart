import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/canvas_state.dart';
import 'widgets/space_left_toolbar.dart';
import 'widgets/space_top_bar.dart';
import 'widgets/canvas_view.dart';
import 'widgets/card_editor_panel.dart';
import 'widgets/ai_chat_panel.dart';
import 'widgets/ai_suggestions_panel.dart';

class CanvasSpaceScreen extends ConsumerWidget {
  const CanvasSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCard = ref.watch(activeCardProvider);
    final isChatOpen = ref.watch(isChatOpenProvider);
    final isSuggestionsOpen = ref.watch(isSuggestionsOpenProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // subtle gray background for canvas
      body: Row(
        children: [
          // Left fixed toolbar
          const SpaceLeftToolbar(),
          
          // Main dynamic area
          Expanded(
            child: Column(
              children: [
                // Top navigation bar
                const SpaceTopBar(),
                
                // Canvas + Reader panels
                Expanded(
                  child: Row(
                    children: [
                      // Canvas Area
                      Expanded(
                        flex: activeCard != null ? 1 : 1, // When reader opens, canvas could shrink or share space
                        child: const CanvasView(),
                      ),
                      
                      // Reader / Editor Panel (conditionally visible)
                      if (activeCard != null)
                        const Expanded(
                          flex: 1,
                          child: CardEditorPanel(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Collapsible right panels
          if (isChatOpen) const AiChatPanel(),
          if (isSuggestionsOpen) const AiSuggestionsPanel(),
        ],
      ),
    );
  }
}
