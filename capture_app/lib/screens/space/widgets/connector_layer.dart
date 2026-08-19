import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/canvas_state.dart';
import '../providers/canvas_models.dart';

class ConnectorLayer extends ConsumerWidget {
  const ConnectorLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(canvasCardsProvider);
    final edges = ref.watch(canvasEdgesProvider);
    final drawingEdge = ref.watch(drawingEdgeProvider);
    final drawingSourceCard = ref.watch(drawingSourceCardProvider);

    final connections = <CardConnection>[];
    
    // Static edges
    for (final edge in edges) {
      final from = cards.cast<CanvasCard?>().firstWhere((c) => c?.id == edge.sourceId, orElse: () => null);
      final to = cards.cast<CanvasCard?>().firstWhere((c) => c?.id == edge.targetId, orElse: () => null);
      if (from != null && to != null) {
        connections.add(CardConnection(from, to: to));
      }
    }
    
    // Active drawing line
    if (drawingEdge != null && drawingSourceCard != null) {
      final from = cards.cast<CanvasCard?>().firstWhere((c) => c?.id == drawingSourceCard, orElse: () => null);
      if (from != null) {
        connections.add(CardConnection(from, toOffset: drawingEdge));
      }
    }

    return CustomPaint(
      size: const Size(10000, 10000), // Match stack size
      painter: ConnectorPainter(connections: connections),
    );
  }
}

class CardConnection {
  final CanvasCard from;
  final CanvasCard? to;
  final Offset? toOffset;
  CardConnection(this.from, {this.to, this.toOffset});
}

class ConnectorPainter extends CustomPainter {
  final List<CardConnection> connections;
  
  ConnectorPainter({required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = LibraryDesignSystem.textSecondary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final conn in connections) {
      final isActive = conn.to == null;
      final currentPaint = isActive ? activePaint : paint;
      
      final start = Offset(
        conn.from.position.dx + conn.from.size.width,
        conn.from.position.dy + (conn.from.size.height / 2),
      );
      
      final end = conn.to != null ? Offset(
        conn.to!.position.dx,
        conn.to!.position.dy + (conn.to!.size.height / 2),
      ) : conn.toOffset!;

      final path = Path();
      path.moveTo(start.dx, start.dy);
      
      // Simple Bezier curve routing
      final controlPoint1 = Offset(start.dx + 40, start.dy);
      final controlPoint2 = Offset(end.dx - 40, end.dy);
      
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        end.dx, end.dy,
      );

      canvas.drawPath(path, currentPaint);
      
      // Draw arrowhead at end
      final arrowPaint = Paint()
        ..color = isActive ? Colors.blue : LibraryDesignSystem.textSecondary
        ..style = PaintingStyle.fill;
        
      final arrowPath = Path();
      arrowPath.moveTo(end.dx, end.dy);
      arrowPath.lineTo(end.dx - 8, end.dy - 4);
      arrowPath.lineTo(end.dx - 8, end.dy + 4);
      arrowPath.close();
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectorPainter oldDelegate) => true;
}