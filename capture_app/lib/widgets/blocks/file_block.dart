import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FileBlockWidget extends StatelessWidget {
  final String fileName;
  final String pages;

  const FileBlockWidget({
    super.key,
    required this.fileName,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Dark surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Red PDF Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.picture_as_pdf, color: AppColors.red, size: 24),
          ),
          const SizedBox(width: 16),
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pages,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Thumbnail Previews (faked with grey boxes)
          Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: 4),
              _buildThumbnail(),
              const SizedBox(width: 4),
              _buildThumbnail(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 28,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF262626), // Lightish grey for thumbnail
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 16, height: 2, color: const Color(0xFF404040)),
            const SizedBox(height: 4),
            Container(width: 12, height: 2, color: const Color(0xFF404040)),
            const SizedBox(height: 4),
            Container(width: 16, height: 2, color: const Color(0xFF404040)),
          ],
        ),
      ),
    );
  }
}
