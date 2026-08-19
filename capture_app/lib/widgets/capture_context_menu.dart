import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/capture.dart';
import '../providers/capture_provider.dart';

import '../theme/app_colors.dart';

void showCaptureContextMenu(BuildContext context, WidgetRef ref, Capture capture) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(capture.title ?? 'Untitled Capture', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.blue),
                title: Text('Edit Details', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditSheet(context, ref, capture);
                },
              ),

              ListTile(
                leading: Icon(Icons.share, color: AppColors.yellow),
                title: Text('Share', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Sharing functionality coming soon!'),
                    backgroundColor: AppColors.surfaceElevated,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.red),
                title: Text('Delete', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(captureListNotifierProvider.notifier).deleteCapture(capture.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Capture deleted'),
                    backgroundColor: AppColors.surfaceElevated,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showEditSheet(BuildContext context, WidgetRef ref, Capture capture) {
  String newTitle = capture.title ?? '';
  String newContent = capture.content;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Capture', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: newTitle),
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.orange)),
              ),
              onChanged: (val) => newTitle = val,
            ),
            SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: newContent),
              style: TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Content / File Path',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.orange)),
              ),
              onChanged: (val) => newContent = val,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: LibraryDesignSystem.textPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ref.read(captureListNotifierProvider.notifier).updateCapture(
                    id: capture.id,
                    title: newTitle,
                    content: newContent,
                  );
                  Navigator.pop(context);
                },
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
      );
    },
  );
}