// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'damage_calculator_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DamageCalculatorViewModel)
final damageCalculatorViewModelProvider = DamageCalculatorViewModelProvider._();

final class DamageCalculatorViewModelProvider
    extends
        $NotifierProvider<DamageCalculatorViewModel, DamageCalculatorState> {
  DamageCalculatorViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'damageCalculatorViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$damageCalculatorViewModelHash();

  @$internal
  @override
  DamageCalculatorViewModel create() => DamageCalculatorViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DamageCalculatorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DamageCalculatorState>(value),
    );
  }
}

String _$damageCalculatorViewModelHash() =>
    r'26db64f43bb6e755abbc4dfd885b1644cc4ae120';

abstract class _$DamageCalculatorViewModel
    extends $Notifier<DamageCalculatorState> {
  DamageCalculatorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DamageCalculatorState, DamageCalculatorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DamageCalculatorState, DamageCalculatorState>,
              DamageCalculatorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
