// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Database provider since we cannot modify app_database.dart.
/// Keeps database singleton and closes it on dispose.

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

/// Database provider since we cannot modify app_database.dart.
/// Keeps database singleton and closes it on dispose.

final class DatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Database provider since we cannot modify app_database.dart.
  /// Keeps database singleton and closes it on dispose.
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$databaseHash() => r'd66464688f3f3beae31aa517238455b4413086f1';

/// Repository provider injected with Drift Database.

@ProviderFor(pokemonRepository)
final pokemonRepositoryProvider = PokemonRepositoryProvider._();

/// Repository provider injected with Drift Database.

final class PokemonRepositoryProvider
    extends
        $FunctionalProvider<
          PokemonRepository,
          PokemonRepository,
          PokemonRepository
        >
    with $Provider<PokemonRepository> {
  /// Repository provider injected with Drift Database.
  PokemonRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pokemonRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pokemonRepositoryHash();

  @$internal
  @override
  $ProviderElement<PokemonRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PokemonRepository create(Ref ref) {
    return pokemonRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PokemonRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PokemonRepository>(value),
    );
  }
}

String _$pokemonRepositoryHash() => r'c23f3eed1171c0a92151bbf3333d38df9b746fc6';

@ProviderFor(pokemonAbilities)
final pokemonAbilitiesProvider = PokemonAbilitiesFamily._();

final class PokemonAbilitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PokemonAbilityWithDetails>>,
          List<PokemonAbilityWithDetails>,
          Stream<List<PokemonAbilityWithDetails>>
        >
    with
        $FutureModifier<List<PokemonAbilityWithDetails>>,
        $StreamProvider<List<PokemonAbilityWithDetails>> {
  PokemonAbilitiesProvider._({
    required PokemonAbilitiesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pokemonAbilitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pokemonAbilitiesHash();

  @override
  String toString() {
    return r'pokemonAbilitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PokemonAbilityWithDetails>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PokemonAbilityWithDetails>> create(Ref ref) {
    final argument = this.argument as int;
    return pokemonAbilities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PokemonAbilitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pokemonAbilitiesHash() => r'a06929f06bb4c4d21aa7d22135238733b142a370';

final class PokemonAbilitiesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<PokemonAbilityWithDetails>>,
          int
        > {
  PokemonAbilitiesFamily._()
    : super(
        retry: null,
        name: r'pokemonAbilitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PokemonAbilitiesProvider call(int pokemonId) =>
      PokemonAbilitiesProvider._(argument: pokemonId, from: this);

  @override
  String toString() => r'pokemonAbilitiesProvider';
}

@ProviderFor(pokemonMoves)
final pokemonMovesProvider = PokemonMovesFamily._();

final class PokemonMovesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PokemonMoveWithDetails>>,
          List<PokemonMoveWithDetails>,
          Stream<List<PokemonMoveWithDetails>>
        >
    with
        $FutureModifier<List<PokemonMoveWithDetails>>,
        $StreamProvider<List<PokemonMoveWithDetails>> {
  PokemonMovesProvider._({
    required PokemonMovesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pokemonMovesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pokemonMovesHash();

  @override
  String toString() {
    return r'pokemonMovesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PokemonMoveWithDetails>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PokemonMoveWithDetails>> create(Ref ref) {
    final argument = this.argument as int;
    return pokemonMoves(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PokemonMovesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pokemonMovesHash() => r'33d78fd8a4c13326f54c31a6ce9a03fee7fb19b6';

final class PokemonMovesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PokemonMoveWithDetails>>, int> {
  PokemonMovesFamily._()
    : super(
        retry: null,
        name: r'pokemonMovesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PokemonMovesProvider call(int pokemonId) =>
      PokemonMovesProvider._(argument: pokemonId, from: this);

  @override
  String toString() => r'pokemonMovesProvider';
}

@ProviderFor(pokemonAbilitiesStream)
final pokemonAbilitiesStreamProvider = PokemonAbilitiesStreamFamily._();

final class PokemonAbilitiesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          Stream<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  PokemonAbilitiesStreamProvider._({
    required PokemonAbilitiesStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pokemonAbilitiesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pokemonAbilitiesStreamHash();

  @override
  String toString() {
    return r'pokemonAbilitiesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as int;
    return pokemonAbilitiesStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PokemonAbilitiesStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pokemonAbilitiesStreamHash() =>
    r'f8fbbc2247671659c40c3d1b6f310e8942102b75';

final class PokemonAbilitiesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Map<String, dynamic>>>, int> {
  PokemonAbilitiesStreamFamily._()
    : super(
        retry: null,
        name: r'pokemonAbilitiesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PokemonAbilitiesStreamProvider call(int pokemonId) =>
      PokemonAbilitiesStreamProvider._(argument: pokemonId, from: this);

  @override
  String toString() => r'pokemonAbilitiesStreamProvider';
}

@ProviderFor(pokemonMovesStream)
final pokemonMovesStreamProvider = PokemonMovesStreamFamily._();

final class PokemonMovesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          Stream<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  PokemonMovesStreamProvider._({
    required PokemonMovesStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pokemonMovesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pokemonMovesStreamHash();

  @override
  String toString() {
    return r'pokemonMovesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as int;
    return pokemonMovesStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PokemonMovesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pokemonMovesStreamHash() =>
    r'165e5aa9be6061e37f597facbb36fc35ccc93bc4';

final class PokemonMovesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Map<String, dynamic>>>, int> {
  PokemonMovesStreamFamily._()
    : super(
        retry: null,
        name: r'pokemonMovesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PokemonMovesStreamProvider call(int pokemonId) =>
      PokemonMovesStreamProvider._(argument: pokemonId, from: this);

  @override
  String toString() => r'pokemonMovesStreamProvider';
}
