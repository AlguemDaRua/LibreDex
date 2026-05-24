// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_calculator_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State notifier utilizing Riverpod codegen to manage individual competitive custom statistics.

@ProviderFor(StatsCalculator)
final statsCalculatorProvider = StatsCalculatorProvider._();

/// State notifier utilizing Riverpod codegen to manage individual competitive custom statistics.
final class StatsCalculatorProvider
    extends $NotifierProvider<StatsCalculator, StatsCalculatorState> {
  /// State notifier utilizing Riverpod codegen to manage individual competitive custom statistics.
  StatsCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsCalculatorHash();

  @$internal
  @override
  StatsCalculator create() => StatsCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsCalculatorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsCalculatorState>(value),
    );
  }
}

String _$statsCalculatorHash() => r'92e4fc2ed0808ab44ed3b7403d17d812c5e0de04';

/// State notifier utilizing Riverpod codegen to manage individual competitive custom statistics.

abstract class _$StatsCalculator extends $Notifier<StatsCalculatorState> {
  StatsCalculatorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StatsCalculatorState, StatsCalculatorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StatsCalculatorState, StatsCalculatorState>,
              StatsCalculatorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
