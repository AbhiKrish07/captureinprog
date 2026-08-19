import 'package:freezed_annotation/freezed_annotation.dart';

part 'capture.freezed.dart';
part 'capture.g.dart';

@freezed
class Capture with _$Capture {
  const Capture._();

  factory Capture({
    required String id,
    required String userId,
    required String content,
    required String contentType, // text/image/link/file
    String? type, // for backwards compatibility
    String? title, // for backwards compatibility
    String? preview, // for backwards compatibility
    required String? rawUrl,
    required List<double>? embedding, // 384-dim, MiniLM-L6-v2
    required Map<String, dynamic>? metadata,
    required DateTime createdAt,
    DateTime? updatedAt, // for backwards compatibility
    double? relevanceScore, // for backwards compatibility
  }) = _Capture;

  String get ingestionStatus {
    return metadata?['status'] as String? ?? 'success';
  }

  factory Capture.fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    m['userId'] = m['userId'] ?? m['user_id'];
    m['createdAt'] = m['createdAt'] ?? m['created_at'];
    m['updatedAt'] = m['updatedAt'] ?? m['updated_at'];
    m['contentType'] = m['contentType'] ?? m['type'] ?? 'text';
    m['relevanceScore'] = m['relevanceScore'] ?? m['relevance_score'];
    m['rawUrl'] = m['rawUrl'] ?? m['raw_url'];
    return _$CaptureFromJson(m);
  }
}

@freezed
class CaptureInput with _$CaptureInput {
  factory CaptureInput({
    required String type,
    required String content,
    required String? title,
    required Map<String, dynamic>? metadata,
  }) = _CaptureInput;

  factory CaptureInput.fromJson(Map<String, dynamic> json) => _$CaptureInputFromJson(json);
}
