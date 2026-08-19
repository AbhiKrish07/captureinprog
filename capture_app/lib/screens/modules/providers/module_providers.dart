import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/capture.dart';
import '../../../services/api_service.dart';

// generic provider for fetching modules of a certain type
final moduleCapturesProvider = AsyncNotifierProviderFamily<ModuleCapturesNotifier, List<Capture>, String>(ModuleCapturesNotifier.new);

final captureByIdProvider = FutureProvider.family<Capture, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  return api.getCapture(id);
});

class ModuleCapturesNotifier extends FamilyAsyncNotifier<List<Capture>, String> {
  late String _moduleType;

  @override
  Future<List<Capture>> build(String arg) async {
    _moduleType = arg;
    return _fetchCaptures();
  }

  Future<List<Capture>> _fetchCaptures() async {
    final api = ref.read(apiServiceProvider);
    final res = await api.listCaptures(module: _moduleType, limit: 100); // fetch top 100 for now
    return res.$1;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCaptures());
  }

  Future<void> addModuleCapture({
    required String title,
    required String content,
    Map<String, dynamic> additionalMetadata = const {},
  }) async {
    final api = ref.read(apiServiceProvider);
    
    final metadata = <String, dynamic>{
      'module': _moduleType,
      ...additionalMetadata,
    };

    final input = CaptureInput(
      type: 'text',
      content: content,
      title: title,
      metadata: metadata,
    );

    await api.createCapture(input);
    await refresh();
  }

  Future<void> updateModuleCapture(
    String captureId, {
    String? title,
    String? content,
    Map<String, dynamic>? metadataUpdates,
  }) async {
    final api = ref.read(apiServiceProvider);
    final currentList = state.valueOrNull ?? [];
    
    final existingCapture = currentList.firstWhere((c) => c.id == captureId);
    
    Map<String, dynamic>? mergedMetadata;
    if (metadataUpdates != null) {
      mergedMetadata = Map<String, dynamic>.from(existingCapture.metadata ?? {});
      mergedMetadata.addAll(metadataUpdates);
    }

    // Optimistic update
    state = AsyncValue.data(
      currentList.map((c) {
        if (c.id == captureId) {
          return c.copyWith(
            title: title ?? c.title,
            content: content ?? c.content,
            metadata: mergedMetadata ?? c.metadata,
          );
        }
        return c;
      }).toList(),
    );

    try {
      await api.updateCapture(
        captureId,
        title: title,
        content: content,
        metadata: mergedMetadata,
      );
    } catch (e) {
      // Revert on error by refreshing
      await refresh();
      rethrow;
    }
  }

  Future<void> deleteModuleCapture(String captureId) async {
    final api = ref.read(apiServiceProvider);
    final currentList = state.valueOrNull ?? [];
    
    // Optimistic delete
    state = AsyncValue.data(currentList.where((c) => c.id != captureId).toList());
    
    try {
      await api.deleteCapture(captureId);
    } catch (e) {
      // Revert on error
      await refresh();
      rethrow;
    }
  }
}
