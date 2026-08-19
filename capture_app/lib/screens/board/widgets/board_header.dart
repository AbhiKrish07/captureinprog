import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoardHeader extends StatelessWidget {
  const BoardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.transparent,
      child: Row(
        children: [
          // Left: App Name and Space Dropdown
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Capture',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),

            ],
          ),
          
          const Spacer(),
          
          // Center: Search Bar
          GestureDetector(
            onTap: () => context.push('/voice'),
            child: Container(
              width: 320,
              height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: LibraryDesignSystem.textPrimary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 8),
                Text(
                  'Ask Capture anything...',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.keyboard_command_key, size: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(width: 2),
                Text('K', style: TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ),
          
          const Spacer(),
          
          // Right Actions
          Row(
            children: [
              _HeaderCircleIcon(icon: Icons.add, color: const Color(0xFF4B5563)),
              const SizedBox(width: 12),
              _HeaderCircleIcon(
                icon: Icons.auto_awesome, 
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
              ),
              const SizedBox(width: 24),
              Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 22),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100&auto=format&fit=crop'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? bgColor;

  const _HeaderCircleIcon({
    required this.icon,
    required this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor ?? LibraryDesignSystem.textPrimary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}