import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';

import '../../core/modules_mocks.dart';
import '../../models/modules_models.dart';
import '../../widgets/modules_widgets.dart';

class AssignmentsModuleScreen extends StatefulWidget {
  const AssignmentsModuleScreen({super.key});
  @override
  State<AssignmentsModuleScreen> createState() => _AssignmentsModuleScreenState();
}

class _AssignmentsModuleScreenState extends State<AssignmentsModuleScreen> {
  final _db = ZenDatabase();
  List<Assignment> _assignments = [];
  double _gpa = 0;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final assignments = await _db.getAssignments();
    final gpa = await _db.calculateGPA();
    if (mounted) setState(() { _assignments = assignments; _gpa = gpa; _loading = false; });
  }

  Future<void> _addAssignment() async {
    final titleCtrl = TextEditingController();
    final courseCtrl = TextEditingController();
    DateTime dueDate = DateTime.now().add(Duration(days: 7));

    await showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, ss) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: AppColors.textMuted.withValues(alpha: 0.3)))),
            SizedBox(height: 20),
            Text('New Assignment', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            SizedBox(height: 16),
            TextField(controller: titleCtrl, autofocus: true, style: GoogleFonts.inter(color: AppColors.textPrimary), decoration: InputDecoration(hintText: 'Assignment title')),
            SizedBox(height: 8),
            TextField(controller: courseCtrl, style: GoogleFonts.inter(color: AppColors.textPrimary), decoration: InputDecoration(hintText: 'Course name')),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: dueDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 365)));
                if (d != null) ss(() => dueDate = d);
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.textMuted), SizedBox(width: 10),
                  Text('Due: ${DateFormat('MMM d, y').format(dueDate)}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
                ]),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || courseCtrl.text.isEmpty) return;
                await _db.insertAssignment(Assignment(title: titleCtrl.text.trim(), course: courseCtrl.text.trim(), dueDate: dueDate));
                if (context.mounted) Navigator.pop(context);
                _loadData();
              },
              child: Text('Add Assignment'),
            )),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Assignments', style: GoogleFonts.inter(fontWeight: FontWeight.w800)), actions: [IconButton(icon: Icon(Icons.add), onPressed: _addAssignment)]),
      body: _loading ? Center(child: CircularProgressIndicator(color: AppColors.orange)) : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          // GPA card
          GlassContainer(margin: EdgeInsets.zero, borderColor: AppColors.cyan.withValues(alpha: 0.2), child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('GPA', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, letterSpacing: 1.5)),
              Text(_gpa.toStringAsFixed(2), style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.cyan)),
            ]),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: (_gpa >= 3.5 ? AppColors.green : _gpa >= 3.0 ? AppColors.yellow : AppColors.red).withValues(alpha: 0.12)),
              child: Text(_gpa >= 3.5 ? 'Excellent' : _gpa >= 3.0 ? 'Good' : 'Needs Work', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: _gpa >= 3.5 ? AppColors.green : _gpa >= 3.0 ? AppColors.yellow : AppColors.red)),
            ),
          ])),
          SizedBox(height: 16),
          if (_assignments.isEmpty)
            EmptyState(icon: Icons.assignment, title: 'No Assignments', subtitle: 'Track your coursework and grades', color: AppColors.cyan)
          else
            ..._assignments.map((a) {
              final daysLeft = a.timeUntilDue.inDays;
              final urgencyColor = a.isOverdue ? AppColors.red : daysLeft <= 3 ? AppColors.yellow : AppColors.green;
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.04), border: Border.all(color: urgencyColor.withValues(alpha: 0.2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(a.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                    if (a.grade != null) Text('${(a.percentage?.toStringAsFixed(0) ?? "0")}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.cyan)),
                  ]),
                  SizedBox(height: 4),
                  Row(children: [
                    Text(a.course, style: GoogleFonts.inter(fontSize: 9, color: AppColors.orange)),
                    Spacer(),
                    Text(a.isOverdue ? 'OVERDUE' : '${daysLeft}d left', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: urgencyColor)),
                  ]),
                ]),
              );
            }),
        ]),
      ),
    );
  }
}