import 'package:capture_app/config/library_design_system.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

import '../../core/modules_mocks.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/markdown.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/capture.dart';
import '../../providers/capture_provider.dart';


class ForgeModuleScreen extends ConsumerStatefulWidget {
  const ForgeModuleScreen({super.key});

  @override
  ConsumerState<ForgeModuleScreen> createState() => _ForgeModuleScreenState();
}

class ForgeFile {
  final String name;
  final String language;
  String content;
  final String? captureId;

  ForgeFile(this.name, this.language, this.content, this.captureId);
}

class _ForgeModuleScreenState extends ConsumerState<ForgeModuleScreen> {
  // UI toggles
  bool _showExplorer = false;
  bool _showAiPanel = false;
  bool _showTerminal = true;

  // File state
  final List<ForgeFile> _files = [];
  bool _initialized = false;
  int _activeFileIndex = 0;
  late CodeController _editorController;
  bool _isExecuting = false;

  // Terminal state
  final List<String> _terminalOutput = [
    'Zen FORGE ENGINE v3.0',
    '✓ System initialized.',
    'Ready for execution.',
  ];

  // AI state
  final _brain = ZenBrain();
  final List<Map<String, String>> _aiMessages = [];
  final _aiInputController = TextEditingController();
  final ScrollController _aiScrollController = ScrollController();
  bool _isAiTyping = false;

  // Design constants
  final Color _forgeOrange = Color(0xFFFDBA74);
  final Color _bgDeep = Color(0xFF04050A);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final captures = await ref.read(captureListNotifierProvider.future);
    if (!mounted) return;
    
    _files.clear();
    for (var c in captures) {
       String ext = 'txt';
       if (c.title != null && c.title!.contains('.')) {
         ext = c.title!.split('.').last;
       } else if (c.metadata != null && c.metadata!['extension'] != null) {
         ext = c.metadata!['extension'];
       }
       _files.add(ForgeFile(c.title ?? 'untitled', ext, c.content, c.id));
    }
    if (_files.isEmpty) {
       _files.add(ForgeFile('main.py', 'python', '# Zen FORGE\n', null));
    }
    _initController();
    _editorController.addListener(() {
      _saveCurrentFile();
    });
    
