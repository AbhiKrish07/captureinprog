// lib/widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import '../config/library_design_system.dart';
import '../screens/capture/bulk_import_screen.dart';

class CustomBottomNav extends StatefulWidget {
  final ValueChanged<int> onTabChanged;
  final int currentIndex;

  const CustomBottomNav({
    required this.onTabChanged,
    required this.currentIndex,
    super.key,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LibraryDesignSystem.background,
        border: Border(
          top: BorderSide(
            color: LibraryDesignSystem.borderDark,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem('Capture', Icons.auto_awesome_mosaic_outlined, 0),
            _buildNavItem('Library', Icons.folder_outlined, 1),
            _buildCenterButton(),
            _buildNavItem('AI Chat', Icons.auto_awesome, 3),
            _buildNavItem('Profile', Icons.person_outline, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, int index) {
    final isActive = widget.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.onTabChanged(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive
                ? LibraryDesignSystem.accentOrange
                : LibraryDesignSystem.textSecondary,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive
                  ? LibraryDesignSystem.accentOrange
                  : LibraryDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BulkImportScreen()),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: LibraryDesignSystem.accentOrange,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          size: 24,
          color: LibraryDesignSystem.textPrimary,
        ),
      ),
    );
  }
}
