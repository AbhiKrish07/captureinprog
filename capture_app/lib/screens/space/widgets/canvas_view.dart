import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/canvas_state.dart';
import 'canvas_card_widget.dart';
import 'canvas_group_widget.dart';
import 'connector_layer.dart';
import 'zoom_controls.dart';

class CanvasView extends ConsumerStatefulWidget {
  const CanvasView({super.key});

  @override
  ConsumerState<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends ConsumerState<CanvasView> {
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    if (ref.read(zoomLevelProvider) != scale) {
      // Delay to avoid setting state during build if panning rapidly
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(zoomLevelProvider.notifier).state = scale;
        }
      });
    }
  }

  void _handleZoom(double newZoom) {
    final matrix = _transformController.value.clone();
    final currentScale = matrix.getMaxScaleOnAxis();
    final scaleDelta = newZoom / currentScale;
    
    // Zoom around center of the viewport
    final center = Offset(
      context.size!.width / 2,
      context.size!.height / 2,
    );
    
    // Convert to scene coordinates
    final sceneCenter = _transformController.toScene(center);
    
    matrix.translate(sceneCenter.dx, sceneCenter.dy);
    matrix.scale(scaleDelta);
    matrix.translate(-sceneCenter.dx, -sceneCenter.dy);
    
    _transformController.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(canvasCardsProvider);
    final groups = ref.watch(canvasGroupsProvider);

    return Stack(
      children: [
        // The infinite canvas
        InteractiveViewer(
          transformationController: _transformController,
          constrained: false, // Infinite panning
          minScale: 0.1,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.all(10000), // very large margin
          child: SizedBox(
            // Need a large enough area for the stack to position things
            width: 10000,
            height: 10000,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Groups (background borders/pills)
                ...groups.map((g) => CanvasGroupWidget(group: g)),
                
                // Connectors Layer
                const ConnectorLayer(),
                
                // Cards Layer
                ...cards.map((card) => Positioned(
                  key: ValueKey(card.id),
                  left: card.position.dx,
                  top: card.position.dy,
                  child: CanvasCardWidget(card: card),
                )),
              ],
            ),
          ),
        ),
        
        // Pinned Zoom Controls (bottom center)
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: ZoomControls(
            onZoomIn: () => _handleZoom((ref.read(zoomLevelProvider) + 0.1).clamp(0.1, 3.0)),
            onZoomOut: () => _handleZoom((ref.read(zoomLevelProvider) - 0.1).clamp(0.1, 3.0)),
          ),
        ),
      ],
    );
  }
}
