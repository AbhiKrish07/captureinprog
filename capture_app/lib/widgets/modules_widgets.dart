import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const GlassContainer({super.key, required this.child, this.margin, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: child,
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.color, this.onAction, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color ?? AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: LibraryDesignSystem.textPrimary),
              child: Text(actionLabel!),
            ),
          ]
        ],
      ),
    );
  }
}

class PriorityTag extends StatelessWidget {
  final String priority;
  final bool compact;
  const PriorityTag({super.key, required this.priority, this.compact = false});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.green;
    if (priority == 'high' || priority == 'critical') color = AppColors.red;
    if (priority == 'medium') color = AppColors.yellow;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12, vertical: compact ? 2 : 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(priority.toUpperCase(), style: GoogleFonts.inter(fontSize: compact ? 10 : 12, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;

  const MetricCard({super.key, required this.title, required this.value, this.icon, this.color, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: color ?? AppColors.textSecondary),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(subtitle!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
              ],
            ]
          ),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;
  const SectionHeader({super.key, required this.title, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color ?? AppColors.textPrimary),
            const SizedBox(width: 8),
          ],
          Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
