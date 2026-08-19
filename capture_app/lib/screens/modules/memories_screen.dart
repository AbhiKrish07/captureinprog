import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

import '../../widgets/modules_widgets.dart';
import '../../core/modules_mocks.dart';
import '../../models/modules_models.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});
  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final _db = ZenDatabase();
  List<MemorySlot> _memories = [];
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    _loadMemories();
  }
  
  Future<void> _loadMemories() async {
    final memories = await _db.getAllMemories();
    if (mounted) {
      setState(() {
        _memories = memories;
        _loading = false;
      });
    }
  }
  
  void _addMemory() {
    _showMemoryDialog();
  }
  
  void _editMemory(MemorySlot memory) {
    _showMemoryDialog(memory: memory);
  }
  
  Future<void> _deleteMemory(String key) async {
    await _db.deleteMemory(key);
    _loadMemories();
  }

  void _showMemoryDialog({MemorySlot? memory}) {
    final keyCtrl = TextEditingController(text: memory?.key ?? '');
    final valueCtrl = TextEditingController(text: memory?.value ?? '');
    
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(memory == null ? 'New Memory' : 'Edit Memory',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: keyCtrl,
              enabled: memory == null, // disable key edit if updating
              style: GoogleFonts.inter(color: memory == null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Topic (e.g. Favorite Color)',
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted.withValues(alpha: 0.5)),
                border: InputBorder.none,
              ),
            ),
            Divider(color: AppColors.border),
            TextField(
              controller: valueCtrl,
              maxLines: 4,
              autofocus: memory != null,
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'What should I remember about this?',
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted.withValues(alpha: 0.5)),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final k = keyCtrl.text.trim();
              final v = valueCtrl.text.trim();
              if (k.isNotEmpty && v.isNotEmpty) {
                await _db.setMemory(k, v);
                if (mounted) _loadMemories();
                if (c.mounted) Navigator.pop(c);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
            child: Text('Save', style: TextStyle(color: LibraryDesignSystem.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  'These details are injected into Zen\'s context during conversation.',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                ),
              ),
              Expanded(
                child: _loading 
                  ? Center(child: CircularProgressIndicator(color: AppColors.orange))
                  : _memories.isEmpty
                    ? Center(
                        child: Text(
                          'No memories stored yet.\n\nTell Zen "Remember that..."\nor add one manually.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                        )
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _memories.length,
                        itemBuilder: (context, index) {
                          final mem = _memories[index];
                          return GestureDetector(
                            onTap: () => _editMemory(mem),
                            child: GlassContainer(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        mem.key.toUpperCase(),
                                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.cyan),
                                      ),
                                      GestureDetector(
                                        onTap: () => _deleteMemory(mem.key),
                                        child: Icon(Icons.close_rounded, size: 16, color: AppColors.red),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    mem.value,
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemory,
        backgroundColor: AppColors.orange,
        child: Icon(Icons.add, color: LibraryDesignSystem.textPrimary),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8),
          Icon(Icons.memory_rounded, size: 24, color: AppColors.orange),
          SizedBox(width: 8),
          Text(
            'ZEN MEMORY',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}