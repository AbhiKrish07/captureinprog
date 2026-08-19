// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Capture _$CaptureFromJson(Map<String, dynamic> json) {
  return _Capture.fromJson(json);
}

/// @nodoc
mixin _$Capture {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get contentType =>
      throw _privateConstructorUsedError; // text/image/link/file
  String? get type =>
      throw _privateConstructorUsedError; // for backwards compatibility
  String? get title =>
      throw _privateConstructorUsedError; // for backwards compatibility
  String? get preview =>
      throw _privateConstructorUsedError; // for backwards compatibility
  String? get rawUrl => throw _privateConstructorUsedError;
  List<double>? get embedding =>
      throw _privateConstructorUsedError; // 384-dim, MiniLM-L6-v2
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // for backwards compatibility
  double? get relevanceScore => throw _privateConstructorUsedError;

  /// Serializes this Capture to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaptureCopyWith<Capture> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaptureCopyWith<$Res> {
  factory $CaptureCopyWith(Capture value, $Res Function(Capture) then) =
      _$CaptureCopyWithImpl<$Res, Capture>;
  @useResult
  $Res call({
    String id,
    String userId,
    String content,
    String contentType,
    String? type,
    String? title,
    String? preview,
    String? rawUrl,
    List<double>? embedding,
    Map<String, dynamic>? metadata,
    DateTime createdAt,
    DateTime? updatedAt,
    double? relevanceScore,
  });
}

/// @nodoc
class _$CaptureCopyWithImpl<$Res, $Val extends Capture>
    implements $CaptureCopyWith<$Res> {
  _$CaptureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? contentType = null,
    Object? type = freezed,
    Object? title = freezed,
    Object? preview = freezed,
    Object? rawUrl = freezed,
    Object? embedding = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? relevanceScore = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            contentType: null == contentType
                ? _value.contentType
                : contentType // ignore: cast_nullable_to_non_nullable
                      as String,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            preview: freezed == preview
                ? _value.preview
                : preview // ignore: cast_nullable_to_non_nullable
                      as String?,
            rawUrl: freezed == rawUrl
                ? _value.rawUrl
                : rawUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            embedding: freezed == embedding
                ? _value.embedding
                : embedding // ignore: cast_nullable_to_non_nullable
                      as List<double>?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            relevanceScore: freezed == relevanceScore
                ? _value.relevanceScore
                : relevanceScore // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaptureImplCopyWith<$Res> implements $CaptureCopyWith<$Res> {
  factory _$$CaptureImplCopyWith(
    _$CaptureImpl value,
    $Res Function(_$CaptureImpl) then,
  ) = __$$CaptureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String content,
    String contentType,
    String? type,
    String? title,
    String? preview,
    String? rawUrl,
    List<double>? embedding,
    Map<String, dynamic>? metadata,
    DateTime createdAt,
    DateTime? updatedAt,
    double? relevanceScore,
  });
}

