import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/canvas_state.dart';
import '../providers/canvas_models.dart';

class AiSuggestionsPanel extends ConsumerWidget {
  const AiSuggestionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCard = ref.watch(activeCardProvider);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: LibraryDesignSystem.textPrimary,
        border: Border(
          left: BorderSide(color: LibraryDesignSystem.borderDark, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Suggested Captures',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    ref.read(isSuggestionsOpenProvider.notifier).state = false;
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: activeCard == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Select a card on the canvas to see semantically related captures from your Store.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Because you selected "${activeCard.title}", here are some related captures:',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const _SuggestionItem(
                      title: 'Attention Is All You Need',
                      type: CanvasCardType.pdf,
                      snippet: 'The dominant sequence transduction models are based on complex recurrent or convolutional neural networks...',
                    ),
                    const SizedBox(height: 12),
                    const _SuggestionItem(
                      title: 'Transformers explained briefly',
                      type: CanvasCardType.note,
                      snippet: 'A quick summary of why self-attention scales better than RNNs.',
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionItem extends ConsumerWidget {
  final String title;
  final CanvasCardType type;
  final String snippet;

  const _SuggestionItem({
    required this.title,
    required this.type,
    required this.snippet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LibraryDesignSystem.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LibraryDesignSystem.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                type == CanvasCardType.pdf ? Icons.picture_as_pdf : Icons.note_alt_outlined,
                size: 14,
                color: LibraryDesignSystem.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            snippet,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                // Add to canvas
                final newCard = CanvasCard(
                  id: 's_${DateTime.now().millisecondsSinceEpoch}',
                  type: type,
                  title: title,
                  content: snippet,
                  position: const Offset(400, 300), // Default drop position or center of view
                  size: const Size(200, 200),
                );
                ref.read(canvasCardsProvider.notifier).addCard(newCard);
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add to Canvas', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: const Size(0, 28),
              ),
            ),
          )
        ],
      ),
    );
  }
}
