import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LibraryDesignSystem.textPrimary,
        border: Border(top: BorderSide(color: LibraryDesignSystem.borderDark)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: LibraryDesignSystem.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LibraryDesignSystem.borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message AI...',
                  style: TextStyle(color: LibraryDesignSystem.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: LibraryDesignSystem.textPrimary,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: LibraryDesignSystem.borderDark),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dashboard_outlined, size: 12, color: LibraryDesignSystem.textSecondary),
                          const SizedBox(width: 4),
                          Text('AGI Research', style: TextStyle(fontSize: 11, color: LibraryDesignSystem.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.add_box_outlined, size: 20, color: LibraryDesignSystem.textSecondary),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 4),
                        Text('Gemini 3 Pro', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
                        Icon(Icons.arrow_drop_down, size: 16, color: Colors.blue),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.mic_none, size: 20, color: LibraryDesignSystem.textSecondary),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: LibraryDesignSystem.textPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_upward, size: 16, color: LibraryDesignSystem.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}