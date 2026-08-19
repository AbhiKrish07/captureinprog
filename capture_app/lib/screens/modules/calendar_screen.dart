import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';

import '../../core/modules_mocks.dart';
import '../../models/modules_models.dart';
import '../../widgets/modules_widgets.dart';

class CalendarModuleScreen extends StatefulWidget {
  const CalendarModuleScreen({super.key});
  @override
  State<CalendarModuleScreen> createState() => _CalendarModuleScreenState();
}

class _CalendarModuleScreenState extends State<CalendarModuleScreen> {
  final _db = ZenDatabase();
  List<CalendarEvent> _events = [];
  bool _loading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final end = start.add(Duration(days: 1));
    final events = await _db.getEvents(from: start, to: end);
    if (mounted) setState(() { _events = events; _loading = false; });
  }

  Future<void> _addEvent() async {
    final titleCtrl = TextEditingController();
    String eventType = 'general';
    TimeOfDay startTime = TimeOfDay(hour: 10, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: 11, minute: 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: AppColors.textMuted.withValues(alpha: 0.3)))),
              SizedBox(height: 20),
              Text('New Event', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              SizedBox(height: 16),
              TextField(controller: titleCtrl, autofocus: true, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16), decoration: InputDecoration(hintText: 'Event title')),
              SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['general', 'meeting', 'class', 'deadline', 'social'].map((t) {
                  final sel = eventType == t;
                  return GestureDetector(
                    onTap: () => setModalState(() => eventType = t),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: sel ? AppColors.orange.withValues(alpha: 0.12) : Colors.transparent,
                        border: Border.all(color: sel ? AppColors.orange : AppColors.border),
                      ),
                      child: Text(t.toUpperCase(), style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: sel ? AppColors.orange : AppColors.textMuted)),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: startTime);
                        if (t != null) setModalState(() => startTime = t);
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Text('Start: ${startTime.format(context)}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: endTime);
                        if (t != null) setModalState(() => endTime = t);
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Text('End: ${endTime.format(context)}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final event = CalendarEvent(
                      title: titleCtrl.text.trim(),
                      eventType: eventType,
                      startTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, startTime.hour, startTime.minute),
                      endTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, endTime.hour, endTime.minute),
                    );
                    await _db.insertEvent(event);
                    await ZenNotifier().scheduleEventReminder(event);
                    if (context.mounted) Navigator.pop(context);
                    _loadEvents();
                  },
                  child: Text('Add Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Calendar', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: _addEvent)],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: AppColors.orange))
                : _events.isEmpty
                    ? EmptyState(icon: Icons.calendar_today, title: 'No Events', subtitle: 'Nothing scheduled for ${DateFormat('MMM d').format(_selectedDate)}', color: AppColors.textMuted)
                    : _buildTimelineView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: 24,
      itemBuilder: (context, hour) {
        final hourEvents = _events.where((e) => e.startTime.hour == hour).toList();
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Time label
              SizedBox(
                width: 50,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              // Vertical divider line
              Container(width: 1, color: AppColors.border.withValues(alpha: 0.5)),
              SizedBox(width: 12),
              // Events for this hour
              Expanded(
                child: Column(
                  children: hourEvents.map((e) => _buildEventTimelineCard(e)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventTimelineCard(CalendarEvent event) {
    final typeColors = {'meeting': AppColors.textMuted, 'class': AppColors.green, 'deadline': AppColors.red, 'social': AppColors.yellow};
    final color = typeColors[event.eventType] ?? AppColors.orange;
    
    return GestureDetector(
      onTap: () => _showEventOptions(event),
      child: Container(
        margin: EdgeInsets.only(bottom: 8, top: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.02)],
          ),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(event.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                Text(event.eventType.toUpperCase(), style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 10, color: color.withValues(alpha: 0.7)),
                SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(event.startTime)} – ${DateFormat('HH:mm').format(event.endTime)}',
                  style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted),
                ),
                if (event.location.isNotEmpty) ...[
                  SizedBox(width: 8),
                  Icon(Icons.location_on_rounded, size: 10, color: AppColors.textMuted),
                  SizedBox(width: 2),
                  Text(event.location, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEventOptions(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(event.title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 12),
            Text('${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { 
                      Navigator.pop(c);
                      _editEvent(event);
                    },
                    icon: Icon(Icons.edit_rounded, size: 16),
                    label: Text('Edit'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: LibraryDesignSystem.textPrimary),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(c);
                      await _db.deleteEvent(event.id);
                      await ZenNotifier().cancelReminder(event.id);
                      _loadEvents();
                    },
                    icon: Icon(Icons.delete_rounded, size: 16),
                    label: Text('Remove'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _editEvent(CalendarEvent event) async {
    final titleCtrl = TextEditingController(text: event.title);
    String type = event.eventType;
    TimeOfDay start = TimeOfDay.fromDateTime(event.startTime);
    TimeOfDay end = TimeOfDay.fromDateTime(event.endTime);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text('Edit Event', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
               SizedBox(height: 16),
               TextField(controller: titleCtrl, style: GoogleFonts.inter(color: LibraryDesignSystem.textPrimary)),
               SizedBox(height: 20),
               // Repeat logic from _addEvent basically
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () async {
                     final updated = CalendarEvent(
                       id: event.id,
                       title: titleCtrl.text.trim(),
                       eventType: type,
                       startTime: DateTime(event.startTime.year, event.startTime.month, event.startTime.day, start.hour, start.minute),
                       endTime: DateTime(event.endTime.year, event.endTime.month, event.endTime.day, end.hour, end.minute),
                     );
                     await _db.insertEvent(updated);
                     if (context.mounted) Navigator.pop(context);
                     _loadEvents();
                   },
                   child: Text('Save Changes'),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 14,
        itemBuilder: (_, i) {
          final date = DateTime.now().add(Duration(days: i - 2));
          final sel = date.day == _selectedDate.day && date.month == _selectedDate.month;
          return GestureDetector(
            onTap: () { setState(() => _selectedDate = date); _loadEvents(); },
            child: Container(
              width: 48, margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: sel ? AppColors.orange.withValues(alpha: 0.15) : LibraryDesignSystem.textPrimary.withValues(alpha: 0.03),
                border: Border.all(color: sel ? AppColors.orange : AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(date).toUpperCase(), style: GoogleFonts.inter(fontSize: 8, color: sel ? AppColors.orange : AppColors.textMuted, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('${date.day}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: sel ? AppColors.orange : AppColors.textPrimary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}