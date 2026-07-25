// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deep_sync_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeepSyncProgress)
final deepSyncProgressProvider = DeepSyncProgressProvider._();

final class DeepSyncProgressProvider
    extends $NotifierProvider<DeepSyncProgress, DeepSyncState> {
  DeepSyncProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepSyncProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepSyncProgressHash();

  @$internal
  @override
  DeepSyncProgress create() => DeepSyncProgress();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeepSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeepSyncState>(value),
    );
  }
}

String _$deepSyncProgressHash() => r'3e1074c775ff9b40935cf99ffdd90a04c905cf45';

abstract class _$DeepSyncProgress extends $Notifier<DeepSyncState> {
  DeepSyncState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DeepSyncState, DeepSyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DeepSyncState, DeepSyncState>,
              DeepSyncState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(deepSyncRepository)
final deepSyncRepositoryProvider = DeepSyncRepositoryProvider._();

final class DeepSyncRepositoryProvider
    extends
        $FunctionalProvider<
          DeepSyncRepository,
          DeepSyncRepository,
          DeepSyncRepository
        >
    with $Provider<DeepSyncRepository> {
  DeepSyncRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepSyncRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepSyncRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeepSyncRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeepSyncRepository create(Ref ref) {
    return deepSyncRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeepSyncRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeepSyncRepository>(value),
    );
  }
}

String _$deepSyncRepositoryHash() =>
    r'5e5127bddef58d56db1b48abf05e2f6cfbcd9de8';
