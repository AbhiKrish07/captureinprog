import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../providers/capture_provider.dart';
import '../../models/capture.dart';
import '../../providers/theme_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _activeFilter = 'All';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(currentSearchQueryProvider.notifier).set(val);
    });
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  bool _matchesFilter(Capture capture, String filter) {
    if (filter == 'All') return true;
    if (filter == 'Notes' && capture.type == 'text') return true;
    if (filter == 'Files' && (capture.type == 'file' || capture.type == 'image' || capture.type == 'video')) return true;
    if (filter == 'Links' && capture.type == 'link') return true;
    if (filter == 'Voice' && capture.type == 'voice') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider);
    final query = ref.watch(currentSearchQueryProvider);
    final isSearching = query.isNotEmpty;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SearchHeader(),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Search',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 20),
            _SearchBar(
              onChanged: _onSearchChanged,
            ),
            SizedBox(height: 24),
            _SearchFilters(
              activeFilter: _activeFilter,
              onFilterChanged: (f) => setState(() => _activeFilter = f),
            ),
            SizedBox(height: 24),
            Expanded(
              child: isSearching 
                  ? _buildSearchResults()
                  : _buildRecentSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final resultsAsync = ref.watch(searchResultsProvider);
    
    return resultsAsync.when(
      data: (captures) {
        final filtered = captures.where((c) => _matchesFilter(c, _activeFilter)).toList();
        
        if (filtered.isEmpty) {
          return Center(
            child: Text('No results found.', style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final capture = filtered[index];
            return _RecentSearchItem(
              query: capture.title ?? capture.content,
              time: _formatTimeAgo(capture.createdAt),
              onTap: () {
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
              },
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.orange)),
      error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: AppColors.textSecondary))),
    );
  }

  Widget _buildRecentSearches() {
    final captureListAsync = ref.watch(captureListNotifierProvider);
    
    return captureListAsync.when(
      data: (captures) {
        final filtered = captures.where((c) => _matchesFilter(c, _activeFilter)).take(5).toList();
        if (filtered.isEmpty) return SizedBox.shrink();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: AppColors.textTertiary),
                        SizedBox(width: 8),
                        Text('Recent captures', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: filtered.map((capture) {
                    return _RecentSearchItem(
                      query: capture.title ?? capture.content,
                      time: _formatTimeAgo(capture.createdAt),
                      onTap: () {
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
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (err, stack) => SizedBox.shrink(),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1.5),
                shape: BoxShape.circle,
              ),
              // Simplified header mock
              child: Icon(Icons.person, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.textTertiary, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search anything in plain English...',
                  hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFilters extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const _SearchFilters({required this.activeFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterChip(icon: Icons.grid_view_rounded, label: 'All', isActive: activeFilter == 'All', onTap: () => onFilterChanged('All')),
          _FilterChip(icon: Icons.description_outlined, label: 'Notes', isActive: activeFilter == 'Notes', onTap: () => onFilterChanged('Notes')),
          _FilterChip(icon: Icons.folder_outlined, label: 'Files', isActive: activeFilter == 'Files', onTap: () => onFilterChanged('Files')),
          _FilterChip(icon: Icons.link, label: 'Links', isActive: activeFilter == 'Links', onTap: () => onFilterChanged('Links')),
          _FilterChip(icon: Icons.graphic_eq, label: 'Voice', isActive: activeFilter == 'Voice', onTap: () => onFilterChanged('Voice')),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _FilterChip({required this.icon, required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: AppColors.orange.withValues(alpha: 0.5), width: 1.5)
              : Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? AppColors.orange : AppColors.textSecondary),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  final String query;
  final String time;
  final VoidCallback? onTap;

  const _RecentSearchItem({required this.query, required this.time, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: AppColors.textTertiary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                query,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 12),
            Text(time, style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
            SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
