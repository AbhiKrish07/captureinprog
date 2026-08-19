import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../models/capture.dart';
import 'capture_context_menu.dart';

class CaptureCard extends ConsumerStatefulWidget {
  final Capture capture;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CaptureCard({
    required this.capture,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  ConsumerState<CaptureCard> createState() => _CaptureCardState();
}

class _CaptureCardState extends ConsumerState<CaptureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kDurationNormal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () => showCaptureContextMenu(context, ref, widget.capture),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_controller.value * 0.02),
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: kSurfaceDark,
              borderRadius: BorderRadius.circular(kRadiusL),
              border: Border.all(
                color: _isHovered ? kAccentOrange : kBorderDark,
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: kAccentOrange.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                // CONTENT
                Padding(
                  padding: EdgeInsets.all(kSpacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TYPE BADGE
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: kSpacingS,
                          vertical: kSpacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: kAccentOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(kRadiusS),
                        ),
                        child: Text(
                          widget.capture.type?.toUpperCase() ?? 'UNKNOWN',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: kAccentOrange,
                          ),
                        ),
                      ),
                      SizedBox(height: kSpacingL),

                      // TITLE
                      Text(
                        widget.capture.title ?? 'Untitled',
                        style: Theme.of(context).textTheme.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: kSpacingM),

                      // PREVIEW
                      Expanded(
                        child: Text(
                          widget.capture.preview ?? widget.capture.content,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: kSpacingL),

                      // METADATA
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: kTextSecondary),
                          SizedBox(width: kSpacingS),
                          Text(
                            _formatDate(widget.capture.createdAt),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // MORE MENU BUTTON
                if (_isHovered)
                  Positioned(
                    top: kSpacingM,
                    right: kSpacingM,
                    child: GestureDetector(
                      onTap: () => showCaptureContextMenu(context, ref, widget.capture),
                      child: Container(
                        padding: EdgeInsets.all(kSpacingS),
                        decoration: BoxDecoration(
                          color: kSurfaceDark.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(kRadiusS),
                        ),
                        child: Icon(Icons.more_vert, size: 16, color: kTextSecondary),
                      ),
                    ),
                  ).animate().fadeIn(duration: kDurationFast),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}m ago';
  }
}
