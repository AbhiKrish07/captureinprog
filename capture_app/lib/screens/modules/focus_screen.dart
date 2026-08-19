import 'package:capture_app/config/library_design_system.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

import '../../core/modules_mocks.dart';
import '../../models/modules_models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// FocusModeScreen — Zen Focus Engine (Redesigned with Zen Constellation)
/// Blocks social media, plays Spotify, enters Ambient Mode, grows Stars
/// ─────────────────────────────────────────────────────────────────────────────
class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});
  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with TickerProviderStateMixin {
  // ── Platform channels ──────────────────────────────────────────────
  static const _focusChannel = MethodChannel('com.zen/focus');

  // ── DB & Spotify ───────────────────────────────────────────────────
  final _db = ZenDatabase();
  final _spotify = SpotifyService();

  final _focusService = FocusService();
  StreamSubscription? _focusSub;
  StreamSubscription? _completeSub;

  // UI state for drafting session (before start)
  int _selectedMinutes = 25;
  String _subject = 'Deep Work';
  bool _sessionComplete = false;
  int _starsEarnedThisSession = 0;

  // Active state read from persistent service
  bool get _isRunning => _focusService.isRunning;
  int get _secondsRemaining => _focusService.secondsRemaining;
  
  // ── Stats state ────────────────────────────────────────────────────
  int _totalFocusedMins = 0;
  
  // ── Permissions & State ────────────────────────────────────────────
  bool _hasAccessibility = false;
  bool _hasOverlay = false;
  bool _blockedAppDetected = false;
  String? _blockedPackage;

  // ── Animations ─────────────────────────────────────────────────────
  late AnimationController _ringAnim;
  late AnimationController _pulseAnim;
  late AnimationController _shieldAnim;

  // ── Spotify mini state ─────────────────────────────────────────────
  Map<String, dynamic>? _track;
  Timer? _spotifyTimer;

  // Social media package → friendly name map
  final _socialNames = {
    'com.instagram.android': 'Instagram',
    'com.twitter.android': 'X (Twitter)',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.facebook.katana': 'Facebook',
    'com.snapchat.android': 'Snapchat',
    'com.reddit.frontpage': 'Reddit',
    'com.linkedin.android': 'LinkedIn',
    'com.pinterest': 'Pinterest',
    'com.whatsapp': 'WhatsApp',
    'org.telegram.messenger': 'Telegram',
    'com.discord': 'Discord',
  };

  final List<String> _subjects = [
    'Deep Work', 'CS', 'Math', 'Physics', 'Design', 'Reading', 'Writing'
  ];

  @override
  void initState() {
    super.initState();
    _focusChannel.setMethodCallHandler((call) async {
      if (call.method == 'onBlockedAppDetected') {
        final pkg = call.arguments as String?;
        if (pkg != null) _onBlockedAppDetected(pkg);
      }
    });
    _checkPermissions();
    _initAnimations();
    _loadSpotify();
    _loadStats();
    _focusSub = _focusService.onUpdate.listen((_) {
      if (mounted) setState(() {});
    });
    _completeSub = _focusService.onComplete.listen((_) {
      if (mounted) _onSessionComplete();
    });
  }

  Future<void> _loadStats() async {
    final sessions = await _db.getStudySessions();
    int total = 0;
    for (var s in sessions) {
      total += s.durationMinutes;
    }
    if (mounted) {
      setState(() {
        _totalFocusedMins = total;
        
      });
    }
  }

  void _initAnimations() {
    _ringAnim = AnimationController(vsync: this, duration: const Duration(seconds: 60));
    _pulseAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _shieldAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _focusSub?.cancel();
    _completeSub?.cancel();
    _spotifyTimer?.cancel();
    _ringAnim.dispose();
    _pulseAnim.dispose();
    _shieldAnim.dispose();
    super.dispose();
  }

  // ── Permissions ────────────────────────────────────────────────────
  Future<void> _checkPermissions() async {
    try {
      final hasA = await _focusChannel.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
      final hasO = await _focusChannel.invokeMethod<bool>('hasOverlayPermission') ?? false;
      if (mounted) {
        setState(() {
        _hasAccessibility = hasA;
        _hasOverlay = hasO;
      });
      }
    } catch (_) {}
  }

  // ── Spotify ────────────────────────────────────────────────────────
  Future<void> _loadSpotify() async {
    _spotifyTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final track = await _spotify.getCurrentTrack();
      if (mounted) setState(() => _track = track);
    });
  }

  Future<void> _openSpotify() async {
    try {
      await _focusChannel.invokeMethod('openSpotify');
    } catch (_) {}
  }

  // ── Focus Timer ────────────────────────────────────────────────────
  void _startFocus() {
    HapticFeedback.heavyImpact();
    _focusService.startFocus(_selectedMinutes, _subject);
    _focusChannel.invokeMethod('openSpotify');
    _ringAnim.forward(from: 0);
  }

  void _stopFocus() {
     _focusService.stopFocus();
     _ringAnim.stop();
  }

  void _onBlockedAppDetected(String pkg) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _blockedAppDetected = true;
      _blockedPackage = pkg;
    });
    _shieldAnim.forward(from: 0);
  }

  void _onSessionComplete() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    _saveSession();
    _focusService.stopFocus();
    setState(() {
      _sessionComplete = true;
      _blockedAppDetected = false;
      _starsEarnedThisSession = _selectedMinutes ~/ 15;
    });
    // Reload stats to update constellation
    _loadStats();
  }

  Future<void> _saveSession({int? minutes}) async {
    final m = minutes ?? _selectedMinutes;
    if (m < 1) return;
    await _db.insertStudySession(
      StudySession(date: DateTime.now(), subject: _subject, durationMinutes: m),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────
  String get _timerDisplay {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_selectedMinutes == 0) return 0;
    return 1.0 - (_secondsRemaining / (_selectedMinutes * 60));
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = _isRunning ? AppColors.orange : AppColors.blue;

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: LibraryDesignSystem.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ZEN FOCUS', style: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: 2, fontSize: 14)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient Glow
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) => Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width / 2 - 200,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    glowColor.withValues(alpha: _isRunning ? 0.2 + (_pulseAnim.value * 0.1) : 0.05),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        if (!_hasAccessibility || !_hasOverlay) _buildPermissionBanners(),
                        if (_blockedAppDetected) _buildBlockAlert(),
                        if (_sessionComplete) _buildCompleteBanner(),
                        
                        const SizedBox(height: 40),
                        
                        // Main Timer Ring
                        _buildTimerRing(glowColor),
                        
                        const SizedBox(height: 50),
                        
                        // Status & Setup
                        if (_isRunning) ...[
                          _buildStatusChips(),
                          const SizedBox(height: 40),
                        ],

                        // Gamification: Zen Constellation
                        if (!_isRunning && _totalFocusedMins > 0) ...[
                          _buildZenConstellation(),
                          const SizedBox(height: 24),
                        ],
                        
                        // Spotify Glassmorphic Player
                        _buildSpotifyMini(),
                        
                        const SizedBox(height: 24),
                        
                        // Blocked Apps Panel
                        _buildBlockedAppslist(),
                      ],
                    ),
                  ),
                ),
                _buildActionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerRing(Color glowColor) {
    return GestureDetector(
      onTap: () {
        if (!_isRunning) _showSetupBottomSheet();
      },
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) => Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: _isRunning ? 0.3 + (_pulseAnim.value * 0.2) : 0.05),
                blurRadius: 40,
                spreadRadius: _isRunning ? 10 + (_pulseAnim.value * 10) : 0,
              )
            ]
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(280, 280),
                painter: _FocusRingPainter(
                  progress: _progress,
                  color: glowColor,
                  pulse: _pulseAnim.value,
                  isRunning: _isRunning,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRunning ? _timerDisplay : '$_selectedMinutes:00',
                    style: GoogleFonts.inter(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: LibraryDesignSystem.textPrimary,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.2))
                    ),
                    child: Text(
                      _isRunning ? _subject.toUpperCase() : 'TAP TO SETUP',
                      style: GoogleFonts.inter(fontSize: 12, color: LibraryDesignSystem.textPrimary, letterSpacing: 2, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSetupBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set Duration', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: LibraryDesignSystem.textPrimary)),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [15, 25, 45, 60, 90, 120].map((d) {
                        final sel = _selectedMinutes == d;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => _selectedMinutes = d);
                            setState(() => _selectedMinutes = d);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: sel ? AppColors.blue.withValues(alpha: 0.2) : LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                              border: Border.all(color: sel ? AppColors.blue : Colors.transparent),
                            ),
                            child: Text('${d}m', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: sel ? AppColors.blue : AppColors.textMuted)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Select Subject', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: LibraryDesignSystem.textPrimary)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: _subjects.map((s) {
                      final sel = _subject == s;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => _subject = s);
                          setState(() => _subject = s);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: sel ? AppColors.orange.withValues(alpha: 0.2) : LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                            border: Border.all(color: sel ? AppColors.orange : Colors.transparent),
                          ),
                          child: Text(s, style: GoogleFonts.inter(fontSize: 13, color: sel ? AppColors.orange : AppColors.textMuted, fontWeight: FontWeight.w600)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _startFocus();
                      },
                      child: Text('ENTER FLOW', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: LibraryDesignSystem.textPrimary, letterSpacing: 2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildStatusChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip(Icons.shield_rounded, 'Apps Blocked', AppColors.orange),
        const SizedBox(width: 12),
        _chip(Icons.music_note_rounded, 'Spotify Active', AppColors.green),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZenConstellation() {
    // 1 star per 15 minutes of deep focus
    final starsCount = _totalFocusedMins ~/ 15;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.cyan),
                      const SizedBox(width: 8),
                      Text('ZEN CONSTELLATION', style: GoogleFonts.inter(fontSize: 12, color: AppColors.cyan, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text('$_totalFocusedMins MINS TOTAL', style: GoogleFonts.inter(fontSize: 10, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.54), fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              // The Galaxy Canvas
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.3),
                  border: Border.all(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05)),
                ),
                child: CustomPaint(
                  painter: _ZenGalaxyPainter(starsCount: starsCount),
                ),
              ),
              const SizedBox(height: 12),
              Text('You have earned $starsCount Zen Stars so far. Keep focusing to grow your galaxy!', style: GoogleFonts.inter(fontSize: 11, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.70))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockAlert() {
    final appName = _socialNames[_blockedPackage] ?? 'Social Media';
    return AnimatedBuilder(
      animation: _shieldAnim,
      builder: (context, child) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.red.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.5 + _shieldAnim.value * 0.5)),
          boxShadow: [
            BoxShadow(color: AppColors.red.withValues(alpha: 0.2), blurRadius: 20)
          ]
        ),
        child: Row(
          children: [
            Icon(Icons.block_rounded, color: AppColors.red, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$appName Blocked!', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.red)),
                  Text('Focus Mode is active. Get back to work.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [
          AppColors.green.withValues(alpha: 0.2),
          AppColors.blue.withValues(alpha: 0.1),
        ]),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Text('✨', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session Complete!', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.green)),
                Text('$_selectedMinutes mins of $_subject locked in. You earned $_starsEarnedThisSession stars!', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotifyMini() {
    return GestureDetector(
      onTap: _openSpotify,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF199A46)]),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF1DB954).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Icon(Icons.music_note_rounded, color: LibraryDesignSystem.textPrimary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _track != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_track!['title'] ?? '', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: LibraryDesignSystem.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(_track!['artist'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Connect Spotify', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: LibraryDesignSystem.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Tap to play focus sounds', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: LibraryDesignSystem.textPrimary, size: 20),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionBanners() {
    return Column(
      children: [
        if (!_hasAccessibility)
          GestureDetector(
            onTap: () async {
              await _focusChannel.invokeMethod('requestAccessibilityPermission');
              await Future.delayed(const Duration(seconds: 2));
              if (context.mounted) _checkPermissions();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.red.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings_accessibility_rounded, color: AppColors.red, size: 24),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enable Accessibility', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.red)),
                      Text('Required to block apps. Tap to enable.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  )),
                ],
              ),
            ),
          ),
        if (!_hasOverlay)
          GestureDetector(
            onTap: () async {
              await _focusChannel.invokeMethod('requestOverlayPermission');
              await Future.delayed(const Duration(seconds: 2));
              if (context.mounted) _checkPermissions();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.yellow.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.layers_rounded, color: AppColors.yellow, size: 24),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Allow Overlay', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.yellow)),
                      Text('Needed to show block screen on top of apps.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  )),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBlockedAppslist() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.block_flipped, size: 16, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.70)),
                      const SizedBox(width: 8),
                      Text('BLOCKED APPS', style: GoogleFonts.inter(fontSize: 12, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.70), letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  if (!_isRunning)
                    GestureDetector(
                      onTap: _addBlockedAppDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Text('+ ADD', style: GoogleFonts.inter(fontSize: 10, color: LibraryDesignSystem.textPrimary, fontWeight: FontWeight.w800)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _socialNames.entries.map((entry) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _isRunning ? AppColors.red.withValues(alpha: 0.1) : LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                    border: Border.all(color: _isRunning ? AppColors.red.withValues(alpha: 0.3) : Colors.transparent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _isRunning ? AppColors.red : LibraryDesignSystem.textPrimary)),
                      if (!_isRunning) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _socialNames.remove(entry.key)),
                          child: Icon(Icons.close_rounded, size: 14, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.54)),
                        ),
                      ],
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addBlockedAppDialog() async {
    final List<dynamic>? apps = await _focusChannel.invokeMethod('getInstalledApps');
    if (apps == null || !mounted) return;
    if (!context.mounted) return;

    final List<Map<String, String>> appList = apps.map((a) => {
      'name': a['name'].toString(),
      'package': a['package'].toString(),
    }).toList();

    showDialog(
      context: context,
      builder: (c) => _AppSelectionDialog(apps: appList),
    ).then((selected) {
      if (selected != null && selected is Map<String, String>) {
        setState(() {
          _socialNames[selected['package']!] = selected['name']!;
        });
      }
    });
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05))),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isRunning ? AppColors.surfaceElevated : AppColors.orange,
          foregroundColor: _isRunning ? AppColors.red : LibraryDesignSystem.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: _isRunning ? AppColors.red.withValues(alpha: 0.3) : Colors.transparent)
          ),
          elevation: _isRunning ? 0 : 8,
        ),
        onPressed: _isRunning ? _stopFocus : _showSetupBottomSheet,
        child: Text(
          _isRunning ? 'END SESSION EARLY' : 'START FOCUS',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
      ),
    );
  }
}

