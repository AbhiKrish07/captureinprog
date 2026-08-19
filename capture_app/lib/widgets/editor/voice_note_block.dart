import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../config/design_system.dart';
import 'dart:math';

class VoiceNoteBlock extends StatelessWidget {
  const VoiceNoteBlock({super.key});

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
          // Mic Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DesignSystem.surfaceGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.mic,
              color: DesignSystem.accentGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSystem.spacingM),
          
          // Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voice Note',
                style: DesignSystem.headlineSmall.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                '1:42 • Today, 9:30 AM',
                style: DesignSystem.labelSmall,
              ),
            ],
          ),
          const SizedBox(width: DesignSystem.spacingM),

          // Waveform (Mocked)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                30,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 2,
                  height: 10 + (Random(index).nextInt(20)).toDouble(), // deterministic random
                  decoration: BoxDecoration(
                    color: DesignSystem.textSecondary.withOpacity(index > 15 ? 0.3 : 1.0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: DesignSystem.spacingM),

          // Play Button
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF1a1a1a),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: DesignSystem.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
