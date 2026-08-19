import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../config/design_system.dart';

class CheckboxItem extends StatefulWidget {
  final String text;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const CheckboxItem({
    super.key,
    required this.text,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<CheckboxItem> createState() => _CheckboxItemState();
}

class _CheckboxItemState extends State<CheckboxItem> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isChecked = !_isChecked;
          });
          widget.onChanged?.call(_isChecked);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _isChecked ? DesignSystem.accentOrange : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _isChecked ? DesignSystem.accentOrange : DesignSystem.textSecondary,
                  width: 1.5,
                ),
              ),
              child: _isChecked
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: DesignSystem.backgroundDark,
                    )
                  : null,
            ),
            const SizedBox(width: DesignSystem.spacingM),
            Expanded(
              child: Text(
                widget.text,
                style: DesignSystem.bodyLarge.copyWith(
                  color: DesignSystem.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddItemButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AddItemButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.plus,
              size: 18,
              color: DesignSystem.textSecondary,
            ),
            const SizedBox(width: DesignSystem.spacingM),
            Text(
              text,
              style: DesignSystem.bodyLarge.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
