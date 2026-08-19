import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../config/design_system.dart';

class PdfAttachmentBlock extends StatelessWidget {
  const PdfAttachmentBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(color: const Color(0xFF262626), width: 1),
      ),
      child: Row(
        children: [
          // PDF Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935), // Red PDF color
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.fileText,
              color: LibraryDesignSystem.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: DesignSystem.spacingM),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Research.pdf',
                  style: DesignSystem.headlineSmall.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '24 pages',
                  style: DesignSystem.labelSmall,
                ),
              ],
            ),
          ),
          
          // Thumbnails (Mocked)
          Row(
            children: [
              _buildMockThumbnail(1),
              const SizedBox(width: 4),
              _buildMockThumbnail(2),
              const SizedBox(width: 4),
              _buildMockThumbnail(3),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMockThumbnail(int index) {
    // Simple mocked representation of PDF pages with graphs
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(width: 6, height: 12 + (index * 4).toDouble(), color: const Color(0xFF7C6EF7)),
              Container(width: 6, height: 24 - (index * 2).toDouble(), color: const Color(0xFFe8593c)),
              Container(width: 6, height: 16 + (index * 6).toDouble(), color: const Color(0xFFFFA000)),
            ],
          )
        ],
      ),
    );
  }
}