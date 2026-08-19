import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TaskBlockWidget extends StatefulWidget {
  final String text;
  final bool initialIsChecked;

  const TaskBlockWidget({
    super.key,
    required this.text,
    this.initialIsChecked = false,
  });

  @override
  State<TaskBlockWidget> createState() => _TaskBlockWidgetState();
}

class _TaskBlockWidgetState extends State<TaskBlockWidget> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialIsChecked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _isChecked ? AppColors.orange : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _isChecked ? AppColors.orange : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: _isChecked
                  ? Icon(Icons.check, size: 14, color: LibraryDesignSystem.textPrimary)
                  : null,
            ),
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}