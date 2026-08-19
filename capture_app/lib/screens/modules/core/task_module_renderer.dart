import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/capture.dart';
import 'module_registry.dart';
import '../tasks_screen.dart';
import '../widgets/task_embedded_widget.dart';

class TaskModuleRenderer extends ModuleRenderer {
  @override
  String get moduleType => 'todo';

  @override
  Widget buildStandaloneView(BuildContext context, WidgetRef ref) {
    return const TasksScreen();
  }

  @override
  Widget buildEmbeddedView(BuildContext context, WidgetRef ref, Capture capture) {
    return TaskEmbeddedWidget(capture: capture);
  }
}
