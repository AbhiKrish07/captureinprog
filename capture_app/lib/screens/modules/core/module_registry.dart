import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/capture.dart';

/// Defines how a module is rendered in standalone and embedded contexts
abstract class ModuleRenderer {
  String get moduleType;

  Widget buildStandaloneView(BuildContext context, WidgetRef ref);
  
  Widget buildEmbeddedView(BuildContext context, WidgetRef ref, Capture capture);
}

class ModuleRegistry {
  final Map<String, ModuleRenderer> _renderers = {};

  void register(ModuleRenderer renderer) {
    _renderers[renderer.moduleType] = renderer;
  }

  ModuleRenderer? getRenderer(String moduleType) {
    return _renderers[moduleType];
  }
}

final moduleRegistryProvider = Provider<ModuleRegistry>((ref) {
  final registry = ModuleRegistry();
  // We will register the ToDo module here later
  return registry;
});
