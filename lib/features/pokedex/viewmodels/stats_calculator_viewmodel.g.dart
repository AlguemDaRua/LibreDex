// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_calculator_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StatsCalculator)
final statsCalculatorProvider = StatsCalculatorProvider._();

final class StatsCalculatorProvider
    extends $NotifierProvider<StatsCalculator, StatsCalculatorState> {
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

String _$statsCalculatorHash() => r'1ec5bff839d75da8d0376582d7f1bc5a9fcc349c';

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
