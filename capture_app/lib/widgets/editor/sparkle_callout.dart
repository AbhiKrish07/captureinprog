import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../config/design_system.dart';

class SparkleCallout extends StatelessWidget {
  const SparkleCallout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Slightly lighter than background
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(color: const Color(0xFF262626), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.sparkles,
            color: DesignSystem.textSecondary,
            size: 20,
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Text(
              'Ideas that solve real problems for creators\nusing AI to simplify the hard stuff.',
              style: DesignSystem.bodyLarge.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
