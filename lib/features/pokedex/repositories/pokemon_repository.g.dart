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
        isAutoDispose: true,
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

String _$databaseHash() => r'b43f5a38382427710fbceefeb419518e859b35ea';

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
        isAutoDispose: true,
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

String _$pokemonRepositoryHash() => r'5c6a64840b2f31adfc90cf2a7a947db169c73ee1';

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
