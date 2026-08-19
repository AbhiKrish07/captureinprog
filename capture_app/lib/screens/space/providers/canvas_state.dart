import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'canvas_models.dart';
import '../../../services/api_service.dart';

final activeSpaceIdProvider = StateProvider<String?>((ref) => 'mock-space-1');

final canvasGroupsProvider = Provider<List<CanvasGroup>>((ref) {
  return [
    const CanvasGroup(id: 'g1', title: 'Foundation', color: Colors.green),
    const CanvasGroup(id: 'g2', title: 'GPT', color: Colors.blue),
    const CanvasGroup(id: 'g3', title: 'Interviews', color: Colors.orange),
  ];
});

class CanvasCardsNotifier extends StateNotifier<List<CanvasCard>> {
  final Ref ref;
  Timer? _debounceTimer;

  CanvasCardsNotifier(this.ref) : super(_initialCards);

  void updateCardPosition(String id, Offset newPosition) {
    state = [
      for (final card in state)
        if (card.id == id) card.copyWith(position: newPosition) else card
    ];
    _scheduleSync();
  }
  
  void addCard(CanvasCard card) {
    state = [...state, card];
    _scheduleSync();
  }

  void bulkImportCards(List<CanvasCard> newCards) {
    // Auto-arrange in a grid layout
    const double startX = 100.0;
    const double startY = 100.0;
    const double spacing = 40.0;
    double currentX = startX;
    double currentY = startY;
    double maxRowHeight = 0.0;
    const double maxWidth = 800.0; // Wrap after this width

    // Find the bottom-most point of existing cards to start placing new ones
    for (final card in state) {
      if (card.position.dy + card.size.height + spacing > currentY) {
        currentY = card.position.dy + card.size.height + spacing;
      }
    }

    final arrangedCards = <CanvasCard>[];
    for (final card in newCards) {
      if (currentX + card.size.width > startX + maxWidth) {
        currentX = startX;
        currentY += maxRowHeight + spacing;
        maxRowHeight = 0;
      }
      arrangedCards.add(card.copyWith(position: Offset(currentX, currentY)));
      currentX += card.size.width + spacing;
      if (card.size.height > maxRowHeight) {
        maxRowHeight = card.size.height;
      }
    }

    state = [...state, ...arrangedCards];
    _scheduleSync();
  }

  void _scheduleSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () async {
      final spaceId = ref.read(activeSpaceIdProvider);
      if (spaceId != null) {
        final cardsJson = state.map((e) => e.toMap()).toList();
        final edgesJson = ref.read(canvasEdgesProvider).map((e) => e.toMap()).toList();
        final canvasState = {'cards': cardsJson, 'edges': edgesJson};
        
        try {
          await ref.read(apiServiceProvider).updateSpace(spaceId, canvasState: canvasState);
          debugPrint("Synced canvas state to backend for space $spaceId");
        } catch (e) {
          debugPrint("Failed to sync canvas state: $e");
        }
      }
    });
  }
}

final canvasCardsProvider = StateNotifierProvider<CanvasCardsNotifier, List<CanvasCard>>((ref) {
  return CanvasCardsNotifier(ref);
});

class CanvasEdgesNotifier extends StateNotifier<List<CanvasEdge>> {
  final Ref ref;

  CanvasEdgesNotifier(this.ref) : super([]);

  void addEdge(CanvasEdge edge) {
    state = [...state, edge];
    ref.read(canvasCardsProvider.notifier)._scheduleSync();
  }
}

final canvasEdgesProvider = StateNotifierProvider<CanvasEdgesNotifier, List<CanvasEdge>>((ref) {
  return CanvasEdgesNotifier(ref);
});

// For active drawing
final drawingEdgeProvider = StateProvider<Offset?>((ref) => null);
final drawingSourceCardProvider = StateProvider<String?>((ref) => null);

final activeCardProvider = StateProvider<CanvasCard?>((ref) => null);
final isChatOpenProvider = StateProvider<bool>((ref) => false);
final isSuggestionsOpenProvider = StateProvider<bool>((ref) => false);
final zoomLevelProvider = StateProvider<double>((ref) => 1.0);

final List<CanvasCard> _initialCards = [
  const CanvasCard(
    id: 'c1',
    type: CanvasCardType.pdf,
    title: 'An Introduction to Universal Artificial Intelligence',
    author: 'Marcus Hutter',
    position: Offset(50, 100),
    size: Size(200, 280),
    groupId: 'g1',
  ),
  const CanvasCard(
    id: 'c2',
    type: CanvasCardType.pdf,
    title: 'Machine Super Intelligence',
    author: 'Shane Legg',
    position: Offset(270, 100),
    size: Size(200, 280),
    groupId: 'g1',
  ),
  const CanvasCard(
    id: 'c3',
    type: CanvasCardType.pdf,
    title: 'Universal Intelligence',
    author: 'Shane Legg, Marcus Hutter',
    position: Offset(490, 100),
    size: Size(200, 280),
    groupId: 'g1',
  ),
];
