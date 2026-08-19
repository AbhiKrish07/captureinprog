import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';

import '../../core/modules_mocks.dart';
import '../../../models/capture.dart';
import 'providers/module_providers.dart';
import '../../widgets/modules_widgets.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});
  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> with AutomaticKeepAliveClientMixin {
  final _brain = ZenBrain();
  
  bool _showCompleted = true;
  String _filter = 'all'; // all, critical, high, medium, low

  @override
  bool get wantKeepAlive => true;

  List<Capture> _getFilteredTasks(List<Capture> tasks) {
    List<Capture> filtered = _filter == 'all' 
        ? List<Capture>.from(tasks) 
        : tasks.where((t) => (t.metadata?['priority'] ?? 'medium') == _filter).toList();
        
    filtered.sort((a,b) {
      final aComp = a.metadata?['completed'] == true;
      final bComp = b.metadata?['completed'] == true;
      if (!aComp && bComp) return -1;
      if (aComp && !bComp) return 1;
      
      final aPri = a.metadata?['priority'] ?? 'medium';
      final bPri = b.metadata?['priority'] ?? 'medium';
      
      int c = _priorityWeight(bPri).compareTo(_priorityWeight(aPri));
      if (c != 0) return c;
      return b.createdAt.compareTo(a.createdAt);
    });
    return filtered;
  }

  int _priorityWeight(String p) {
    switch (p.toLowerCase()) {
      case 'critical': return 4;
      case 'high': return 3;
      case 'medium': return 2;
      case 'low': return 1;
      default: return 0;
    }
  }

  Future<void> _addTask() async {
    await _showTaskDialog();
  }

  Future<void> _editTask(Capture task) async {
    await _showTaskDialog(existingTask: task);
  }

  Future<void> _showTaskDialog({Capture? existingTask}) async {
    final titleController = TextEditingController(text: existingTask?.title ?? '');
    final descController = TextEditingController(text: existingTask?.content ?? '');
    String priority = existingTask?.metadata?['priority'] ?? 'medium';
    
    DateTime? dueDate;
    if (existingTask?.metadata?['due_date'] != null) {
      dueDate = DateTime.tryParse(existingTask!.metadata!['due_date']);
    }
    
    final isEditing = existingTask != null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'New Task',
                    style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (isEditing) ...[ 
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(moduleCapturesProvider('todo').notifier).deleteModuleCapture(existingTask.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.red.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.red),
                          const SizedBox(width: 4),
                          Text('Delete', style: GoogleFonts.inter(fontSize: 9, color: AppColors.red)),
                        ]),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: !isEditing,
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16),
                decoration: const InputDecoration(hintText: 'What needs to be done?'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add notes (optional)',
                  hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              // Priority selector
              Text('Priority', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Row(
                children: ['high', 'medium', 'low'].map((p) {
                  final selected = priority == p;
                  final color = _priorityColor(p);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => priority = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
                          border: Border.all(
                            color: selected ? color : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            p.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 7, fontWeight: FontWeight.w700,
                              color: selected ? color : AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Due date
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    if (!context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: dueDate != null 
                          ? TimeOfDay(hour: dueDate!.hour, minute: dueDate!.minute)
                          : const TimeOfDay(hour: 17, minute: 0),
                    );
                    if (!context.mounted) return;
                    setModalState(() {
                      dueDate = DateTime(
                        date.year, date.month, date.day,
                        time?.hour ?? 17, time?.minute ?? 0,
                      );
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: dueDate != null ? AppColors.orange.withValues(alpha: 0.4) : AppColors.border,
                    ),
                    color: dueDate != null ? AppColors.orange.withValues(alpha: 0.05) : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, 
                          color: dueDate != null ? AppColors.orange : AppColors.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dueDate != null
                              ? DateFormat('MMM d, y · HH:mm').format(dueDate!)
                              : 'Set due date (optional)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: dueDate != null ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ),
                      if (dueDate != null)
                        GestureDetector(
                          onTap: () => setModalState(() => dueDate = null),
                          child: Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: LibraryDesignSystem.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    
                    final notifier = ref.read(moduleCapturesProvider('todo').notifier);
                    
                    if (isEditing) {
                      await notifier.updateModuleCapture(
                        existingTask.id,
                        title: titleController.text.trim(),
                        content: descController.text.trim(),
                        metadataUpdates: {
                          'priority': priority,
                          'due_date': dueDate?.toIso8601String(),
                        }
                      );
                    } else {
                      await notifier.addModuleCapture(
                        title: titleController.text.trim(),
                        content: descController.text.trim(),
                        additionalMetadata: {
                          'priority': priority,
                          'due_date': dueDate?.toIso8601String(),
                          'completed': false,
                        }
                      );
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? 'Task updated!' : 'Task added!', style: GoogleFonts.inter()),
                          backgroundColor: AppColors.surface,
                        ),
                      );
                    }
                  },
                  child: Text(
                    isEditing ? 'Save Changes' : 'Add Task',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'critical': return const Color(0xFFEF4444);
      case 'high': return AppColors.red;
      case 'medium': return AppColors.yellow;
      case 'low': return AppColors.green;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tasksAsync = ref.watch(moduleCapturesProvider('todo'));
    
    return Scaffold(
      backgroundColor: LibraryDesignSystem.textPrimary,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.surfaceGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(
              child: tasksAsync.when(
                loading: () => Center(child: CircularProgressIndicator(color: AppColors.orange)),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (captures) {
                  var tasks = _getFilteredTasks(captures);
                  if (!_showCompleted) {
                    tasks = tasks.where((t) => t.metadata?['completed'] != true).toList();
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () => ref.read(moduleCapturesProvider('todo').notifier).refresh(),
                    color: AppColors.orange,
                    backgroundColor: AppColors.surface,
                    child: tasks.isEmpty
                        ? EmptyState(
                            icon: Icons.checklist_rounded,
                            title: 'No Tasks',
                            subtitle: 'Add your first task or Ask Zen to help prioritize your day.',
                            color: AppColors.orange,
                            onAction: _addTask,
                            actionLabel: 'Add Task',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                            itemCount: tasks.length,
                            itemBuilder: (context, i) => _buildTaskCard(tasks[i]),
                          ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    ),
   );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
      child: Row(
        children: [
          Icon(Icons.checklist_rounded, size: 20, color: AppColors.orange),
          const SizedBox(width: 10),
          Text(
            'TASKS',
            style: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              setState(() => _showCompleted = !_showCompleted);
            },
            icon: Icon(
              _showCompleted ? Icons.visibility_off : Icons.visibility,
              size: 16, color: AppColors.textMuted,
            ),
            label: Text(
              _showCompleted ? 'Hide Done' : 'Show Done',
              style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted),
            ),
          ),
          IconButton(
            icon: Icon(Icons.auto_awesome, size: 20, color: AppColors.orange),
            tooltip: 'AI Reprioritize',
            onPressed: () async {
              await _brain.analyzeAndPrioritizeTasks();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tasks re-ranked by Zen', style: GoogleFonts.inter()),
                    backgroundColor: AppColors.surface,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, size: 24, color: AppColors.orange),
            onPressed: _addTask,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: ['all', 'high', 'medium', 'low'].map((f) {
          final selected = _filter == f;
          final color = f == 'all' ? AppColors.orange : _priorityColor(f);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
                  border: Border.all(
                    color: selected ? color.withValues(alpha: 0.4) : AppColors.border,
                  ),
                ),
                child: Text(
                  f.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: selected ? color : AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskCard(Capture task) {
    final metadata = task.metadata ?? {};
    final priority = metadata['priority'] ?? 'medium';
    final completed = metadata['completed'] == true;
    
    DateTime? dueDate;
    if (metadata['due_date'] != null) {
      dueDate = DateTime.tryParse(metadata['due_date']);
    }
    
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now()) && !completed;
    
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.red.withValues(alpha: 0.15),
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_rounded, color: AppColors.red),
      ),
      onDismissed: (_) async {
        ref.read(moduleCapturesProvider('todo').notifier).deleteModuleCapture(task.id);
      },
      child: GestureDetector(
        onLongPress: () => _editTask(task),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: LibraryDesignSystem.textPrimary.withValues(alpha: completed ? 0.02 : 0.04),
            border: Border.all(
              color: isOverdue 
                  ? AppColors.red.withValues(alpha: 0.3)
                  : completed 
                      ? AppColors.green.withValues(alpha: 0.2)
                      : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              // Completion checkbox
              GestureDetector(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  ref.read(moduleCapturesProvider('todo').notifier).updateModuleCapture(
                    task.id,
                    metadataUpdates: {'completed': !completed},
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed 
                        ? AppColors.green.withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: completed ? AppColors.green : _priorityColor(priority).withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: completed
                      ? Icon(Icons.check, size: 14, color: AppColors.green)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title ?? 'Untitled',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: completed 
                            ? AppColors.textMuted 
                            : AppColors.textPrimary,
                        decoration: completed ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textMuted,
                      ),
                    ),
                    if (task.content.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.content,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (dueDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        isOverdue
                            ? 'OVERDUE · ${DateFormat('MMM d').format(dueDate)}'
                            : 'Due ${DateFormat('MMM d, HH:mm').format(dueDate)}',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: isOverdue ? AppColors.red : AppColors.textMuted,
                          fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Right actions
              if (!completed) ...[ 
                GestureDetector(
                  onTap: () => _editTask(task),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.edit_rounded, size: 16, color: AppColors.textMuted.withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 4, height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _priorityColor(priority).withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 8),
                PriorityTag(priority: priority, compact: true),
              ],
            ],
          ),
        ),
      ),
    );
  }
}