class _ZenGalaxyPainter extends CustomPainter {
  final int starsCount;

  _ZenGalaxyPainter({required this.starsCount});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed so constellation stays stable

    for (int i = 0; i < starsCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + random.nextDouble() * 2.5; // Random size
      
      final paint = Paint()
        ..color = LibraryDesignSystem.textPrimary.withValues(alpha: 0.6 + random.nextDouble() * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
      
      // Draw cross/twinkle for larger stars
      if (radius > 2.0) {
        final crossPaint = Paint()
          ..color = LibraryDesignSystem.textPrimary.withValues(alpha: 0.4)
          ..strokeWidth = 0.5;
        canvas.drawLine(Offset(x - 4, y), Offset(x + 4, y), crossPaint);
        canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), crossPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZenGalaxyPainter oldDelegate) {
    return oldDelegate.starsCount != starsCount;
  }
}

class _FocusRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double pulse;
  final bool isRunning;

  _FocusRingPainter({
    required this.progress,
    required this.color,
    required this.pulse,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Background track
    final trackPaint = Paint()
      ..color = LibraryDesignSystem.textPrimary.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (isRunning) {
      final sweepAngle = 2 * math.pi * progress;
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );

      // Glow effect on top of arc
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4 + (pulse * 0.2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.pulse != pulse ||
           oldDelegate.isRunning != isRunning;
  }
}

class _AppSelectionDialog extends StatefulWidget {
  final List<Map<String, String>> apps;
  const _AppSelectionDialog({required this.apps});
  @override
  State<_AppSelectionDialog> createState() => _AppSelectionDialogState();
}

class _AppSelectionDialogState extends State<_AppSelectionDialog> {
  String _search = '';
  
  @override
  Widget build(BuildContext context) {
    final filtered = widget.apps.where((a) => a['name']!.toLowerCase().contains(_search.toLowerCase())).toList();
    filtered.sort((a, b) => a['name']!.compareTo(b['name']!));

    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Select App to Block', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: LibraryDesignSystem.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              style: TextStyle(color: LibraryDesignSystem.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.54)),
                prefixIcon: Icon(Icons.search, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.54)),
                filled: true,
                fillColor: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, idx) {
                  final app = filtered[idx];
                  return ListTile(
                    title: Text(app['name']!, style: TextStyle(color: LibraryDesignSystem.textPrimary)),
                    subtitle: Text(app['package']!, style: TextStyle(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.38), fontSize: 10)),
                    onTap: () => Navigator.pop(context, app),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}