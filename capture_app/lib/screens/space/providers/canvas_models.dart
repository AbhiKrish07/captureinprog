import 'package:flutter/material.dart';

enum CanvasCardType { pdf, video, note, image, link, file, moduleTask }

class CanvasCard {
  final String id;
  final CanvasCardType type;
  final String title;
  final String? content;
  final String? previewUrl;
  final String? author;
  final Offset position;
  final Size size;
  final String? groupId;
  final String? captureId;

  const CanvasCard({
    required this.id,
    required this.type,
    required this.title,
    this.content,
    this.previewUrl,
    this.author,
    required this.position,
    required this.size,
    this.groupId,
    this.captureId,
  });

  CanvasCard copyWith({
    String? id,
    CanvasCardType? type,
    String? title,
    String? content,
    String? previewUrl,
    String? author,
    Offset? position,
    Size? size,
    String? groupId,
    String? captureId,
  }) {
    return CanvasCard(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      previewUrl: previewUrl ?? this.previewUrl,
      author: author ?? this.author,
      position: position ?? this.position,
      size: size ?? this.size,
      groupId: groupId ?? this.groupId,
      captureId: captureId ?? this.captureId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'content': content,
      'previewUrl': previewUrl,
      'author': author,
      'position': {'dx': position.dx, 'dy': position.dy},
      'size': {'width': size.width, 'height': size.height},
      'groupId': groupId,
      'captureId': captureId,
    };
  }

  factory CanvasCard.fromMap(Map<String, dynamic> map) {
    return CanvasCard(
      id: map['id'],
      type: CanvasCardType.values.firstWhere((e) => e.name == map['type'], orElse: () => CanvasCardType.note),
      title: map['title'] ?? 'Untitled',
      content: map['content'],
      previewUrl: map['previewUrl'],
      author: map['author'],
      position: map['position'] != null ? Offset((map['position']['dx'] as num).toDouble(), (map['position']['dy'] as num).toDouble()) : Offset.zero,
      size: map['size'] != null ? Size((map['size']['width'] as num).toDouble(), (map['size']['height'] as num).toDouble()) : const Size(200, 200),
      groupId: map['groupId'],
      captureId: map['captureId'],
    );
  }
}

class CanvasEdge {
  final String id;
  final String sourceId;
  final String targetId;
  final String? label;

  const CanvasEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.label,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceId': sourceId,
      'targetId': targetId,
      'label': label,
    };
  }

  factory CanvasEdge.fromMap(Map<String, dynamic> map) {
    return CanvasEdge(
      id: map['id'],
      sourceId: map['sourceId'],
      targetId: map['targetId'],
      label: map['label'],
    );
  }
}

class CanvasGroup {
  final String id;
  final String title;
  final Color color;

  const CanvasGroup({
    required this.id,
    required this.title,
    required this.color,
  });
}
