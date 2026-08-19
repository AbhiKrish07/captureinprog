import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/capture_provider.dart';
import '../../models/capture.dart';

class DocumentModuleScreen extends ConsumerStatefulWidget {
  final String? initialCaptureId;
  const DocumentModuleScreen({super.key, this.initialCaptureId});
  
  @override
  ConsumerState<DocumentModuleScreen> createState() => _DocumentModuleScreenState();
}

class _DocumentModuleScreenState extends ConsumerState<DocumentModuleScreen> {
  // Theme colors
  static const Color _bg = Color(0xFF0D0D0B);
  static const Color _surface = Color(0xFF161614);
  static const Color _border = Color(0xFF262624);
  static const Color _text = Color(0xFFF0EAD8);
  static const Color _muted = Color(0xFF8A8A85);
  static const Color _orange = Color(0xFFE8A87C);

  String? _selectedCaptureId;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedCaptureId = widget.initialCaptureId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onCaptureSelected(Capture capture) {
    if (_selectedCaptureId == capture.id) return;
    setState(() {
      _selectedCaptureId = capture.id;
      _titleController.text = capture.title ?? '';
      _contentController.text = capture.content;
    });
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_selectedCaptureId != null) {
        ref.read(captureListNotifierProvider.notifier).updateCapture(
          id: _selectedCaptureId!,
          title: _titleController.text,
          content: _contentController.text,
        );
      }
    });
  }

  void _createNewDocument() async {
    final newId = await ref.read(captureListNotifierProvider.notifier).addCapture(
      CaptureInput(
        type: 'text',
        title: 'Untitled Document',
        content: '',
        metadata: {},
      )
    );
    setState(() {
      _selectedCaptureId = newId;
      _titleController.text = 'Untitled Document';
      _contentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureListNotifierProvider);
    
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 280,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: _border)),
              ),
              child: Column(
                children: [
                  // Sidebar Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: _muted, size: 16),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text('Documents', style: GoogleFonts.inter(color: _text, fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add_box_outlined, color: _orange),
                          onPressed: _createNewDocument,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _border),
                  // List
                  Expanded(
                    child: captureState.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: _orange)),
                      error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
                      data: (captures) {
                        final textCaptures = captures.where((c) => c.contentType == 'text').toList();
                        
                        // If no capture is selected, select the first one (or initial one)
                        if (_selectedCaptureId == null && textCaptures.isNotEmpty) {
                          // Try to find the initial capture
                          Capture? target = textCaptures.where((c) => c.id == widget.initialCaptureId).firstOrNull;
                          target ??= textCaptures.first;
                          
                          Future.microtask(() {
                            if (mounted) _onCaptureSelected(target!);
                          });
                        }

                        if (textCaptures.isEmpty) {
                          return Center(
                            child: Text('No documents found.\nCreate one to get started!', textAlign: TextAlign.center, style: GoogleFonts.inter(color: _muted)),
                          );
                        }
                        
                        return ListView.builder(
                          itemCount: textCaptures.length,
                          itemBuilder: (context, index) {
                            final capture = textCaptures[index];
                            final isSelected = capture.id == _selectedCaptureId;
                            return InkWell(
                              onTap: () => _onCaptureSelected(capture),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? _surface : Colors.transparent,
                                  border: Border(left: BorderSide(color: isSelected ? _orange : Colors.transparent, width: 3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      capture.title?.isNotEmpty == true ? capture.title! : 'Untitled',
                                      style: GoogleFonts.inter(color: _text, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, fontSize: 14),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      capture.content.isNotEmpty ? capture.content : 'No content',
                                      style: GoogleFonts.inter(color: _muted, fontSize: 12),
                                      maxLines: 2, overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Editor Area
            Expanded(
              child: _selectedCaptureId == null
                ? const Center(child: Text('Select a document to edit', style: TextStyle(color: _muted)))
                : Column(
                    children: [
                      // Editor Toolbar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: _border)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.format_bold, color: _muted, size: 20),
                            const SizedBox(width: 16),
                            const Icon(Icons.format_italic, color: _muted, size: 20),
                            const SizedBox(width: 16),
                            const Icon(Icons.format_underline, color: _muted, size: 20),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 14, color: _orange),
                                  const SizedBox(width: 6),
                                  Text('Saved', style: GoogleFonts.inter(color: _orange, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Editor
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _titleController,
                                onChanged: (_) => _onTextChanged(),
                                style: GoogleFonts.inter(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: _text,
                                  letterSpacing: -0.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Document Title',
                                  hintStyle: GoogleFonts.inter(color: _muted.withOpacity(0.5)),
                                  border: InputBorder.none,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _contentController,
                                onChanged: (_) => _onTextChanged(),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: _text,
                                  height: 1.6,
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  hintText: 'Start writing...',
                                  hintStyle: GoogleFonts.inter(color: _muted.withOpacity(0.5)),
                                  border: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}