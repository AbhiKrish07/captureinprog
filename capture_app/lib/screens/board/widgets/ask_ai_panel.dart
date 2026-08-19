import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AskAIPanel extends StatefulWidget {
  final VoidCallback onClose;

  const AskAIPanel({super.key, required this.onClose});

  @override
  State<AskAIPanel> createState() => _AskAIPanelState();
}

class _AskAIPanelState extends State<AskAIPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: 200,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: AppColors.violet),
                      SizedBox(width: 6),
                      Text(
                        'Ask AI',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Icon(Icons.close, size: 16, color: AppColors.textTertiary),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'What would you like to\ndo on this canvas?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 14),

              // Options
              _AIOption(
                icon: Icons.summarize_outlined,
                label: 'Summarize\nthis board',
                color: AppColors.violet,
              ),
              _AIOption(
                icon: Icons.account_tree_outlined,
                label: 'Generate a\nmind map',
                color: AppColors.violet,
              ),
              _AIOption(
                icon: Icons.lightbulb_outline,
                label: 'Improve\nthis idea',
                color: AppColors.violet,
              ),
              _AIOption(
                icon: Icons.search,
                label: 'Find related\ninsights',
                color: AppColors.violet,
              ),
              _AIOption(
                icon: Icons.more_horiz,
                label: 'More options',
                color: AppColors.textSecondary,
              ),

              SizedBox(height: 14),
              Divider(color: AppColors.border, height: 1),
              SizedBox(height: 12),

              // Context
              Text(
                'Context',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              _ContextRow(icon: Icons.crop_square, label: 'This canvas', trailing: '▼'),
              _ContextRow(icon: Icons.link, label: '2 linked spaces', trailing: '8'),
              _ContextRow(icon: Icons.insert_drive_file_outlined, label: '3 files', trailing: '3'),
              _ContextRow(icon: Icons.mic, label: '2 voice notes', trailing: '2'),

              SizedBox(height: 14),
              Divider(color: AppColors.border, height: 1),
              SizedBox(height: 12),

              // Recent prompts
              Text(
                'Recent prompts',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              _PromptItem(label: 'Make this a roadmap'),
              _PromptItem(label: 'What are the risks?'),
              _PromptItem(label: 'Turn this into a doc'),
            ],
          ),
        ),
      ),
    );
  }
}

class _AIOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AIOption({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_AIOption> createState() => _AIOptionState();
}

class _AIOptionState extends State<_AIOption> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          margin: EdgeInsets.only(bottom: 4),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, size: 16, color: widget.color),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String trailing;

  const _ContextRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptItem extends StatelessWidget {
  final String label;

  const _PromptItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          height: 1.4,
        ),
      ),
    );
  }
}