import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import '../providers/canvas_state.dart';


class CardEditorPanel extends ConsumerStatefulWidget {
  const CardEditorPanel({super.key});

  @override
  ConsumerState<CardEditorPanel> createState() => _CardEditorPanelState();
}

class _CardEditorPanelState extends ConsumerState<CardEditorPanel> {
  EditorState? _editorState;
  
  @override
  void initState() {
    super.initState();
    _initEditor();
  }

  void _initEditor() {
    // Basic mock editor state
    _editorState = EditorState(
      document: Document.fromJson({
        "document": {
          "type": "page",
          "children": [
            {
              "type": "heading",
              "data": {"level": 1},
              "children": [
                {"text": "Block Editor Preview"}
              ]
            },
            {
              "type": "paragraph",
              "data": {},
              "children": [
                {"text": "This is a rich text editor using appflowy_editor. "},
                {"text": "It supports colored highlights", "attributes": {"backgroundColor": "#FFF9C4"}}, // light yellow
                {"text": ", bold, italic, and more."}
              ]
            },
            {
              "type": "bulleted_list",
              "data": {},
              "children": [
                {"text": "List item 1"},
              ]
            },
            {
              "type": "bulleted_list",
              "data": {},
              "children": [
                {"text": "List item 2 with "},
                {"text": "citation [1]", "attributes": {"href": "#citation1", "color": "#1E88E5"}},
              ]
            }
          ]
        }
      }),
    );
  }

  @override
  void didUpdateWidget(covariant CardEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ideally update editor state based on new active card if it changed
  }

  @override
  void dispose() {
    _editorState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCard = ref.watch(activeCardProvider);
    
    if (activeCard == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: LibraryDesignSystem.textPrimary,
        border: Border(
          left: BorderSide(color: LibraryDesignSystem.borderDark, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: LibraryDesignSystem.borderDark)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    ref.read(activeCardProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activeCard.title,
                    style: TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Editor Body
          Expanded(
            child: AppFlowyEditor(
              editorState: _editorState!,
              editable: true,
              autoFocus: true,
            ),
          ),
        ],
      ),
    );
  }
}