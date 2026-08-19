import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/capture_provider.dart';

class BoardCanvas extends ConsumerWidget {
  const BoardCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The Liquid aesthetic is strictly Light Mode, so we hardcode light colors here
    // to match the exact mockup regardless of device theme.
    final Color bgColor = const Color(0xFFFCFCFD);

    final capturesAsync = ref.watch(captureListNotifierProvider);

    return InteractiveViewer(
      minScale: 0.2,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(2000),
      constrained: false,
      child: Container(
        width: 3000,
        height: 3000,
        color: bgColor,
        child: Stack(
          children: [
            // Connection Lines Painter
            Positioned.fill(
              child: CustomPaint(
                painter: _LiquidConnectionsPainter(),
              ),
            ),
            
            // Render actual data
            capturesAsync.when(
              data: (captures) {
                if (captures.isEmpty) {
                  return const Positioned(
                    left: 500,
                    top: 500,
                    child: LiquidStickyNode(
                      tag: '# welcome',
                      content: 'Welcome to Capture. Tap the + below or ask the AI to save your first thought.',
                      footer: 'Just now',
                    ),
                  );
                }
                
                return Stack(
                  children: List.generate(captures.length, (index) {
                    final capture = captures[index];
                    
                    // Generate a staggered grid layout
                    final row = index ~/ 3;
                    final col = index % 3;
                    final double left = 300.0 + (col * 350) + (row % 2 * 100);
                    final double top = 300.0 + (row * 350);

                    Widget node;
                    if (capture.type == 'image' || capture.type == 'link') {
                      node = LiquidImageNode(
                        imageUrl: 'https://images.unsplash.com/photo-1542385151-efd9000785a0?q=80&w=400&auto=format&fit=crop',
                        title: capture.title ?? 'Capture',
                        subtitle: capture.preview ?? capture.content,
                        tag: '#${capture.type}',
                      );
                    } else if (capture.type == 'voice') {
                       node = LiquidVideoNode(
                         imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=400&auto=format&fit=crop',
                         title: capture.title ?? 'Voice Note',
                         subtitle: capture.content,
                         duration: 'Voice',
                       );
                    } else {
                      node = LiquidStickyNode(
                        tag: '#${capture.type}',
                        content: capture.content,
                        footer: 'Captured recently',
                      );
                    }

                    return Positioned(
                      left: left,
                      top: top,
                      child: node,
                    );
                  }),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, st) => Positioned(
                left: 500, top: 500,
                child: Text('Error loading captures: $err', style: TextStyle(color: Colors.red)),
              ),
            ),

            // Drop Target
            const Positioned(
              left: 720,
              top: 1500,
              child: LiquidDropTargetNode(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiquidConnectionsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC4B5FD) // Soft purple line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dotPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.fill;

    // Daily Habits (400, 300) to James Clear (550, 650)
    _drawBezier(canvas, paint, dotPaint, 
      start: const Offset(490, 520), // Bottom of Daily Habits
      end: const Offset(650, 650),   // Left of James Clear
    );

    // Protocols (700, 250) to Drop Target (720, 950)
    _drawBezier(canvas, paint, dotPaint, 
      start: const Offset(790, 480), // Bottom of Protocols
      end: const Offset(780, 950),   // Top of Drop Target
    );

    // James Clear (550, 650) to Drop Target (720, 950)
    _drawBezier(canvas, paint, dotPaint, 
      start: const Offset(650, 830), // Bottom of James Clear
      end: const Offset(780, 950),   // Top of Drop Target
    );

    // Atomic Habits (850, 600) to Drop Target (720, 950)
    _drawBezier(canvas, paint, dotPaint, 
      start: const Offset(940, 830), // Bottom of Atomic Habits
      end: const Offset(780, 950),   // Top of Drop Target
    );
    
    // Idea (250, 750) to James Clear (550, 650)
    _drawBezier(canvas, paint, dotPaint, 
      start: const Offset(400, 830), // Right of Idea
      end: const Offset(550, 740),   // Left of James Clear
    );
  }

  void _drawBezier(Canvas canvas, Paint paint, Paint dotPaint, {required Offset start, required Offset end}) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    // Calculate control points for smooth elegant S-curves
    final controlPoint1 = Offset(start.dx, start.dy + (end.dy - start.dy) / 2);
    final controlPoint2 = Offset(end.dx, start.dy + (end.dy - start.dy) / 2);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy,
    );

    canvas.drawPath(path, paint);
    canvas.drawCircle(start, 4, dotPaint);
    canvas.drawCircle(end, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------
// NODE WIDGETS
// ---------------------------------------------------------

class LiquidImageNode extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String tag;

  const LiquidImageNode({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseLiquidNode(
      width: 220,
      glowColor: const Color(0xFFE0E7FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _LiquidTag(text: tag, color: const Color(0xFF10B981)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LiquidBookNode extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String tag;

  const LiquidBookNode({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseLiquidNode(
      width: 180,
      glowColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 120,
                width: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _LiquidTag(text: tag, color: const Color(0xFF8B5CF6)),
          ],
        ),
      ),
    );
  }
}

class LiquidVideoNode extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String duration;

  const LiquidVideoNode({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseLiquidNode(
      width: 240,
      glowColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: LibraryDesignSystem.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow_rounded, size: 20, color: LibraryDesignSystem.textPrimary),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  duration,
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LiquidStickyNode extends StatelessWidget {
  final String tag;
  final String content;
  final String footer;

  const LiquidStickyNode({
    super.key,
    required this.tag,
    required this.content,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.05, // Slight tilt
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF), // Very soft purple sticky
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD8B4FE).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tag,
              style: TextStyle(
                color: Color(0xFF9333EA),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: Color(0xFF4C1D95),
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              footer,
              style: TextStyle(
                color: Color(0xFFA855F7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiquidDropTargetNode extends StatelessWidget {
  const LiquidDropTargetNode({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: LibraryDesignSystem.textPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFF9CA3AF), size: 24),
            const SizedBox(height: 8),
            Text(
              'Drop anything\nto create',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// HELPERS
// ---------------------------------------------------------

class _BaseLiquidNode extends StatelessWidget {
  final Widget child;
  final double width;
  final Color glowColor;

  const _BaseLiquidNode({
    required this.child,
    required this.width,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: LibraryDesignSystem.textPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          if (glowColor != Colors.transparent)
            BoxShadow(
              color: glowColor,
              blurRadius: 40,
              spreadRadius: -10,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: child,
    );
  }
}

class _LiquidTag extends StatelessWidget {
  final String text;
  final Color color;

  const _LiquidTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}