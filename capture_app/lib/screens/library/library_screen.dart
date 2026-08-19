// lib/screens/library/library_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../config/library_design_system.dart';
import 'widgets/recent_item.dart';
import 'widgets/filter_tabs.dart';
import '../../providers/capture_provider.dart';


import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isRecentsExpanded = false;

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  IconData _getIconForType(String type) {
    if (type == 'image') return Icons.image_outlined;
    if (type == 'video') return Icons.play_circle_outline;
    if (type == 'file') return Icons.insert_drive_file_outlined;
    if (type == 'link') return Icons.link;
    if (type == 'voice' || type == 'audio') return Icons.mic_none;
    return Icons.description_outlined;
  }

  Color _getColorForType(String type) {
    if (type == 'image') return AppColors.blue;
    if (type == 'video') return AppColors.red;
    if (type == 'file') return AppColors.green;
    if (type == 'link') return AppColors.yellow;
    return AppColors.violet;
  }



  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider);
    final captureListAsync = ref.watch(captureListNotifierProvider);
    return Scaffold(
      backgroundColor: LibraryDesignSystem.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: LibraryDesignSystem.spacingM,
                  left: LibraryDesignSystem.spacingL,
                  right: LibraryDesignSystem.spacingL,
                  bottom: LibraryDesignSystem.spacingM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Captures',
                      style: LibraryDesignSystem.titleLarge,
                    ),
                    SizedBox(height: LibraryDesignSystem.spacingS),

                    // Subtitle
                    Text(
                      'Everything you\'ve captured, organized your way.',
                      style: LibraryDesignSystem.subtitle,
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: LibraryDesignSystem.spacingL,
                  vertical: LibraryDesignSystem.spacingM,
                ),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: LibraryDesignSystem.surface,
                    borderRadius: BorderRadius.circular(
                      LibraryDesignSystem.radiusM,
                    ),
                    border: Border.all(
                      color: LibraryDesignSystem.borderDark,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: LibraryDesignSystem.spacingM,
                        ),
                        child: Icon(
                          Icons.search,
                          size: 20,
                          color: LibraryDesignSystem.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: LibraryDesignSystem.textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search your second brain...',
                            hintStyle: TextStyle(
                              color: LibraryDesignSystem.textMuted,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: LibraryDesignSystem.spacingM,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: LibraryDesignSystem.spacingM,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '⌘ K',
                              style: TextStyle(
                                fontSize: 12,
                                color: LibraryDesignSystem.textMuted,
                              ),
                            ),
                            SizedBox(width: LibraryDesignSystem.spacingM),
                            Icon(
                              Icons.filter_list,
                              size: 20,
                              color: LibraryDesignSystem.textSecondary,
                            ),
                            SizedBox(width: LibraryDesignSystem.spacingS),
                            Icon(
                              Icons.swap_vert,
                              size: 20,
                              color: LibraryDesignSystem.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filter tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: LibraryDesignSystem.spacingL,
                  vertical: LibraryDesignSystem.spacingM,
                ),
                child: FilterTabs(
                  onFilterChanged: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
              ),
            ),
            // Modules Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: LibraryDesignSystem.spacingL,
                  right: LibraryDesignSystem.spacingL,
                  bottom: LibraryDesignSystem.spacingM,
                ),
                child: Text(
                  'Modules',
                  style: LibraryDesignSystem.sectionHeader,
                ),
              ),
            ),

            // Modules Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: LibraryDesignSystem.spacingL),
                  children: [
                    _buildModuleCard(context, 'Tasks', Icons.check_box_outlined, LibraryDesignSystem.folderBlue, '/modules/tasks'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Canvas', Icons.dashboard_customize_outlined, LibraryDesignSystem.folderOrange, '/modules/canvas'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Focus', Icons.center_focus_strong_outlined, LibraryDesignSystem.folderPurple, '/modules/focus'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Reading', Icons.menu_book_outlined, LibraryDesignSystem.folderGreen, '/modules/reading'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Study', Icons.school_outlined, LibraryDesignSystem.folderOrange, '/modules/study'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Finance', Icons.attach_money_outlined, LibraryDesignSystem.folderGreen, '/modules/finance'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Mood', Icons.mood_outlined, LibraryDesignSystem.folderPurple, '/modules/mood'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Doc', Icons.description_outlined, LibraryDesignSystem.folderBlue, '/modules/document'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Assignments', Icons.assignment_outlined, LibraryDesignSystem.folderOrange, '/modules/assignments'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Calendar', Icons.calendar_today_outlined, LibraryDesignSystem.folderBlue, '/modules/calendar'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Forge', Icons.build_outlined, LibraryDesignSystem.folderPurple, '/modules/forge'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Memories', Icons.photo_album_outlined, LibraryDesignSystem.folderOrange, '/modules/memories'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Research', Icons.science_outlined, LibraryDesignSystem.folderBlue, '/modules/research'),
                    SizedBox(width: 12),
                    _buildModuleCard(context, 'Startup', Icons.rocket_launch_outlined, LibraryDesignSystem.folderOrange, '/modules/startup'),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(child: SizedBox(height: LibraryDesignSystem.spacingL)),

            // All Files section header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: LibraryDesignSystem.spacingL,
                  right: LibraryDesignSystem.spacingL,
                  bottom: LibraryDesignSystem.spacingM,
                ),
                child: Text(
                  'All Files',
                  style: LibraryDesignSystem.sectionHeader,
                ),
              ),
            ),

            // All Files items
            captureListAsync.when(
              data: (allCaptures) {
                final captures = allCaptures.where((c) {
                  if (_selectedFilter == 'all') return true;
                  if (_selectedFilter == 'files') return c.type == 'file' || c.type == 'pdf' || c.type == 'doc' || c.type == 'text' || c.type == 'page';
                  if (_selectedFilter == 'images') return c.type == 'image';
                  if (_selectedFilter == 'videos') return c.type == 'video';
                  if (_selectedFilter == 'audio') return c.type == 'voice' || c.type == 'audio';
                  return false;
                }).toList();

                if (captures.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: LibraryDesignSystem.spacingXL),
                      child: Center(
                        child: Text(
                          'No files found.',
                          style: LibraryDesignSystem.subtitle,
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: LibraryDesignSystem.spacingL,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final capture = captures[index];
                        final cType = capture.type ?? 'unknown';
                        return Padding(
                          padding: EdgeInsets.only(bottom: LibraryDesignSystem.spacingS),
                          child: RecentItem(
                            capture: capture,
                            title: capture.title ?? capture.content,
                            subtitle: cType.isNotEmpty ? '${cType[0].toUpperCase()}${cType.substring(1)}' : 'Unknown',
                            timeAgo: _formatTimeAgo(capture.createdAt),
                            icon: _getIconForType(cType),
                            iconColor: _getColorForType(cType),
                            onTap: () {
                              if (['image', 'video', 'file', 'voice', 'audio'].contains(cType)) {
                                context.push('/capture/viewer', extra: capture);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: LibraryDesignSystem.surfaceLight,
                                    title: Text(capture.title ?? 'Capture', style: LibraryDesignSystem.spaceCardTitle),
                                    content: Text(capture.content, style: LibraryDesignSystem.subtitle),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text('Close', style: TextStyle(color: LibraryDesignSystem.accentOrange)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                      childCount: captures.length,
                    ),
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator(color: LibraryDesignSystem.accentOrange)),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error loading captures: $err', style: LibraryDesignSystem.subtitle)),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: LibraryDesignSystem.spacingXL)),

            // Recent section header
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => setState(() => _isRecentsExpanded = !_isRecentsExpanded),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: LibraryDesignSystem.spacingL,
                    right: LibraryDesignSystem.spacingL,
                    bottom: LibraryDesignSystem.spacingM,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Files',
                        style: LibraryDesignSystem.sectionHeader,
                      ),
                      Icon(
                        _isRecentsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 20,
                        color: LibraryDesignSystem.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Recent items
            if (!_isRecentsExpanded) SliverToBoxAdapter(child: SizedBox.shrink()) else captureListAsync.when(
              data: (allCaptures) {
                final captures = allCaptures.where((c) {
                  if (_selectedFilter == 'all') return true;
                  if (_selectedFilter == 'files') return c.type == 'file' || c.type == 'pdf' || c.type == 'doc' || c.type == 'text' || c.type == 'page';
                  if (_selectedFilter == 'images') return c.type == 'image';
                  if (_selectedFilter == 'videos') return c.type == 'video';
                  if (_selectedFilter == 'audio') return c.type == 'voice' || c.type == 'audio';
                  return false;
                }).take(5).toList();

                if (captures.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: LibraryDesignSystem.spacingXL),
                      child: Center(
                        child: Text(
                          'No recent items found.',
                          style: LibraryDesignSystem.subtitle,
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: LibraryDesignSystem.spacingL,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final capture = captures[index];
                        final cType = capture.type ?? 'unknown';
                        return Padding(
                          padding: EdgeInsets.only(bottom: LibraryDesignSystem.spacingS),
                          child: RecentItem(
                            capture: capture,
                            title: capture.title ?? capture.content,
                            subtitle: cType.isNotEmpty ? '${cType[0].toUpperCase()}${cType.substring(1)}' : 'Unknown',
                            timeAgo: _formatTimeAgo(capture.createdAt),
                            icon: _getIconForType(cType),
                            iconColor: _getColorForType(cType),
                            onTap: () {
                              if (['image', 'video', 'file', 'voice', 'audio'].contains(cType)) {
                                context.push('/capture/viewer', extra: capture);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: LibraryDesignSystem.surfaceLight,
                                    title: Text(capture.title ?? 'Capture', style: LibraryDesignSystem.spaceCardTitle),
                                    content: Text(capture.content, style: LibraryDesignSystem.subtitle),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text('Close', style: TextStyle(color: LibraryDesignSystem.accentOrange)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                      childCount: captures.length,
                    ),
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator(color: LibraryDesignSystem.accentOrange)),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error loading captures: $err', style: LibraryDesignSystem.subtitle)),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: LibraryDesignSystem.spacingXL)),


            SliverToBoxAdapter(child: SizedBox(height: LibraryDesignSystem.spacingL)),

            // Expandable sections
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: LibraryDesignSystem.spacingL,
                ),
                child: Column(
                  children: [

                    _buildExpandableSection(
                      'Spaces',
                      '1',
                      icon: Icons.space_dashboard_outlined,
                      onTap: () => context.push('/canvas-space'),
                    ),
                    SizedBox(height: LibraryDesignSystem.spacingS),
                    _buildExpandableSection('Tags', '0'),
                    SizedBox(height: LibraryDesignSystem.spacingS),
                    _buildExpandableSection('Shared with me', '0'),
                    SizedBox(height: LibraryDesignSystem.spacingS),
                    _buildExpandableSection('Archive', '0'),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String label, String count, {IconData icon = Icons.folder_open_outlined, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: LibraryDesignSystem.spacingM,
          vertical: LibraryDesignSystem.spacingM,
        ),
        decoration: BoxDecoration(
          color: LibraryDesignSystem.surface,
          borderRadius: BorderRadius.circular(LibraryDesignSystem.radiusM),
          border: Border.all(
            color: LibraryDesignSystem.borderDark,
            width: 1,
          ),
        ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: LibraryDesignSystem.textSecondary,
              ),
              SizedBox(width: LibraryDesignSystem.spacingM),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: LibraryDesignSystem.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: LibraryDesignSystem.textSecondary,
                ),
              ),
              SizedBox(width: LibraryDesignSystem.spacingM),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: LibraryDesignSystem.textSecondary,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildModuleCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: LibraryDesignSystem.surface,
          borderRadius: BorderRadius.circular(LibraryDesignSystem.radiusM),
          border: Border.all(color: LibraryDesignSystem.borderDark, width: 1),
        ),
        padding: EdgeInsets.all(LibraryDesignSystem.spacingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: LibraryDesignSystem.spacingS),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: LibraryDesignSystem.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
