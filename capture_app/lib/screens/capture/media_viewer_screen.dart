import 'package:capture_app/config/library_design_system.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../theme/app_colors.dart';
import '../../models/capture.dart';

class MediaViewerScreen extends StatefulWidget {
  final Capture capture;

  const MediaViewerScreen({super.key, required this.capture});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.capture.type == 'video') {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final file = File(widget.capture.content);
    if (!file.existsSync()) return;

    _videoPlayerController = VideoPlayerController.file(file);
    await _videoPlayerController!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
    );
    
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    final file = File(widget.capture.content);
    final exists = file.existsSync();

    if (!exists) {
      return Center(
        child: Text('File not found', style: TextStyle(color: LibraryDesignSystem.textPrimary)),
      );
    }

    if (widget.capture.type == 'image') {
      return Center(
        child: InteractiveViewer(
          child: Image.file(file),
        ),
      );
    } else if (widget.capture.type == 'video') {
      if (_isVideoInitialized && _chewieController != null) {
        return Center(
          child: Chewie(controller: _chewieController!),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        );
      }
    } else if (widget.capture.type == 'file' && widget.capture.content.toLowerCase().endsWith('.pdf')) {
      return PDFView(
        filePath: file.path,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('Unsupported File Type', style: TextStyle(color: LibraryDesignSystem.textPrimary)),
            const SizedBox(height: 8),
            Text(widget.capture.title ?? 'File', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LibraryDesignSystem.textPrimary, // Media viewers are usually pure black
      appBar: AppBar(
        backgroundColor: LibraryDesignSystem.textPrimary.withValues(alpha: 0.5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: LibraryDesignSystem.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.capture.title ?? 'View Media',
          style: TextStyle(color: LibraryDesignSystem.textPrimary, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }
}