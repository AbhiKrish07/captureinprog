import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

import '../../core/modules_mocks.dart';
import '../../models/modules_models.dart';
import '../../widgets/modules_widgets.dart';

class MoodModuleScreen extends StatefulWidget {
  const MoodModuleScreen({super.key});
  @override
  State<MoodModuleScreen> createState() => _MoodModuleScreenState();
}

class _MoodModuleScreenState extends State<MoodModuleScreen> {
  final _db = ZenDatabase();
  List<Mood> _history = [];
  Mood? _today;
  double _avgEnergy = 5;
  bool _loading = true;

  // Check-in state
  int _moodScore = 5;
  int _energyLevel = 5;
  final _notesCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final history = await _db.getMoodHistory(days: 30);
    final today = await _db.getTodaysMood();
    final avg = await _db.getAverageEnergy(days: 7);
    if (mounted) setState(() { _history = history; _today = today; _avgEnergy = avg; _loading = false; });
  }

  Future<void> _checkIn() async {
    HapticFeedback.mediumImpact();
    final entry = Mood(date: DateTime.now(), moodScore: _moodScore, energyLevel: _energyLevel, notes: _notesCtrl.text.trim());
    await _db.insertMood(entry);
    _notesCtrl.clear();
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-in saved! ${entry.moodEmoji}', style: GoogleFonts.inter()), backgroundColor: AppColors.surface),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Mood & Energy', style: GoogleFonts.inter(fontWeight: FontWeight.w800))),
      body: _loading ? Center(child: CircularProgressIndicator(color: AppColors.orange)) : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          // Stats row
          Row(children: [
            Expanded(child: MetricCard(title: '7-DAY ENERGY', value: _avgEnergy.toStringAsFixed(1), icon: Icons.bolt, color: AppColors.yellow, subtitle: '/10')),
            SizedBox(width: 8),
            Expanded(child: MetricCard(
              title: 'TODAY',
              value: _today != null ? '${_today!.moodEmoji} ${_today!.moodScore}/10' : 'Not checked in',
              icon: Icons.mood, color: AppColors.orange,
            )),
          ]),
          SizedBox(height: 16),
          // Check-in card
          GlassContainer(
            margin: EdgeInsets.zero,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_today != null ? 'UPDATE CHECK-IN' : 'DAILY CHECK-IN', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
              SizedBox(height: 16),
              // Mood slider
              Text('How are you feeling?', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              Row(children: [
                Text('😢', style: TextStyle(fontSize: 20)),
                Expanded(child: SliderTheme(
                  data: SliderThemeData(activeTrackColor: AppColors.orange, thumbColor: AppColors.orange, inactiveTrackColor: AppColors.textMuted, overlayColor: AppColors.orange.withValues(alpha: 0.1)),
                  child: Slider(value: _moodScore.toDouble(), min: 1, max: 10, divisions: 9, label: '$_moodScore', onChanged: (v) => setState(() => _moodScore = v.round())),
                )),
                Text('🌟', style: TextStyle(fontSize: 20)),
              ]),
              SizedBox(height: 8),
              // Energy slider
              Text('Energy level?', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              Row(children: [
                Text('😴', style: TextStyle(fontSize: 20)),
                Expanded(child: SliderTheme(
                  data: SliderThemeData(activeTrackColor: AppColors.yellow, thumbColor: AppColors.yellow, inactiveTrackColor: AppColors.textMuted, overlayColor: AppColors.yellow.withValues(alpha: 0.1)),
                  child: Slider(value: _energyLevel.toDouble(), min: 1, max: 10, divisions: 9, label: '$_energyLevel', onChanged: (v) => setState(() => _energyLevel = v.round())),
                )),
                Text('⚡', style: TextStyle(fontSize: 20)),
              ]),
              SizedBox(height: 8),
              TextField(controller: _notesCtrl, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13), maxLines: 2, decoration: InputDecoration(hintText: 'Notes (optional)')),
              SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _checkIn, child: Text('Save Check-in'))),
            ]),
          ),
          SizedBox(height: 16),
          // History
          SectionHeader(title: 'HISTORY', icon: Icons.bar_chart, color: AppColors.orange),
          if (_history.isEmpty)
            EmptyState(icon: Icons.mood, title: 'No History', subtitle: 'Start checking in daily', color: AppColors.orange)
          else
            ..._history.take(14).map((m) => Container(
              margin: EdgeInsets.only(bottom: 6),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.03), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Text(m.moodEmoji, style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${m.date.month}/${m.date.day} · Mood ${m.moodScore}/10', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  if (m.notes.isNotEmpty) Text(m.notes, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                Text('${m.energyEmoji} ${m.energyLevel}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.yellow)),
              ]),
            )),
        ]),
      ),
    );
  }
}