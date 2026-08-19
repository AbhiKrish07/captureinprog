import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../providers/capture_provider.dart';
import '../../widgets/capture_context_menu.dart';
import '../../models/capture.dart';

class RecentsScreen extends ConsumerWidget {
  const RecentsScreen({super.key});

  IconData _getIconForType(String type) {
    if (type == 'image') return Icons.image_outlined;
    if (type == 'video') return Icons.play_circle_outline;
    if (type == 'file') return Icons.insert_drive_file_outlined;
    if (type == 'link') return Icons.link;
    return Icons.description_outlined;
  }

  Color _getColorForType(String type) {
    if (type == 'image') return Color(0xFF4A88ED);
    if (type == 'video') return Color(0xFFEC5A72);
    if (type == 'file') return Color(0xFF3BAE74);
    if (type == 'link') return Color(0xFFD38B42);
    return Color(0xFF9B63DA);
  }

  Color _getBgColorForType(String type) {
    if (type == 'image') return AppColors.blue.withValues(alpha: 0.1);
    if (type == 'video') return AppColors.red.withValues(alpha: 0.1);
    if (type == 'file') return AppColors.green.withValues(alpha: 0.1);
    if (type == 'link') return AppColors.yellow.withValues(alpha: 0.1);
    return Color(0xFF9B63DA).withValues(alpha: 0.1);
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captureListAsync = ref.watch(captureListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'All Captures',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: captureListAsync.when(
        data: (captures) {
          if (captures.isEmpty) {
            return Center(
              child: Text(
                'No captures yet.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(24),
            itemCount: captures.length,
            itemBuilder: (context, index) {
              final capture = captures[index];
              final cType = capture.type ?? 'unknown';
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _RecentItem(
                  capture: capture,
                  icon: _getIconForType(cType),
                  iconColor: _getColorForType(cType),
                  iconBg: _getBgColorForType(cType),
                  title: capture.title ?? capture.content,
                  type: cType.isNotEmpty ? cType[0].toUpperCase() + cType.substring(1) : 'Unknown',
                  time: _formatTimeAgo(capture.createdAt),
                  onTap: () {
                    if (['image', 'video', 'file'].contains(cType)) {
                      context.push('/capture/viewer', extra: capture);
                    } else {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surfaceElevated,
                          title: Text(capture.title ?? 'Capture', style: TextStyle(color: AppColors.textPrimary)),
                          content: Text(capture.content, style: TextStyle(color: AppColors.textSecondary)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Close', style: TextStyle(color: AppColors.orange)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.orange)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _RecentItem extends ConsumerWidget {
  final Capture capture;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String type;
  final String time;
  final VoidCallback? onTap;

  const _RecentItem({
    required this.capture,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.type,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => showCaptureContextMenu(context, ref, capture),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        type,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.circle, size: 3, color: AppColors.border),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => showCaptureContextMenu(context, ref, capture),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.more_horiz, color: AppColors.border),
              ),
            ),
          ],
        ),
      ),
    );
  }
}