/// @nodoc
class __$$CaptureImplCopyWithImpl<$Res>
    extends _$CaptureCopyWithImpl<$Res, _$CaptureImpl>
    implements _$$CaptureImplCopyWith<$Res> {
  __$$CaptureImplCopyWithImpl(
    _$CaptureImpl _value,
    $Res Function(_$CaptureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? contentType = null,
    Object? type = freezed,
    Object? title = freezed,
    Object? preview = freezed,
    Object? rawUrl = freezed,
    Object? embedding = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? relevanceScore = freezed,
  }) {
    return _then(
      _$CaptureImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        contentType: null == contentType
            ? _value.contentType
            : contentType // ignore: cast_nullable_to_non_nullable
                  as String,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        preview: freezed == preview
            ? _value.preview
            : preview // ignore: cast_nullable_to_non_nullable
                  as String?,
        rawUrl: freezed == rawUrl
            ? _value.rawUrl
            : rawUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        embedding: freezed == embedding
            ? _value._embedding
            : embedding // ignore: cast_nullable_to_non_nullable
                  as List<double>?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        relevanceScore: freezed == relevanceScore
            ? _value.relevanceScore
            : relevanceScore // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CaptureImpl extends _Capture {
  _$CaptureImpl({
    required this.id,
    required this.userId,
    required this.content,
    required this.contentType,
    this.type,
    this.title,
    this.preview,
    required this.rawUrl,
    required final List<double>? embedding,
    required final Map<String, dynamic>? metadata,
    required this.createdAt,
    this.updatedAt,
    this.relevanceScore,
  }) : _embedding = embedding,
       _metadata = metadata,
       super._();

  factory _$CaptureImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaptureImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String content;
  @override
  final String contentType;
  // text/image/link/file
  @override
  final String? type;
  // for backwards compatibility
  @override
  final String? title;
  // for backwards compatibility
  @override
  final String? preview;
  // for backwards compatibility
  @override
  final String? rawUrl;
  final List<double>? _embedding;
  @override
  List<double>? get embedding {
    final value = _embedding;
    if (value == null) return null;
    if (_embedding is EqualUnmodifiableListView) return _embedding;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // 384-dim, MiniLM-L6-v2
  final Map<String, dynamic>? _metadata;
  // 384-dim, MiniLM-L6-v2
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  // for backwards compatibility
  @override
  final double? relevanceScore;

  @override
  String toString() {
    return 'Capture(id: $id, userId: $userId, content: $content, contentType: $contentType, type: $type, title: $title, preview: $preview, rawUrl: $rawUrl, embedding: $embedding, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, relevanceScore: $relevanceScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaptureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.preview, preview) || other.preview == preview) &&
            (identical(other.rawUrl, rawUrl) || other.rawUrl == rawUrl) &&
            const DeepCollectionEquality().equals(
              other._embedding,
              _embedding,
            ) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.relevanceScore, relevanceScore) ||
                other.relevanceScore == relevanceScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    content,
    contentType,
    type,
    title,
    preview,
    rawUrl,
    const DeepCollectionEquality().hash(_embedding),
    const DeepCollectionEquality().hash(_metadata),
    createdAt,
    updatedAt,
    relevanceScore,
  );

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaptureImplCopyWith<_$CaptureImpl> get copyWith =>
      __$$CaptureImplCopyWithImpl<_$CaptureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CaptureImplToJson(this);
  }
}

abstract class _Capture extends Capture {
  factory _Capture({
    required final String id,
    required final String userId,
    required final String content,
    required final String contentType,
    final String? type,
    final String? title,
    final String? preview,
    required final String? rawUrl,
    required final List<double>? embedding,
    required final Map<String, dynamic>? metadata,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final double? relevanceScore,
  }) = _$CaptureImpl;
  _Capture._() : super._();

  factory _Capture.fromJson(Map<String, dynamic> json) = _$CaptureImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get content;
  @override
  String get contentType; // text/image/link/file
  @override
  String? get type; // for backwards compatibility
  @override
  String? get title; // for backwards compatibility
  @override
  String? get preview; // for backwards compatibility
  @override
  String? get rawUrl;
  @override
  List<double>? get embedding; // 384-dim, MiniLM-L6-v2
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt; // for backwards compatibility
  @override
  double? get relevanceScore;

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaptureImplCopyWith<_$CaptureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CaptureInput _$CaptureInputFromJson(Map<String, dynamic> json) {
  return _CaptureInput.fromJson(json);
}

/// @nodoc
mixin _$CaptureInput {
  String get type => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this CaptureInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CaptureInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaptureInputCopyWith<CaptureInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaptureInputCopyWith<$Res> {
  factory $CaptureInputCopyWith(
    CaptureInput value,
    $Res Function(CaptureInput) then,
  ) = _$CaptureInputCopyWithImpl<$Res, CaptureInput>;
  @useResult
  $Res call({
    String type,
    String content,
    String? title,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$CaptureInputCopyWithImpl<$Res, $Val extends CaptureInput>
    implements $CaptureInputCopyWith<$Res> {
  _$CaptureInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaptureInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? content = null,
    Object? title = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaptureInputImplCopyWith<$Res>
    implements $CaptureInputCopyWith<$Res> {
  factory _$$CaptureInputImplCopyWith(
    _$CaptureInputImpl value,
    $Res Function(_$CaptureInputImpl) then,
  ) = __$$CaptureInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String content,
    String? title,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$CaptureInputImplCopyWithImpl<$Res>
    extends _$CaptureInputCopyWithImpl<$Res, _$CaptureInputImpl>
    implements _$$CaptureInputImplCopyWith<$Res> {
  __$$CaptureInputImplCopyWithImpl(
    _$CaptureInputImpl _value,
    $Res Function(_$CaptureInputImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaptureInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? content = null,
    Object? title = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$CaptureInputImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CaptureInputImpl implements _CaptureInput {
  _$CaptureInputImpl({
    required this.type,
    required this.content,
    required this.title,
    required final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$CaptureInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaptureInputImplFromJson(json);

  @override
  final String type;
  @override
  final String content;
  @override
  final String? title;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CaptureInput(type: $type, content: $content, title: $title, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaptureInputImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    content,
    title,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of CaptureInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaptureInputImplCopyWith<_$CaptureInputImpl> get copyWith =>
      __$$CaptureInputImplCopyWithImpl<_$CaptureInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CaptureInputImplToJson(this);
  }
}

abstract class _CaptureInput implements CaptureInput {
  factory _CaptureInput({
    required final String type,
    required final String content,
    required final String? title,
    required final Map<String, dynamic>? metadata,
  }) = _$CaptureInputImpl;

  factory _CaptureInput.fromJson(Map<String, dynamic> json) =
      _$CaptureInputImpl.fromJson;

  @override
  String get type;
  @override
  String get content;
  @override
  String? get title;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of CaptureInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaptureInputImplCopyWith<_$CaptureInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
