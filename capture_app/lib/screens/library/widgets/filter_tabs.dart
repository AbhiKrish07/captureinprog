// lib/screens/library/widgets/filter_tabs.dart
import 'package:flutter/material.dart';
import '../../../config/library_design_system.dart';

class FilterTabs extends StatefulWidget {
  final ValueChanged<String> onFilterChanged;

  const FilterTabs({required this.onFilterChanged, super.key});

  @override
  State<FilterTabs> createState() => _FilterTabsState();
}

class _FilterTabsState extends State<FilterTabs> {
  String _selectedFilter = 'all';

  final List<String> _filters = ['All', 'Files', 'Images', 'Videos', 'Audio'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter.toLowerCase();
          return Padding(
            padding: EdgeInsets.only(
              right: LibraryDesignSystem.spacingS,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter.toLowerCase());
                widget.onFilterChanged(_selectedFilter);
              },
              child: AnimatedContainer(
                duration: LibraryDesignSystem.durationFast,
                padding: EdgeInsets.symmetric(
                  horizontal: LibraryDesignSystem.spacingM,
                  vertical: LibraryDesignSystem.spacingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? LibraryDesignSystem.accentOrange
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    LibraryDesignSystem.radiusS,
                  ),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: LibraryDesignSystem.borderDark,
                          width: 1,
                        ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? LibraryDesignSystem.background
                        : LibraryDesignSystem.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
