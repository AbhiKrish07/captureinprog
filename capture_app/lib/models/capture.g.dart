// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CaptureImpl _$$CaptureImplFromJson(Map<String, dynamic> json) =>
    _$CaptureImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      contentType: json['contentType'] as String,
      type: json['type'] as String?,
      title: json['title'] as String?,
      preview: json['preview'] as String?,
      rawUrl: json['rawUrl'] as String?,
      embedding: (json['embedding'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$CaptureImplToJson(_$CaptureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'content': instance.content,
      'contentType': instance.contentType,
      'type': instance.type,
      'title': instance.title,
      'preview': instance.preview,
      'rawUrl': instance.rawUrl,
      'embedding': instance.embedding,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'relevanceScore': instance.relevanceScore,
    };

_$CaptureInputImpl _$$CaptureInputImplFromJson(Map<String, dynamic> json) =>
    _$CaptureInputImpl(
      type: json['type'] as String,
      content: json['content'] as String,
      title: json['title'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CaptureInputImplToJson(_$CaptureInputImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'content': instance.content,
      'title': instance.title,
      'metadata': instance.metadata,
    };
