
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../theme/app_colors.dart';
import '../models/capture.dart';
import '../providers/capture_provider.dart';

class BottomSheetCaptureInput extends ConsumerStatefulWidget {
  const BottomSheetCaptureInput({super.key});

  @override
  ConsumerState<BottomSheetCaptureInput> createState() => _BottomSheetCaptureInputState();
}

class _BottomSheetCaptureInputState extends ConsumerState<BottomSheetCaptureInput> {
  final _controller = TextEditingController();
  bool _isSaving = false;
  File? _selectedFile;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveCapture() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    
    setState(() => _isSaving = true);
    
    String type = 'text';
    String content = text;
    String? title;

    try {
      if (_selectedFile != null) {
        final ext = p.extension(_selectedFile!.path).toLowerCase();
        if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) {
          type = 'image';
        } else if (['.mp4', '.mov', '.avi'].contains(ext)) {
          type = 'video';
        } else {
          type = 'file';
        }


        title = text.isEmpty ? p.basename(_selectedFile!.path) : text;
        
        await ref.read(captureListNotifierProvider.notifier).uploadCapture(
          _selectedFile!,
          type,
          title,
        );
      } else {
        final input = CaptureInput(
          type: type,
          content: content,
          title: text.isEmpty ? null : text,
          metadata: null,
        );
        await ref.read(captureListNotifierProvider.notifier).addCapture(input);
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving capture: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedFile != null)
            Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFileIcon(p.extension(_selectedFile!.path)),
                    color: AppColors.greenDark,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    p.basename(_selectedFile!.path),
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedFile = null),
                    child: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          
          Container(
            decoration: BoxDecoration(
              color: AppColors.input,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            padding: EdgeInsets.all(4),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: 4,
                  minLines: 1,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Plan, @ for context, / for commands',
                    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      _ActionButton(icon: Icons.attach_file, onTap: _pickFile),
                      SizedBox(width: 8),
                      _ActionButton(icon: Icons.alternate_email, onTap: () {}),
                      SizedBox(width: 8),
                      _ActionButton(icon: Icons.auto_awesome, onTap: () {}),
                      SizedBox(width: 8),
                      _ActionButton(
                        icon: Icons.mic, 
                        onTap: () {
                          Navigator.pop(context); // Close bottom sheet
                          context.push('/voice');
                        },
                      ),
                      Spacer(),
                      if (_isSaving)
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.greenDark),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _saveCapture,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.greenDark,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_upward, color: AppColors.background, size: 18),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String ext) {
    ext = ext.toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) return Icons.image;
    if (['.mp4', '.mov', '.avi'].contains(ext)) return Icons.video_file;
    if (['.pdf'].contains(ext)) return Icons.picture_as_pdf;
    if (['.doc', '.docx', '.txt'].contains(ext)) return Icons.description;
    return Icons.insert_drive_file;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20, color: AppColors.textTertiary),
    );
  }
}

void showCaptureBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BottomSheetCaptureInput(),
  );
}