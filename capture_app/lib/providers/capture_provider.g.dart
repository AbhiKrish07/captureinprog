// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchResultsHash() => r'9461427249723047a1423c0d3c57814387a5d504';

/// See also [searchResults].
@ProviderFor(searchResults)
final searchResultsProvider = AutoDisposeFutureProvider<List<Capture>>.internal(
  searchResults,
  name: r'searchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchResultsRef = AutoDisposeFutureProviderRef<List<Capture>>;
String _$captureListNotifierHash() =>
    r'4768150a2a3228f38a55597d8c7db3554c3d8928';

/// See also [CaptureListNotifier].
@ProviderFor(CaptureListNotifier)
final captureListNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      CaptureListNotifier,
      List<Capture>
    >.internal(
      CaptureListNotifier.new,
      name: r'captureListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$captureListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CaptureListNotifier = AutoDisposeAsyncNotifier<List<Capture>>;
String _$searchNotifierHash() => r'019c00fab77e6a80d0d30a02b83fdb481ef3f956';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SearchNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Capture>> {
  late final String query;

  FutureOr<List<Capture>> build(String query);
}

/// See also [SearchNotifier].
@ProviderFor(SearchNotifier)
const searchNotifierProvider = SearchNotifierFamily();

/// See also [SearchNotifier].
class SearchNotifierFamily extends Family<AsyncValue<List<Capture>>> {
  /// See also [SearchNotifier].
  const SearchNotifierFamily();

  /// See also [SearchNotifier].
  SearchNotifierProvider call(String query) {
    return SearchNotifierProvider(query);
  }

  @override
  SearchNotifierProvider getProviderOverride(
    covariant SearchNotifierProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchNotifierProvider';
}

/// See also [SearchNotifier].
class SearchNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<SearchNotifier, List<Capture>> {
  /// See also [SearchNotifier].
  SearchNotifierProvider(String query)
    : this._internal(
        () => SearchNotifier()..query = query,
        from: searchNotifierProvider,
        name: r'searchNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchNotifierHash,
        dependencies: SearchNotifierFamily._dependencies,
        allTransitiveDependencies:
            SearchNotifierFamily._allTransitiveDependencies,
        query: query,
      );

  SearchNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<List<Capture>> runNotifierBuild(covariant SearchNotifier notifier) {
    return notifier.build(query);
  }

  @override
  Override overrideWith(SearchNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SearchNotifierProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SearchNotifier, List<Capture>>
  createElement() {
    return _SearchNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchNotifierProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Capture>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<SearchNotifier, List<Capture>>
    with SearchNotifierRef {
  _SearchNotifierProviderElement(super.provider);

  @override
  String get query => (origin as SearchNotifierProvider).query;
}

String _$currentSearchQueryHash() =>
    r'cfc17c1aeccd727d1ac3e7fe06ea4cbfaeded0a7';

/// See also [CurrentSearchQuery].
@ProviderFor(CurrentSearchQuery)
final currentSearchQueryProvider =
    AutoDisposeNotifierProvider<CurrentSearchQuery, String>.internal(
      CurrentSearchQuery.new,
      name: r'currentSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
