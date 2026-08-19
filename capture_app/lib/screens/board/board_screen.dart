import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/board_header.dart';
import 'widgets/board_toolbar.dart';
import 'widgets/board_canvas.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  @override
  Widget build(BuildContext context) {
    // The Liquid aesthetic is strictly Light Mode
    final Color bgColor = const Color(0xFFFCFCFD);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                BoardHeader(), // Might need tweaks, but keeping it for context
                Expanded(
                  child: Stack(
                    children: [
                      // The Infinite Canvas
                      BoardCanvas(),
                      
                      // Bottom Left "Ask AI" floating pill
                      Positioned(
                        left: 24,
                        bottom: 32,
                        child: GestureDetector(
                          onTap: () => context.push('/voice'),
                          child: Container(
                          width: 280,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: LibraryDesignSystem.textPrimary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Color(0xFF10B981), // Green dot
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Capture is ready',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Ask anything...',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(Icons.keyboard_command_key, size: 12, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),
                      
                      // Bottom Center Floating Toolbar
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 32,
                        child: Center(
                          child: BoardToolbar(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}