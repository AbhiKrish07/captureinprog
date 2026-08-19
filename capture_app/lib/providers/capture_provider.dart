import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/capture.dart';
import '../services/api_service.dart';

part 'capture_provider.g.dart';

// Notifiers for managing capture state

@riverpod
class CaptureListNotifier extends _$CaptureListNotifier {
  late Box _box;

  @override
  Future<List<Capture>> build() async {
    _box = Hive.box('capturesBox');
    
    // Background sync on boot
    _syncFromApiInBackground();
    
    return _getLocalCaptures();
  }

  List<Capture> _getLocalCaptures() {
    final List<Capture> captures = [];
    for (var i = 0; i < _box.length; i++) {
      final item = _box.getAt(i);
      if (item is Map) {
        final jsonMap = jsonDecode(jsonEncode(item)) as Map<String, dynamic>;
        try {
          captures.add(Capture.fromJson(jsonMap));
        } catch (e) {
          // skip
        }
      }
    }
    captures.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return captures;
  }

  Future<void> _syncFromApiInBackground() async {
    try {
      final api = ref.read(apiServiceProvider);
      final (remoteCaptures, _) = await api.listCaptures(limit: 100);
      
      // Update local box with remote captures
      for (final capture in remoteCaptures) {
        await _box.put(capture.id, capture.toJson());
      }
      
      // Refresh UI if we got new data
      state = AsyncValue.data(_getLocalCaptures());
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }

  // Refresh captures
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(_getLocalCaptures());
    _syncFromApiInBackground(); // trigger background sync
  }

  // Add a new capture
  Future<String> addCapture(CaptureInput input) async {
    // 1. Save locally for instant offline feedback
    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    final newCapture = Capture(
      id: localId,
      userId: 'local_user',
      type: input.type,
      contentType: input.type,
      content: input.content,
      rawUrl: null,
      title: input.title,
      preview: null,
      embedding: null,
      metadata: input.metadata,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      relevanceScore: null,
    );
    await _box.put(newCapture.id, newCapture.toJson());
    state = AsyncValue.data(_getLocalCaptures());

    // 2. Sync to API in background
    _syncCreateToApi(input, localId);
    
    return newCapture.id;
  }

  Future<void> _syncCreateToApi(CaptureInput input, String localId) async {
    try {
      final api = ref.read(apiServiceProvider);
      final remoteCapture = await api.createCapture(input);
      // Replace local mock with real remote capture (has real ID and DB fields)
      await _box.delete(localId);
      await _box.put(remoteCapture.id, remoteCapture.toJson());
      state = AsyncValue.data(_getLocalCaptures());
    } catch (e) {
      debugPrint('Failed to sync capture to API: $e');
    }
  }

  // Delete a capture
  Future<void> deleteCapture(String id) async {
    await _box.delete(id);
    state = AsyncValue.data(_getLocalCaptures());

    try {
      final api = ref.read(apiServiceProvider);
      await api.deleteCapture(id);
    } catch (e) {
      debugPrint('Failed to delete on API: $e');
    }
  }

  // Upload a capture file
  Future<void> uploadCapture(File file, String type, String? title) async {
    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    final newCapture = Capture(
      id: localId,
      userId: 'local_user',
      type: type,
      contentType: type,
      content: file.path, 
      rawUrl: null,
      title: title ?? file.path.split('/').last,
      preview: null,
      embedding: null,
      metadata: {'fileUrl': file.path},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      relevanceScore: null,
    );
    await _box.put(newCapture.id, newCapture.toJson());
    state = AsyncValue.data(_getLocalCaptures());

    try {
      final api = ref.read(apiServiceProvider);
      final remoteCapture = await api.uploadCaptureFile(file: file, type: type, title: title);
      await _box.delete(localId);
      await _box.put(remoteCapture.id, remoteCapture.toJson());
      state = AsyncValue.data(_getLocalCaptures());
    } catch (e) {
      debugPrint('Failed to upload to API: $e');
    }
  }

  // Update a capture's details
  Future<void> updateCapture({
    required String id,
    String? title,
    String? preview,
    String? content,
    Map<String, dynamic>? metadata,
  }) async {
    final item = _box.get(id);
    if (item is Map) {
      final jsonMap = jsonDecode(jsonEncode(item)) as Map<String, dynamic>;
      final capture = Capture.fromJson(jsonMap);
      
      final updatedCapture = capture.copyWith(
        title: title ?? capture.title,
        preview: preview ?? capture.preview,
        content: content ?? capture.content,
        metadata: metadata ?? capture.metadata,
        updatedAt: DateTime.now(),
      );
      
      await _box.put(id, updatedCapture.toJson());
      state = AsyncValue.data(_getLocalCaptures());
      
      try {
        final api = ref.read(apiServiceProvider);
        final remoteCapture = await api.updateCapture(id, title: title, preview: preview, content: content, metadata: metadata);
        await _box.put(remoteCapture.id, remoteCapture.toJson());
        state = AsyncValue.data(_getLocalCaptures());
      } catch (e) {
        debugPrint('Failed to update API: $e');
      }
    }
  }
}

// Search captures provider
@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  Future<List<Capture>> build(String query) async {
    if (query.isEmpty) return [];
    return _searchApi(query);
  }

  Future<List<Capture>> _searchApi(String query) async {
    final api = ref.read(apiServiceProvider);
    try {
      return await api.searchCaptures(query: query);
    } catch (e) {
      debugPrint('Error searching via API: $e');
      return [];
    }
  }

  // Update search query
  Future<void> search(String newQuery) async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _searchApi(newQuery));
  }
}

// Current search query state (UI state)
@riverpod
class CurrentSearchQuery extends _$CurrentSearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
}

// Watch search results based on current query
@riverpod
Future<List<Capture>> searchResults(Ref ref) {
  final query = ref.watch(currentSearchQueryProvider);
  return ref.watch(searchNotifierProvider(query).future);
}
