import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/canvas_state.dart';
import '../providers/canvas_models.dart';

class SpaceTopBar extends ConsumerWidget {
  const SpaceTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: LibraryDesignSystem.textPrimary,
        border: Border(
          bottom: BorderSide(color: LibraryDesignSystem.borderDark, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Breadcrumb / Title
          Icon(Icons.dashboard_outlined, size: 18, color: LibraryDesignSystem.textSecondary),
          const SizedBox(width: 8),
          Text(
            'AGI Research', // mock space name
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: LibraryDesignSystem.textPrimary,
            ),
          ),
          
          const Spacer(),
          
          // Right actions
          TextButton(
            onPressed: () {
              // Mock bulk import
              final newCards = [
                CanvasCard(
                  id: 'mock_import_1', type: CanvasCardType.note, title: 'Imported Note 1',
                  content: 'Some insights', position: Offset.zero, size: Size(200, 150)
                ),
                CanvasCard(
                  id: 'mock_import_2', type: CanvasCardType.image, title: 'Imported Image',
                  position: Offset.zero, size: Size(200, 200)
                ),
                CanvasCard(
                  id: 'mock_import_3', type: CanvasCardType.pdf, title: 'Imported PDF',
                  position: Offset.zero, size: Size(200, 280)
                ),
              ];
              ref.read(canvasCardsProvider.notifier).bulkImportCards(newCards);
            },
            child: Text('Import', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Share', style: TextStyle(color: LibraryDesignSystem.textPrimary)),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, size: 20),
            color: LibraryDesignSystem.textSecondary,
            onPressed: () {},
          ),
          
          // View toggles
          Container(width: 1, height: 20, color: LibraryDesignSystem.borderDark, margin: const EdgeInsets.symmetric(horizontal: 8)),
          
          IconButton(
            icon: Icon(Icons.grid_view, size: 20),
            color: LibraryDesignSystem.textSecondary,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.view_timeline_outlined, size: 20),
            color: LibraryDesignSystem.textSecondary,
            onPressed: () {},
          ),
          // AI Chat toggle
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline, 
              size: 20, 
              color: ref.watch(isChatOpenProvider) ? Colors.blue : LibraryDesignSystem.textSecondary,
            ),
            onPressed: () {
              ref.read(isChatOpenProvider.notifier).state = !ref.read(isChatOpenProvider);
              if (ref.read(isChatOpenProvider)) {
                 ref.read(isSuggestionsOpenProvider.notifier).state = false;
              }
            },
          ),
          // AI Suggestions toggle
          IconButton(
            icon: Icon(
              Icons.auto_awesome, 
              size: 20, 
              color: ref.watch(isSuggestionsOpenProvider) ? Colors.purple : LibraryDesignSystem.textSecondary,
            ),
            onPressed: () {
              ref.read(isSuggestionsOpenProvider.notifier).state = !ref.read(isSuggestionsOpenProvider);
              if (ref.read(isSuggestionsOpenProvider)) {
                 ref.read(isChatOpenProvider.notifier).state = false;
              }
            },
          ),
        ],
      ),
    );
  }
}