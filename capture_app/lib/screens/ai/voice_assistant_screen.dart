import 'package:capture_app/config/library_design_system.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/capture_provider.dart';
import '../../models/capture.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;
  String _transcription = 'Listening...';
  String _fadedTranscription = '';
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _mockTimer?.cancel();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      _speechEnabled = false;
      if (mounted) setState(() {});
    }
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
      _transcription = '';
      _fadedTranscription = '';
    });

    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _transcription = result.recognizedWords;
          });
          if (result.finalResult) {
            _saveAndClose();
          }
        },
      );
    } else {
      // Fallback Mock for unsupported platforms
      _transcription = "Listening... (Fallback mode)";
      _mockTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _transcription = "This is a transcribed voice note using the fallback mode.";
          });
          Timer(const Duration(seconds: 1), _saveAndClose);
        }
      });
    }
  }

  void _stopListening() async {
    setState(() {
      _isListening = false;
    });
    if (_speechEnabled) {
      await _speechToText.stop();
    }
    _mockTimer?.cancel();
    
    _saveAndClose();
  }

  void _saveAndClose() async {
    if (_transcription.isEmpty || _transcription.startsWith("Listening")) {
      if (mounted) context.pop();
      return;
    }

    try {
      final input = CaptureInput(
        type: 'voice',
        content: _transcription,
        title: 'Voice Note',
        metadata: null,
      );
      await ref.read(captureListNotifierProvider.notifier).addCapture(input);
      if (mounted) context.pop(); // Go back
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving voice note: $e')));
        setState(() => _isListening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The UI requires a clean white/light grey background to match the screenshots
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            // Close Button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(Icons.close, color: Color(0xFF4B5563)),
                onPressed: () => context.pop(),
              ),
            ),
            
            // Header Text (Capture / Hey Capture)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _isListening
                      ? Text(
                          'Hey Capture 👋',
                          key: ValueKey('hey'),
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        )
                      : Text(
                          'Capture',
                          key: ValueKey('capture'),
                          style: TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),

            // Main Content Area
            Positioned.fill(
              top: 80,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _isListening ? _buildListeningState() : _buildInitialState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      key: const ValueKey('initial'),
      children: [
        const SizedBox(height: 40),
        Text(
          'How can I assist you?',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
        
        const SizedBox(height: 60),
        
        // List of options (fading opacity for depth as in screenshot)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              _buildOptionPill(Icons.description_outlined, 'Recent Captures', 1.0).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2),
              _buildOptionPill(Icons.people_outline, 'CRM', 0.8).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2),
              _buildOptionPill(Icons.settings_outlined, 'Account settings', 0.6).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2),
              _buildOptionPill(Icons.bar_chart_outlined, 'Reports', 0.4).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.2),
              _buildOptionPill(Icons.dashboard_outlined, 'Dashboard', 0.2).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),
        
        // Bottom Action
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              Text(
                'Or press the voice assistant button',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _startListening,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: LibraryDesignSystem.textPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF374151),
                    size: 28,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scaleXY(begin: 1.0, end: 1.05, duration: 1.5.seconds, curve: Curves.easeInOut),
            ],
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
        ),
      ],
    );
  }

  Widget _buildOptionPill(IconData icon, String label, double opacity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: LibraryDesignSystem.textPrimary,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListeningState() {
    return Column(
      key: const ValueKey('listening'),
      children: [
        const SizedBox(height: 40),
        
        // Transcription Text
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: _transcription,
                style: TextStyle(color: Color(0xFF111827)),
              ),
              TextSpan(
                text: _fadedTranscription,
                style: TextStyle(color: Color(0xFFD1D5DB)), // Faded trailing text
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1),
        
        const Spacer(),
        
        // The 3D Blob Animation
        Center(
          child: GestureDetector(
            onTap: _stopListening,
            child: SizedBox(
              width: 300,
              height: 300,
              child: _AnimatedBlob(),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .moveY(begin: -5, end: 5, duration: 3.seconds, curve: Curves.easeInOut),
          ),
        ),
        
        const Spacer(flex: 2),
        
        Text(
          'Tap the orb to stop listening',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 3D BLOB ANIMATION
// ---------------------------------------------------------------------------

class _AnimatedBlob extends StatefulWidget {
  const _AnimatedBlob();

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return CustomPaint(
          painter: _BlobPainter(t),
        );
      },
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;

  _BlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.4;
    
    // We use a complex radial gradient to simulate 3D depth and specular highlights
    final gradient = RadialGradient(
      center: const Alignment(-0.2, -0.3), // Light source from top-left
      radius: 0.8,
      colors: const [
        Color(0xFF818CF8), // Light blue highlight
        Color(0xFF4F46E5), // Core blue
        Color(0xFF312E81), // Deep shadow
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: baseRadius))
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // We modify the radius around the circle using sine waves dependent on time t
    for (int i = 0; i <= 360; i += 5) {
      final rad = i * pi / 180;
      
      // Complex noise-like deformation for a highly fluid 3D feel
      final wave1 = sin(rad * 3 + t * pi * 2) * 18;
      final wave2 = cos(rad * 4 - t * pi * 2) * 12;
      final wave3 = sin(rad * 2 + t * pi * 4) * 10;
      final wave4 = cos(rad * 5 + t * pi * 3) * 5; // Extra micro-detail
      
      final currentRadius = baseRadius + wave1 + wave2 + wave3 + wave4;
      
      final x = center.dx + currentRadius * cos(rad);
      final y = center.dy + currentRadius * sin(rad);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw a shadow beneath the blob for grounding
    final shadowPath = Path()..addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy + baseRadius * 0.8), 
      width: baseRadius * 1.5, 
      height: 30
    ));
    canvas.drawPath(shadowPath, Paint()..color = LibraryDesignSystem.textPrimary.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));

    // Draw the blob
    canvas.drawPath(path, paint);

    // Overlay some swooping "ridges" to simulate the 3D texture in the screenshot
    final ridgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.5);

    final ridgePath1 = Path();
    ridgePath1.moveTo(center.dx - baseRadius * 0.7, center.dy + baseRadius * 0.2);
    ridgePath1.quadraticBezierTo(
      center.dx, center.dy + baseRadius * 0.5 + sin(t * pi * 2) * 20, 
      center.dx + baseRadius * 0.7, center.dy - baseRadius * 0.2
    );
    canvas.drawPath(ridgePath1, ridgePaint);

    final ridgePath2 = Path();
    ridgePath2.moveTo(center.dx - baseRadius * 0.5, center.dy - baseRadius * 0.3);
    ridgePath2.quadraticBezierTo(
      center.dx, center.dy - baseRadius * 0.1 + cos(t * pi * 2) * 20, 
      center.dx + baseRadius * 0.8, center.dy + baseRadius * 0.4
    );
    // Add a third inner ridge for extra volumetric reflection
    final ridgePath3 = Path();
    ridgePath3.moveTo(center.dx - baseRadius * 0.3, center.dy + baseRadius * 0.6);
    ridgePath3.quadraticBezierTo(
      center.dx + baseRadius * 0.4, center.dy + baseRadius * 0.2 + sin(t * pi * 3) * 15, 
      center.dx + baseRadius * 0.6, center.dy + baseRadius * 0.7
    );
    canvas.drawPath(ridgePath3, Paint()..color = const Color(0xFF818CF8).withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 15..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}