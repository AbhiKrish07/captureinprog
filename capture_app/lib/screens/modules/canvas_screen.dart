import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/capture_provider.dart';
import '../../models/capture.dart';
import 'document_screen.dart';

class CanvasModuleScreen extends ConsumerStatefulWidget {
  const CanvasModuleScreen({super.key});

  @override
  ConsumerState<CanvasModuleScreen> createState() => _CanvasModuleScreenState();
}

class _CanvasModuleScreenState extends ConsumerState<CanvasModuleScreen> {
  // Theme Light Mode
  static const Color _bg = Color(0xFFF9F9F8); // Very light grey background
  static const Color _surface = Color(0xFFFFFFFF); // Pure white cards
  static const Color _border = Color(0xFFE5E5E5);
  static const Color _textPrimary = Color(0xFF111111);
  static const Color _textSecondary = Color(0xFF71717A);
  static const Color _accent = Color(0xFF2563EB); // Blue accent

  final TransformationController _transformationController = TransformationController();
  final Map<String, Offset> _localPositions = {};

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Offset _getCapturePosition(Capture capture) {
    if (_localPositions.containsKey(capture.id)) {
      return _localPositions[capture.id]!;
    }
    if (capture.metadata != null) {
      final x = (capture.metadata!['x'] as num?)?.toDouble();
      final y = (capture.metadata!['y'] as num?)?.toDouble();
      if (x != null && y != null) {
        return Offset(x, y);
      }
    }
    // Default fallback position
    return const Offset(2500, 2500); // Center of 5000x5000 canvas
  }

  void _updateCapturePosition(Capture capture, Offset offset, bool saveToBackend) {
    setState(() {
      _localPositions[capture.id] = offset;
    });
    
    if (saveToBackend) {
      final newMetadata = Map<String, dynamic>.from(capture.metadata ?? {});
      newMetadata['x'] = offset.dx;
      newMetadata['y'] = offset.dy;
      
      ref.read(captureListNotifierProvider.notifier).updateCapture(
        id: capture.id,
        metadata: newMetadata,
      );
    }
  }

  void _openCapture(Capture capture) {
    if (capture.contentType == 'text') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentModuleScreen(initialCaptureId: capture.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot open ${capture.contentType} yet')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureListNotifierProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            // The Infinite Canvas
            captureState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (captures) {
                // Initialize the transformation controller to center the canvas initially
                if (_transformationController.value == Matrix4.identity()) {
                  _transformationController.value = Matrix4.identity()..translate(-2000.0, -2000.0);
                }

                return InteractiveViewer(
                  transformationController: _transformationController,
                  constrained: false,
                  minScale: 0.1,
                  maxScale: 2.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: SizedBox(
                    width: 5000,
                    height: 5000,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background Grid
                        Positioned.fill(
                          child: CustomPaint(
                            painter: GridPainter(color: _border),
                          ),
                        ),
                        
                        // All cards
                        ...captures.map((capture) {
                          final position = _getCapturePosition(capture);
                          return Positioned(
                            left: position.dx,
                            top: position.dy,
                            child: _buildCard(capture),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // UI Overlay: Top Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(backgroundColor: _surface, elevation: 2),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      'Whiteboard',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Capture capture) {
    return GestureDetector(
      onPanUpdate: (details) {
        // We need to account for the zoom scale so dragging feels 1:1
        final double scale = _transformationController.value.getMaxScaleOnAxis();
        final delta = details.delta / scale;
        final currentPos = _getCapturePosition(capture);
        _updateCapturePosition(capture, currentPos + delta, false);
      },
      onPanEnd: (details) {
        // Save to backend on end
        final currentPos = _getCapturePosition(capture);
        _updateCapturePosition(capture, currentPos, true);
      },
      onDoubleTap: () => _openCapture(capture),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  capture.contentType == 'text' ? Icons.notes : 
                  capture.contentType == 'image' ? Icons.image : 
                  Icons.insert_drive_file,
                  size: 16,
                  color: _accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    capture.title?.isNotEmpty == true ? capture.title! : 'Untitled',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              capture.content.isNotEmpty ? capture.content : 'Double tap to edit...',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Background Grid Painter
class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    
    const double step = 40; // Size of grid squares
    
    // Draw dots
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}