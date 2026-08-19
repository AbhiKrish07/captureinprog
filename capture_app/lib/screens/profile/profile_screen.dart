import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage your account, preferences\nand settings.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _HeaderIcon(icon: Icons.notifications_none_rounded),
                        SizedBox(width: 8),
                        _HeaderIcon(icon: Icons.settings_outlined, hasBorder: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // User card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _UserCard(),
              ),
            ),

            // Pro banner
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: _ProBanner(),
              ),
            ),

            // Account section
            SliverToBoxAdapter(
              child: _SettingsSection(
                title: 'Account',
                items: [
                  _SettingsItem(icon: Icons.person_outline, label: 'Personal Information'),
                  _SettingsItem(icon: Icons.email_outlined, label: 'Email & Password'),
                  _SettingsItem(icon: Icons.credit_card, label: 'Billing & Subscription'),
                  _SettingsItem(icon: Icons.access_time, label: 'Usage'),
                ],
              ),
            ),

            // Preferences section
            SliverToBoxAdapter(
              child: _SettingsSection(
                title: 'Preferences',
                items: [
                  _SettingsItem(icon: Icons.contrast, label: 'Appearance', value: 'System'),
                  _SettingsItem(icon: Icons.edit_note, label: 'Editor'),
                  _SettingsItem(icon: Icons.dashboard_outlined, label: 'Default View', value: 'Document'),
                  _SettingsItem(icon: Icons.auto_awesome, label: 'AI Preferences'),
                  _SettingsItem(icon: Icons.notifications_none, label: 'Notifications'),
                  _SettingsItem(icon: Icons.language, label: 'Language', value: 'English'),
                ],
              ),
            ),

            // Data & Security section
            SliverToBoxAdapter(
              child: _SettingsSection(
                title: 'Data & Security',
                items: [
                  _SettingsItem(icon: Icons.cloud_outlined, label: 'Cloud & Storage'),
                  _SettingsItem(icon: Icons.download_outlined, label: 'Import'),
                  _SettingsItem(icon: Icons.upload_outlined, label: 'Export'),
                  _SettingsItem(icon: Icons.shield_outlined, label: 'Privacy'),
                  _SettingsItem(icon: Icons.link, label: 'Connected Apps'),
                ],
              ),
            ),

            // Log out button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _LogoutButton(),
              ),
            ),

            // Version info
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Center(
                  child: Text(
                    'App version 1.2.4 · Build 1242',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatefulWidget {
  final IconData icon;
  final bool hasBorder;

  const _HeaderIcon({required this.icon, this.hasBorder = false});

  @override
  State<_HeaderIcon> createState() => _HeaderIconState();
}

class _HeaderIconState extends State<_HeaderIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: widget.hasBorder
                ? Border.all(color: AppColors.border, width: 0.5)
                : null,
          ),
          child: Icon(widget.icon, size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 2),
                  ),
                  child: Icon(Icons.g_mobiledata, size: 12, color: LibraryDesignSystem.textPrimary),
                ),
              ),
            ],
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Arjun Sharma',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.orange.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'Pro',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'arjun@capture.app',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 11, color: AppColors.textTertiary),
                    SizedBox(width: 4),
                    Text(
                      'Member since Sep 2024',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ProBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.violet.withValues(alpha: 0.08),
            AppColors.orange.withValues(alpha: 0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.violet.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.workspace_premium,
              size: 20,
              color: AppColors.violet,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re on Capture Pro',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Unlock more AI usage, bigger uploads\nand advanced features.',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Manage Plan',
              style: TextStyle(
                color: LibraryDesignSystem.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Divider(
                    color: AppColors.borderSubtle,
                    height: 0.5,
                    indent: 48,
                  ),
              ],
            ],
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

class _SettingsItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
  });

  @override
  State<_SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<_SettingsItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        color: _pressed ? AppColors.cardHover : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(widget.icon, size: 20, color: AppColors.textSecondary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (widget.value != null) ...[
              Text(
                widget.value!,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _pressed ? AppColors.cardHover : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 18, color: AppColors.orange),
            SizedBox(width: 8),
            Text(
              'Log out',
              style: TextStyle(
                color: AppColors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}