    setState(() {
      _initialized = true;
    });
  }

  void _initController() {
    final language = _files[_activeFileIndex].language;
    var mode = python;
    if (language == 'javascript' || language == 'js') mode = javascript;
    if (language == 'dart') mode = dart;
    if (language == 'markdown' || language == 'md') mode = markdown;

    _editorController = CodeController(
      text: _files[_activeFileIndex].content,
      language: mode,
    );
  }

  @override
  void dispose() {
    _editorController.dispose();
    _aiInputController.dispose();
    _aiScrollController.dispose();
    super.dispose();
  }

  void _switchFile(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _files[_activeFileIndex].content = _editorController.text;
      _activeFileIndex = index;
      
      final language = _files[_activeFileIndex].language;
      var mode = python;
      if (language == 'javascript' || language == 'js') mode = javascript;
      if (language == 'dart') mode = dart;
      if (language == 'markdown' || language == 'md') mode = markdown;
      
      _editorController.language = mode;
      _editorController.text = _files[_activeFileIndex].content;
    });
  }

  void _saveCurrentFile() {
    if (_activeFileIndex < _files.length) {
      final file = _files[_activeFileIndex];
      if (file.captureId != null && file.content != _editorController.text) {
        file.content = _editorController.text;
        ref.read(captureListNotifierProvider.notifier).updateCapture(
          id: file.captureId!,
          content: file.content,
        );
      }
    }
  }

  Map<String, dynamic> _tryParseJson(String text) {
    try {
      // Find the first { and last }
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final jsonPart = text.substring(start, end + 1);
        return jsonDecode(jsonPart);
      }
      return jsonDecode(text);
    } catch (e) {
      throw Exception("Invalid JSON format from engine: $e");
    }
  }

  Future<void> _runCode() async {
    if (_isExecuting) return;
    HapticFeedback.mediumImpact();

    final currentFile = _files[_activeFileIndex];

    setState(() {
      _showTerminal = true;
      _isExecuting = true;
      _terminalOutput.add(' ');
      _terminalOutput.add('> Starting Zen Build Engine...');
      _terminalOutput.add('> Compiling ${currentFile.name}...');
    });

    final prompt = """
Act as a high-performance code executor and debugger. 
I have a file named `${currentFile.name}` with the following content:
```${currentFile.language}
${_editorController.text}
```

Please simulate the execution of this code. 
- If the code has logic or syntax errors, describe them like a compiler/interpreter would.
- If it runs, provide the expected output (STDOUT).
- Format your response as a JSON object with:
{
  "status": "success" | "error",
  "output": "The console output or error trace",
  "insights": "A short 1-sentence tip for the developer"
}
Return ONLY the JSON.
""";

    try {
      final response = await _brain.chat(prompt, persistHistory: false);
      final data = _tryParseJson(response);

      setState(() {
        _terminalOutput.add(data['output'] ?? 'No output returned.');
        if (data['status'] == 'error') {
          _terminalOutput.add('✖ Build failed.');
        } else {
          _terminalOutput.add('✓ Build finished successfully.');
        }
        if (data['insights'] != null) {
          _terminalOutput.add('💡 Tip: ${data['insights']}');
        }
        _isExecuting = false;
      });
    } catch (e) {
      setState(() {
        _terminalOutput
            .add('✖ Engine error: Unable to parse execution result.');
        _terminalOutput.add('Error details: $e');
        _isExecuting = false;
      });
    }
  }

  void _addNewFile() {
    final nameController = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1))),
              title: Text('NEW FILE',
                  style: GoogleFonts.inter(
                      color: _forgeOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              content: TextField(
                controller: nameController,
                autofocus: true,
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'filename.ext',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.24)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.2))),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('CANCEL',
                        style: GoogleFonts.inter(fontSize: 12, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.5)))),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      final ext = nameController.text.split('.').last;
                      
                      // Create capture
                      final input = CaptureInput(
                        type: 'file',
                        title: nameController.text,
                        content: '',
                        metadata: {'extension': ext},
                      );
                      final captureId = await ref.read(captureListNotifierProvider.notifier).addCapture(input);


                      setState(() {
                        _files.add(ForgeFile(nameController.text, ext, '', captureId));
                        _switchFile(_files.length - 1);
                      });
                      if (context.mounted) {
                        Navigator.pop(ctx);
                      }
                    }
                  },
                  child: Text('CREATE',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _forgeOrange,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ));
  }

  void _deleteFile(int index) {
    if (_files.length <= 1) return;
    HapticFeedback.heavyImpact();
    
    final file = _files[index];
    if (file.captureId != null) {
      ref.read(captureListNotifierProvider.notifier).deleteCapture(file.captureId!);
    }

    setState(() {
      _files.removeAt(index);
      if (_activeFileIndex >= _files.length) {
        _activeFileIndex = _files.length - 1;
      }
      _editorController.text = _files[_activeFileIndex].content;
    });
  }

  Future<void> _sendToZen(String prompt) async {
    HapticFeedback.lightImpact();
    
    // Add user message locally
    setState(() {
      _aiMessages.add({'role': 'user', 'content': prompt});
      _aiMessages.add({'role': 'assistant', 'content': ''});
      _isAiTyping = true;
    });
    _scrollToBottom();

    final code = _editorController.text;
    final fullPrompt = "Context from file `${_files[_activeFileIndex].name}`:\n```\n$code\n```\n\nPrompt: $prompt";

    try {
      String fullContent = "";
      final lastIdx = _aiMessages.length - 1;
      
      await for (final chunk in _brain.chatStream(fullPrompt, persistHistory: false)) {
        if (!chunk.startsWith('Error') && !chunk.startsWith('⚠️')) {
          fullContent += chunk;
          if (mounted) {
            setState(() {
              _aiMessages[lastIdx]['content'] = fullContent;
            });
            _scrollToBottom();
          }
        } else {
          fullContent = chunk;
          break;
        }
      }
      
      if (mounted) setState(() => _isAiTyping = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiMessages.add({'role': 'assistant', 'content': 'System error in Engine.'});
          _isAiTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_aiScrollController.hasClients) {
        _aiScrollController.animateTo(
          _aiScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    if (!_initialized) {
      return Scaffold(
        backgroundColor: _bgDeep,
        body: Center(child: CircularProgressIndicator(color: _forgeOrange)),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;

    return Scaffold(
      backgroundColor: _bgDeep,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Row(
                children: [
                  if (_showExplorer) _buildExplorer(),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: ClipRect(child: _buildEditor())),
                        if (_showTerminal)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.3,
                            ),
                            child: _buildTerminal(),
                          ),
                      ],
                    ),
                  ),
                  if (_showAiPanel)
                    Flexible(
                      flex: isNarrow ? 10 : 1,
                      child: _buildAiPanel(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: _bgDeep,
        border:
            Border(bottom: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          // Nav Back & Logo
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 14, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.5)),
            ),
          ),
          Container(width: 1, height: 24, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1)),
          if (MediaQuery.of(context).size.width > 600)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _forgeOrange,
                      boxShadow: [
                        BoxShadow(
                            color: _forgeOrange.withValues(alpha: 0.5), blurRadius: 8)
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'THE FORGE',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _forgeOrange,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

          // File Tabs
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                final isActive = index == _activeFileIndex;
                return GestureDetector(
                  onTap: () => _switchFile(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isActive
                          ? LibraryDesignSystem.textPrimary.withValues(alpha: 0.05)
                          : Colors.transparent,
                      border: Border(
                        right: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1)),
                        bottom: BorderSide(
                            color: isActive ? _forgeOrange : Colors.transparent,
                            width: 2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      file.name,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isActive
                            ? LibraryDesignSystem.textPrimary
                            : LibraryDesignSystem.textPrimary.withValues(alpha: 0.5),
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Actions
          Row(
            children: [
              _topBtn(
                  _isExecuting
                      ? Icons.hourglass_empty_rounded
                      : Icons.play_arrow_rounded,
                  _isExecuting ? '...' : 'Run',
                  _forgeOrange,
                  _forgeOrange.withValues(alpha: 0.1),
                  _runCode),
              SizedBox(width: 8),
              _topBtn(Icons.folder_shared_rounded, 'Files',
                  LibraryDesignSystem.textPrimary.withValues(alpha: 0.7), Colors.transparent, () {
                setState(() {
                  _showExplorer = !_showExplorer;
                  if (_showExplorer &&
                      MediaQuery.of(context).size.width < 600) {
                    _showAiPanel = false;
                  }
                });
              }),
              SizedBox(width: 8),
              _topBtn(
                  Icons.auto_awesome, 'Zen', _forgeOrange, Colors.transparent,
                  () {
                setState(() {
                  _showAiPanel = !_showAiPanel;
                  if (_showAiPanel && MediaQuery.of(context).size.width < 600) {
                    _showExplorer = false;
                  }
                });
              }),
              SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topBtn(
      IconData icon, String label, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplorer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth > 600 ? 220.0 : 160.0;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Color(0xFF030408),
        border: Border(right: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'EXPLORER',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.4),
                letterSpacing: 2,
              ),
            ),
          ),
          InkWell(
            onTap: _addNewFile,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.add_box_rounded,
                      size: 14, color: Colors.greenAccent),
                  SizedBox(width: 8),
                  Text('NEW FILE',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                final isActive = index == _activeFileIndex;
                return InkWell(
                  onTap: () => _switchFile(index),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? LibraryDesignSystem.textPrimary.withValues(alpha: 0.05)
                          : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                            color: isActive ? _forgeOrange : Colors.transparent,
                            width: 2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file_rounded,
                            size: 14, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.4)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            file.name,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isActive
                                  ? LibraryDesignSystem.textPrimary
                                  : LibraryDesignSystem.textPrimary.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        if (isActive && _files.length > 1)
                          InkWell(
                            onTap: () => _deleteFile(index),
                            child: Icon(Icons.delete_outline_rounded,
                                size: 12, color: AppColors.textMuted.withValues(alpha: 0.5)),
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
    );
  }

  Widget _buildEditor() {
    return Container(
      color: _bgDeep,
      child: Stack(
        children: [
          CodeField(
            controller: _editorController,
            textStyle: GoogleFonts.inter(
              fontSize: 13,
              height: 1.6,
              color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.9),
            ),
            cursorColor: _forgeOrange,
            lineNumberStyle: LineNumberStyle(
              width: 46,
              margin: 16,
              textAlign: TextAlign.right,
              textStyle: GoogleFonts.inter(fontSize: 11, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.24)),
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _files[_activeFileIndex].language.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 10, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminal() {
    return Container(
      constraints: BoxConstraints(minHeight: 50, maxHeight: 250),
      decoration: BoxDecoration(
        color: Color(0xFF020308),
        border: Border(top: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                Text('OUTPUT',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: LibraryDesignSystem.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
                Spacer(),
                InkWell(
                  onTap: () => setState(() => _terminalOutput.clear()),
                  child: Row(
                    children: [
                      Icon(Icons.layers_clear_outlined, size: 12, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.5)),
                      SizedBox(width: 4),
                      Text('CLEAR', style: GoogleFonts.inter(fontSize: 9, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                InkWell(
                  onTap: () => setState(() => _showTerminal = false),
                  child: Icon(Icons.close_rounded,
                      size: 14, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _terminalOutput.length,
              itemBuilder: (context, index) {
                final line = _terminalOutput[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: line.contains('Error') || line.contains('failed') || line.contains('✖')
                          ? AppColors.textMuted
                          : line.contains('✓') || line.contains('finished')
                              ? AppColors.textMuted
                              : line.startsWith('>') 
                                  ? _forgeOrange.withValues(alpha: 0.8)
                                  : LibraryDesignSystem.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiPanel() {
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth > 600 ? 320.0 : screenWidth * 0.8;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Color(0xFF04050E),
        border: Border(left: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1))),
              color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.02),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: _forgeOrange),
                SizedBox(width: 8),
                Text(
                  'ENGINE ASSISTANT',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: LibraryDesignSystem.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _aiMessages.clear();
                    });
                  },
                  icon: Icon(Icons.delete_sweep_rounded, size: 16, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.30)),
                  tooltip: 'Clear Chat',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _aiScrollController,
              padding: EdgeInsets.all(16),
              itemCount: _aiMessages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _aiMessages.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Zen is processing your code...',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.5)),
                    ),
                  );
                }
                final msg = _aiMessages[index];
                final isUser = msg['role'] == 'user';
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? LibraryDesignSystem.textPrimary.withValues(alpha: 0.05)
                        : _forgeOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isUser
                          ? LibraryDesignSystem.textPrimary.withValues(alpha: 0.1)
                          : _forgeOrange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          isUser ? 'YOU' : 'ZEN',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isUser
                                ? LibraryDesignSystem.textPrimary.withValues(alpha: 0.5)
                                : _forgeOrange,
                          ),
                        ),
                      SizedBox(height: 6),
                      _buildMessageContent(msg['content']!, isUser),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aiInputController,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: LibraryDesignSystem.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask Zen about your code...',
                      hintStyle: GoogleFonts.inter(fontSize: 10, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.4)),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _forgeOrange),
                      ),
                    ),
                    onSubmitted: (txt) {
                      if (txt.trim().isNotEmpty) {
                        _sendToZen(txt.trim());
                        _aiInputController.clear();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: _forgeOrange),
                  onPressed: () {
                    final txt = _aiInputController.text.trim();
                    if (txt.isNotEmpty) {
                      _sendToZen(txt);
                      _aiInputController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(String text, bool isUser) {
    if (isUser) {
      return Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          height: 1.5,
          color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.9),
        ),
      );
    }

    // Parse markdown code blocks (multi-block support)
    final blocks = text.split("```");
    if (blocks.length > 1) {
      List<Widget> children = [];
      for (int i = 0; i < blocks.length; i++) {
        final part = blocks[i].trim();
        if (part.isEmpty) continue;

        if (i % 2 != 0) {
          // It's a code block
          final lines = part.split('\n');
          final firstLine = lines.first.trim();
          final code = lines.length > 1 ? lines.sublist(1).join('\n').trim() : part;
          
          children.add(
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF020308),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(firstLine.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: _forgeOrange.withValues(alpha: 0.5))),
                      Icon(Icons.code, size: 12, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.24)),
                    ],
                  ),
                  Divider(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1)),
                  Text(code, style: GoogleFonts.inter(fontSize: 10, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.8))),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _editorController.text = code;
                        _files[_activeFileIndex].content = code;
                        _showTerminal = true;
                        _terminalOutput.add('> Code injected into editor.');
                      });
                    },
                    icon: Icon(Icons.flash_on, size: 14),
                    label: Text('INJECT CODE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forgeOrange,
                      foregroundColor: Color(0xFF04050E),
                      elevation: 0,
                      minimumSize: Size(double.infinity, 30),
                      textStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // It's normal text
          children.add(
            Text(part, style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.9))),
          );
        }
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
    }

    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        height: 1.5,
        color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.9),
      ),
    );
  }
}