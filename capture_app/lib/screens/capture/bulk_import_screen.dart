import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../models/capture.dart';
import '../../config/library_design_system.dart';
import '../../theme/app_colors.dart';

enum ImportStatus { pending, uploading, success, partial, failed }

class ImportItem {
  final File file;
  ImportStatus status;
  String? errorMessage;
  Capture? result;

  ImportItem({required this.file, this.status = ImportStatus.pending});
}

class BulkImportScreen extends ConsumerStatefulWidget {
  const BulkImportScreen({super.key});

  @override
  ConsumerState<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends ConsumerState<BulkImportScreen> {
  final List<ImportItem> _items = [];
  bool _isImporting = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _items.addAll(result.paths.whereType<String>().map((path) => ImportItem(file: File(path))));
      });
    }
  }

  Future<void> _pickFolder() async {
    final String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final dir = Directory(result);
      final files = dir.listSync(recursive: true).whereType<File>().toList();
      setState(() {
        _items.addAll(files.map((file) => ImportItem(file: file)));
      });
    }
  }

  Future<void> _startImport() async {
    if (_isImporting || _items.isEmpty) return;
    
    setState(() {
      _isImporting = true;
    });

    final apiService = ref.read(apiServiceProvider);

    for (var item in _items) {
      if (item.status == ImportStatus.success || item.status == ImportStatus.partial) continue;

      setState(() {
        item.status = ImportStatus.uploading;
      });

      try {
        final ext = item.file.path.split('.').last.toLowerCase();
        String type = 'file';
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) type = 'image';
        if (['mp3', 'm4a', 'wav'].contains(ext)) type = 'voice';
        if (['pdf'].contains(ext)) type = 'pdf';

        final capture = await apiService.uploadCaptureFile(
          file: item.file,
          type: type,
        );

        setState(() {
          item.result = capture;
          item.status = capture.ingestionStatus == 'partial' 
            ? ImportStatus.partial 
            : ImportStatus.success;
        });
      } catch (e) {
        setState(() {
          item.status = ImportStatus.failed;
          item.errorMessage = e.toString();
        });
      }
    }

    setState(() {
      _isImporting = false;
    });
  }

  Widget _buildStatusIcon(ImportItem item) {
    switch (item.status) {
      case ImportStatus.pending:
        return Icon(Icons.schedule, color: LibraryDesignSystem.textSecondary);
      case ImportStatus.uploading:
        return SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: LibraryDesignSystem.accentOrange));
      case ImportStatus.success:
        return Icon(Icons.check_circle, color: AppColors.green);
      case ImportStatus.partial:
        return Tooltip(
          message: "Needs OCR or partial success",
          child: Icon(Icons.warning_amber_rounded, color: AppColors.yellow)
        );
      case ImportStatus.failed:
        return Tooltip(
          message: item.errorMessage ?? "Failed",
          child: Icon(Icons.error, color: AppColors.red)
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LibraryDesignSystem.background,
      appBar: AppBar(
        title: Text('Bulk Import', style: TextStyle(color: LibraryDesignSystem.textPrimary)),
        backgroundColor: LibraryDesignSystem.background,
        iconTheme: IconThemeData(color: LibraryDesignSystem.textPrimary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isImporting ? null : _pickFiles,
                  icon: Icon(Icons.file_upload),
                  label: Text('Add Files'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceElevated, foregroundColor: LibraryDesignSystem.textPrimary),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isImporting ? null : _pickFolder,
                  icon: Icon(Icons.folder),
                  label: Text('Add Folder'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceElevated, foregroundColor: LibraryDesignSystem.textPrimary),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: _isImporting ? null : _startImport,
                  style: ElevatedButton.styleFrom(backgroundColor: LibraryDesignSystem.accentOrange, foregroundColor: LibraryDesignSystem.background),
                  child: Text(_isImporting ? 'Importing...' : 'Start Import'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: _buildStatusIcon(item),
                  title: Text(item.file.path.split(Platform.pathSeparator).last, style: TextStyle(color: LibraryDesignSystem.textPrimary)),
                  subtitle: item.status == ImportStatus.failed 
                    ? Text(item.errorMessage ?? 'Error', style: TextStyle(color: AppColors.red))
                    : item.status == ImportStatus.partial
                      ? Text('Partial Success / Needs OCR', style: TextStyle(color: AppColors.yellow))
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
