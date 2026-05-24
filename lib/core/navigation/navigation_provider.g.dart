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

String _$currentMenuIndexHash() => r'9590208a0e130a3de73d5b3d08c3b8d67eec1ec8';

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
