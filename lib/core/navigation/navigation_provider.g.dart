// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentMenuIndex)
final currentMenuIndexProvider = CurrentMenuIndexProvider._();

final class CurrentMenuIndexProvider
    extends $NotifierProvider<CurrentMenuIndex, int> {
  CurrentMenuIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentMenuIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentMenuIndexHash();

  @$internal
  @override
  CurrentMenuIndex create() => CurrentMenuIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$currentMenuIndexHash() => r'df9c2d27fedfe591994a75a92d3c4b1f52cf9e0c';

abstract class _$CurrentMenuIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
