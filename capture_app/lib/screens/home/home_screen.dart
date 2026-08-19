import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../providers/capture_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/shortcuts_provider.dart';

import '../../widgets/capture_context_menu.dart';
import '../../models/capture.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme to force rebuild when dark mode toggles
    ref.watch(themeProvider);
    // This specific screen uses a light theme to match the mockup
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(),
              SizedBox(height: 24),
              _GreetingSection(),
              SizedBox(height: 32),
              _ShortcutsSection(),
              SizedBox(height: 32),
              _SearchBarSection(),
              SizedBox(height: 32),
              _RecentSection(),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_mosaic, color: AppColors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Capture',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),

              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GreetingSection extends ConsumerWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);
    final String displayName;
    if (user != null) {
      // Check user metadata for 'name' or 'full_name', fallback to email prefix
      final metadataName = user.userMetadata?['name'] ?? user.userMetadata?['full_name'];
      if (metadataName != null && metadataName.toString().isNotEmpty) {
        displayName = metadataName.toString();
      } else if (user.email != null && user.email!.isNotEmpty) {
        displayName = user.email!.split('@').first;
      } else {
        displayName = 'Boss';
      }
    } else {
      displayName = 'Boss';
    }

    // Capitalize first letter of display name if it's not empty
    final formattedName = displayName.length > 1 
        ? '${displayName[0].toUpperCase()}${displayName.substring(1)}'
        : displayName;

    final hour = DateTime.now().hour;
    String timeGreeting = 'Good morning';
    if (hour >= 12 && hour < 17) {
      timeGreeting = 'Good afternoon';
    } else if (hour >= 17) {
      timeGreeting = 'Good evening';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -1,
                fontFamily: 'Inter',
              ),
              children: [
                TextSpan(text: '$timeGreeting $formattedName,\nwhat are we '),
                TextSpan(
                  text: 'capturing?',
                  style: TextStyle(color: AppColors.orange),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Drop anything. We'll handle the rest.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class _ShortcutsSection extends ConsumerWidget {
  const _ShortcutsSection();



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcuts = ref.watch(shortcutsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [

          ...shortcuts.map((shortcut) => _ShortcutCard(
            icon: shortcut.icon,
            color: shortcut.color,
            label: shortcut.label,
            onTap: () => context.push(shortcut.route),
            onLongPress: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceElevated,
                  title: Text('Remove Shortcut?', style: TextStyle(color: AppColors.textPrimary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
                    TextButton(onPressed: () {
                      ref.read(shortcutsProvider.notifier).removeShortcut(shortcut.id);
                      Navigator.pop(ctx);
                    }, child: Text('Remove', style: TextStyle(color: AppColors.red))),
                  ]
                )
              );
            },
          )),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ShortcutCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: color,
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarSection extends StatelessWidget {
  const _SearchBarSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              SizedBox(width: 12),
              Text(
                'Search captures, spaces...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => context.push('/voice'),
                child: Icon(Icons.mic, color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSection extends ConsumerWidget {
  const _RecentSection();

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  IconData _getIconForType(String type) {
    if (type == 'image') return Icons.image_outlined;
    if (type == 'video') return Icons.play_arrow_rounded;
    if (type == 'file') return Icons.insert_drive_file_outlined;
    if (type == 'voice') return Icons.graphic_eq;
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captureListAsync = ref.watch(captureListNotifierProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Recent',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary, size: 20),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/recents'),
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          captureListAsync.when(
            data: (captures) {
              if (captures.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No captures yet.', style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return Column(
                children: captures.take(5).map((capture) {
                  final cType = capture.type ?? 'unknown';
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _RecentItem(
                      capture: capture,
                      icon: _getIconForType(cType),
                      iconColor: _getColorForType(cType),
                      iconBg: _getBgColorForType(cType),
                      title: capture.title ?? capture.content,
                      type: '${cType[0].toUpperCase()}${cType.substring(1)}',
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
                }).toList(),
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: AppColors.orange)),
            error: (err, stack) => Text('Error: $err'),
          ),
        ],
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
    ));
  }
}
