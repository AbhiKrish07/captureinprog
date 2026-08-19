import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class InputBar extends StatefulWidget {
  final String placeholder;
  final bool showSparkle;

  const InputBar({
    super.key,
    this.placeholder = 'Ask AI anything...',
    this.showSparkle = true,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  bool _isFocused = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isFocused ? AppColors.violet.withValues(alpha: 0.5) : AppColors.border,
              width: _isFocused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (widget.showSparkle) ...[
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.violet,
                ),
                SizedBox(width: 8),
              ],
              Expanded(
                child: Focus(
                  onFocusChange: (focused) {
                    setState(() => _isFocused = focused);
                  },
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              _CircleButton(
                icon: Icons.mic,
                color: AppColors.violet,
                size: 34,
                onTap: () {},
              ),
              SizedBox(width: 6),
              _CircleButton(
                icon: Icons.arrow_upward,
                color: AppColors.violet,
                size: 34,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.animateTo(0.9),
      onTapUp: (_) {
        _controller.animateTo(1.0);
        widget.onTap();
      },
      onTapCancel: () => _controller.animateTo(1.0),
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: widget.size * 0.5,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
