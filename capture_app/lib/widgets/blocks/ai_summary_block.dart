import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AiSummaryBlockWidget extends StatelessWidget {
  final List<String> bulletPoints;

  const AiSummaryBlockWidget({
    super.key,
    required this.bulletPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF160D24), // Dark deep purple
            const Color(0xFF0F0818), // Almost black
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D1B4E).withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.violet, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Summary',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.more_horiz, color: AppColors.textTertiary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          ...bulletPoints.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, left: 4, right: 12),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.textTertiary, size: 12),
              const SizedBox(width: 6),
              Text(
                'Auto-generated',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
