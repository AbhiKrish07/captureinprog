import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../theme/app_colors.dart';

import '../../core/modules_mocks.dart';
import '../../models/modules_models.dart';
import '../../widgets/modules_widgets.dart';

class StudyModuleScreen extends StatefulWidget {
  const StudyModuleScreen({super.key});
  @override
  State<StudyModuleScreen> createState() => _StudyModuleScreenState();
}

class _StudyModuleScreenState extends State<StudyModuleScreen> {
  final _db = ZenDatabase();
  
  // Pomodoro state
  int _pomodoroMinutes = 25;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  Timer? _timer;
  String _currentSubject = '';
  
  // Stats
  int _streak = 0;
  int _todayMinutes = 0;
  List<StudySession> _recentSessions = [];
  bool _loading = true;

  final List<String> _subjects = ['Math', 'Physics', 'CS', 'English', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final streak = await _db.getStudyStreak();
    final today = await _db.getTotalStudyMinutesToday();
    final sessions = await _db.getStudySessions(days: 7);
    if (mounted) {
      setState(() {
        _streak = streak;
        _todayMinutes = today;
        _recentSessions = sessions;
        _loading = false;
      });
    }
  }

  void _startPomodoro() {
    if (_currentSubject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select a subject first', style: GoogleFonts.inter()), backgroundColor: AppColors.surface),
      );
      return;
    }
    
    HapticFeedback.mediumImpact();
    setState(() {
      _secondsRemaining = _pomodoroMinutes * 60;
      _isRunning = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _completeSession();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _stopPomodoro() {
    _timer?.cancel();
    final elapsed = _pomodoroMinutes * 60 - _secondsRemaining;
    if (elapsed > 60) { // At least 1 minute
      _saveSession(elapsed ~/ 60);
    }
    setState(() { _isRunning = false; _secondsRemaining = 0; });
  }

  void _completeSession() {
    HapticFeedback.heavyImpact();
    _saveSession(_pomodoroMinutes);
    setState(() { _isRunning = false; _secondsRemaining = 0; });
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('🎉 Session Complete!', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('$_pomodoroMinutes minutes of $_currentSubject logged.', style: GoogleFonts.inter(color: AppColors.textMuted)),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(c), child: Text('Nice'))],
      ),
    );
  }

  Future<void> _saveSession(int minutes) async {
    final session = StudySession(date: DateTime.now(), subject: _currentSubject, durationMinutes: minutes);
    await _db.insertStudySession(session);
    _loadData();
  }

  String get _timerDisplay {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Study', style: GoogleFonts.inter(fontWeight: FontWeight.w800))),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.orange))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsRow(),
                  SizedBox(height: 16),
                  _buildPomodoroCard(),
                  SizedBox(height: 16),
                  _buildRecentSessions(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: MetricCard(title: 'STREAK', value: '$_streak 🔥', icon: Icons.local_fire_department, color: AppColors.yellow)),
        SizedBox(width: 8),
        Expanded(child: MetricCard(title: 'TODAY', value: '${_todayMinutes}m', icon: Icons.timer, color: AppColors.green)),
      ],
    );
  }

  Widget _buildPomodoroCard() {
    return GlassContainer(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(24),
      borderColor: _isRunning ? AppColors.orange.withValues(alpha: 0.3) : null,
      child: Column(
        children: [
          Text('POMODORO', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, letterSpacing: 2, fontWeight: FontWeight.w700)),
          SizedBox(height: 16),
          // Timer display
          Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _isRunning ? AppColors.orange : AppColors.border, width: 3),
              boxShadow: _isRunning ? [BoxShadow(color: AppColors.orange.withValues(alpha: 0.2), blurRadius: 30)] : null,
            ),
            child: Center(
              child: Text(
                _isRunning ? _timerDisplay : '$_pomodoroMinutes:00',
                style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Duration selector
          if (!_isRunning) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [15, 25, 45, 60].map((d) {
                final sel = _pomodoroMinutes == d;
                return GestureDetector(
                  onTap: () => setState(() => _pomodoroMinutes = d),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: sel ? AppColors.orange.withValues(alpha: 0.15) : Colors.transparent,
                      border: Border.all(color: sel ? AppColors.orange : AppColors.border),
                    ),
                    child: Text('${d}m', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? AppColors.orange : AppColors.textMuted)),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            // Subject selector
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _subjects.map((s) {
                final sel = _currentSubject == s;
                return GestureDetector(
                  onTap: () => setState(() => _currentSubject = s),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: sel ? AppColors.green.withValues(alpha: 0.12) : Colors.transparent,
                      border: Border.all(color: sel ? AppColors.green : AppColors.border),
                    ),
                    child: Text(s, style: GoogleFonts.inter(fontSize: 12, color: sel ? AppColors.green : AppColors.textMuted, fontWeight: sel ? FontWeight.w700 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRunning ? _stopPomodoro : _startPomodoro,
              style: ElevatedButton.styleFrom(backgroundColor: _isRunning ? AppColors.red : AppColors.orange),
              child: Text(_isRunning ? 'Stop' : 'Start Focus', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions() {
    if (_recentSessions.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'RECENT SESSIONS', icon: Icons.history_rounded, color: AppColors.orange),
        ..._recentSessions.take(10).map((s) => Container(
          margin: EdgeInsets.only(bottom: 6),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.03), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Icon(Icons.book_rounded, size: 16, color: AppColors.green),
              SizedBox(width: 10),
              Expanded(child: Text(s.subject, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
              Text('${s.durationMinutes}m', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
            ],
          ),
        )),
      ],
    );
  }
}