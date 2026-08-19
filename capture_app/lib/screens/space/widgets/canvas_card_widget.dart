import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/canvas_models.dart';
import '../providers/canvas_state.dart';
import '../../modules/widgets/task_embedded_widget.dart';
import '../../modules/providers/module_providers.dart';

class CanvasCardWidget extends ConsumerStatefulWidget {
  final CanvasCard card;
  
  const CanvasCardWidget({super.key, required this.card});

  @override
  ConsumerState<CanvasCardWidget> createState() => _CanvasCardWidgetState();
}

class _CanvasCardWidgetState extends ConsumerState<CanvasCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeCard = ref.watch(activeCardProvider);
    final isSelected = activeCard?.id == widget.card.id;
    final isDrawingFromHere = ref.watch(drawingSourceCardProvider) == widget.card.id;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              final zoom = ref.read(zoomLevelProvider);
              final newPos = widget.card.position + (details.delta / zoom);
              ref.read(canvasCardsProvider.notifier).updateCardPosition(widget.card.id, newPos);
            },
            onTap: () {
              ref.read(activeCardProvider.notifier).state = widget.card;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.card.size.width,
              height: widget.card.size.height,
              decoration: BoxDecoration(
                color: LibraryDesignSystem.textPrimary,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? Colors.blue : (_isHovered ? Colors.blue.withValues(alpha: 0.5) : LibraryDesignSystem.borderDark),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected || _isHovered)
                    BoxShadow(
                      color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header / Type indicator
                  Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: LibraryDesignSystem.surface,
                      border: Border(bottom: BorderSide(color: LibraryDesignSystem.borderDark)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.card.type == CanvasCardType.pdf ? Icons.picture_as_pdf
                            : widget.card.type == CanvasCardType.video ? Icons.play_circle_outline
                            : Icons.note_alt_outlined,
                          size: 14,
                          color: LibraryDesignSystem.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.card.title,
                            style: TextStyle(fontSize: 10, color: LibraryDesignSystem.textSecondary, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content Area Mock
                  Expanded(
                    child: widget.card.type == CanvasCardType.moduleTask && widget.card.captureId != null
                        ? ref.watch(captureByIdProvider(widget.card.captureId!)).when(
                            data: (capture) => TaskEmbeddedWidget(capture: capture),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(fontSize: 10, color: Colors.red))),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.card.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                if (widget.card.author != null)
                                  Text(
                                    widget.card.author!,
                                    style: TextStyle(color: LibraryDesignSystem.textSecondary, fontSize: 11),
                                  ),
                                const Spacer(),
                                if (widget.card.type == CanvasCardType.video)
                                  Center(
                                    child: Icon(Icons.play_circle_fill, size: 48, color: Colors.red.withValues(alpha: 0.8)),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          
          // Connection Handle
          if (_isHovered || isDrawingFromHere)
            Positioned(
              right: -12,
              top: widget.card.size.height / 2 - 12,
              child: GestureDetector(
                onPanStart: (details) {
                  ref.read(drawingSourceCardProvider.notifier).state = widget.card.id;
                  final startPos = widget.card.position + Offset(widget.card.size.width, widget.card.size.height / 2);
                  ref.read(drawingEdgeProvider.notifier).state = startPos;
                },
                onPanUpdate: (details) {
                  final zoom = ref.read(zoomLevelProvider);
                  final current = ref.read(drawingEdgeProvider) ?? Offset.zero;
                  ref.read(drawingEdgeProvider.notifier).state = current + (details.delta / zoom);
                },
                onPanEnd: (details) {
                  final endPos = ref.read(drawingEdgeProvider);
                  final sourceId = ref.read(drawingSourceCardProvider);
                  if (endPos != null && sourceId != null) {
                    final cards = ref.read(canvasCardsProvider);
                    for (final c in cards) {
                      if (c.id != sourceId) {
                        final rect = Rect.fromLTWH(c.position.dx, c.position.dy, c.size.width, c.size.height);
                        if (rect.inflate(20).contains(endPos)) {
                          final newEdge = CanvasEdge(
                            id: 'e_${DateTime.now().millisecondsSinceEpoch}',
                            sourceId: sourceId,
                            targetId: c.id,
                          );
                          ref.read(canvasEdgesProvider.notifier).addEdge(newEdge);
                          break;
                        }
                      }
                    }
                  }
                  ref.read(drawingSourceCardProvider.notifier).state = null;
                  ref.read(drawingEdgeProvider.notifier).state = null;
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                    border: Border.all(color: LibraryDesignSystem.textPrimary, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}