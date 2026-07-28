import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Physical data that belongs to a single Pokémon *form* (Mega Charizard X has a
/// different weight than Charizard, so this is keyed by form id, not species id).
@immutable
class FormFacts {
  /// Height in metres.
  final double heightM;

  /// Weight in kilograms. Drives weight-based moves such as Low Kick and Grass Knot.
  final double weightKg;

  /// Base experience yielded when this Pokémon is defeated.
  final int baseExp;

  const FormFacts({
    required this.heightM,
    required this.weightKg,
    required this.baseExp,
  });

  factory FormFacts.fromJson(Map<String, dynamic> json) => FormFacts(
        heightM: (json['heightM'] as num).toDouble(),
        weightKg: (json['weightKg'] as num).toDouble(),
        baseExp: json['baseExp'] as int,
      );

  /// Height rendered as both metric and imperial, e.g. `2.1 m (6'11")`.
  String get heightLabel {
    final totalInches = heightM * 39.3701;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    // Guard the 11.6" -> 12" rounding case.
    final carry = inches == 12;
    return '${heightM.toStringAsFixed(1)} m '
        '(${carry ? feet + 1 : feet}\'${carry ? 0 : inches}")';
  }

  /// Weight rendered as both metric and imperial, e.g. `460.0 kg (1014.1 lbs)`.
  String get weightLabel =>
      '${weightKg.toStringAsFixed(1)} kg (${(weightKg * 2.20462).toStringAsFixed(1)} lbs)';
}

/// Gender distribution of a species.
@immutable
class GenderRatio {
  final bool genderless;
  final double malePercent;
  final double femalePercent;

  const GenderRatio({
    required this.genderless,
    required this.malePercent,
    required this.femalePercent,
  });

  factory GenderRatio.fromJson(Map<String, dynamic> json) => GenderRatio(
        genderless: json['genderless'] as bool,
        malePercent: (json['male'] as num).toDouble(),
        femalePercent: (json['female'] as num).toDouble(),
      );

  String get label {
    if (genderless) return 'Genderless';
    if (malePercent == 0) return '100% Female';
    if (femalePercent == 0) return '100% Male';
    return '${formatPercent(malePercent)}% Male / ${formatPercent(femalePercent)}% Female';
  }

  /// Renders 50.0 as "50" but keeps 87.5 as "87.5".
  static String formatPercent(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}

/// Breeding, catching and training data shared by every form of a species.
@immutable
class SpeciesFacts {
  final int id;
  final int generation;

  /// National dex id this species evolves from, or null when it is a base form.
  final int? evolvesFrom;
  final GenderRatio gender;

  /// Base catch rate, 3 (hardest) to 255 (easiest).
  final int captureRate;
  final int baseHappiness;
  final bool isBaby;

  /// Egg cycles required to hatch.
  final int eggCycles;

  /// Approximate steps required to hatch an egg.
  final int eggSteps;
  final String growthRate;

  /// Total experience needed to reach level 100 on this growth rate.
  final int growthTotalExp;
  final bool isLegendary;
  final bool isMythical;
  final List<String> eggGroups;

  const SpeciesFacts({
    required this.id,
    required this.generation,
    required this.evolvesFrom,
    required this.gender,
    required this.captureRate,
    required this.baseHappiness,
    required this.isBaby,
    required this.eggCycles,
    required this.eggSteps,
    required this.growthRate,
    required this.growthTotalExp,
    required this.isLegendary,
    required this.isMythical,
    required this.eggGroups,
  });

  factory SpeciesFacts.fromJson(Map<String, dynamic> json) => SpeciesFacts(
        id: json['id'] as int,
        generation: json['generation'] as int,
        evolvesFrom: json['evolvesFrom'] as int?,
        gender: GenderRatio.fromJson(json['gender'] as Map<String, dynamic>),
        captureRate: json['captureRate'] as int,
        baseHappiness: json['baseHappiness'] as int,
        isBaby: json['isBaby'] as bool,
        eggCycles: json['eggCycles'] as int,
        eggSteps: json['eggSteps'] as int,
        growthRate: json['growthRate'] as String,
        growthTotalExp: json['growthTotalExp'] as int,
        isLegendary: json['isLegendary'] as bool,
        isMythical: json['isMythical'] as bool,
        eggGroups: (json['eggGroups'] as List<dynamic>).cast<String>(),
      );

  /// Species in the Undiscovered egg group cannot be bred.
  bool get canBreed => eggGroups.isNotEmpty && !eggGroups.contains('Undiscovered');

  /// Odds of catching at full HP with a standard Poké Ball, as a percentage.
  ///
  /// Uses the Gen III+ capture formula with `HP_max = HP_current` and a 1× ball,
  /// which reduces to `(captureRate / 3) / 255` per shake check.
  double get pokeballCatchPercent {
    final a = captureRate / 3 / 255;
    return (a * a * a * a * 100).clamp(0, 100).toDouble();
  }

  String get captureRateLabel {
    final percent = pokeballCatchPercent;
    final formatted = percent >= 1 ? percent.toStringAsFixed(1) : percent.toStringAsFixed(2);
    return '$captureRate ($formatted% with a Poké Ball at full HP)';
  }

  String get eggGroupLabel => eggGroups.isEmpty ? 'Unknown' : eggGroups.join(' / ');
}

/// The bundled species dataset, extracted from the open-source PokéAPI CSV data
/// and bundled with the app so these facts remain available without a connection.
@immutable
class SpeciesDataset {
  final Map<int, FormFacts> _forms;
  final Map<int, SpeciesFacts> _species;

  const SpeciesDataset._(this._forms, this._species);

  static const SpeciesDataset empty = SpeciesDataset._({}, {});

  /// 100%-male distribution used by [formGenderOverrides].
  static const GenderRatio maleLocked =
      GenderRatio(genderless: false, malePercent: 100, femalePercent: 0);

  /// 100%-female distribution used by [formGenderOverrides].
  static const GenderRatio femaleLocked =
      GenderRatio(genderless: false, malePercent: 0, femalePercent: 100);

  /// Forms whose gender ratio differs from the *species* ratio shipped by
  /// PokéAPI.
  ///
  /// Species-level gender data is shared by every form, which is wrong for
  /// the gender-morph forms (Indeedee-Female is always female while the
  /// species reads 50/50) and for event/cosplay forms with a locked gender
  /// (cap Pikachu is always male; Cosplay Pikachu always female). Keyed by
  /// bundled Pokémon form id.
  static const Map<int, GenderRatio> formGenderOverrides = {
    // Gender-morph forms: the base row is the male visual, the separate
    // 10xxx row is the female visual. Each is gender-locked in the games.
    678: maleLocked, // Meowstic-Male
    10025: femaleLocked, // Meowstic-Female
    876: maleLocked, // Indeedee-Male
    10186: femaleLocked, // Indeedee-Female
    902: maleLocked, // Basculegion-Male
    10248: femaleLocked, // Basculegion-Female
    10254: femaleLocked, // Oinkologne-Female (species 916 reads 100% male)
    // Cosplay Pikachu outfits are female-only.
    10080: femaleLocked,
    10081: femaleLocked,
    10082: femaleLocked,
    10083: femaleLocked,
    10084: femaleLocked,
    10085: femaleLocked,
    // Cap Pikachu gifts are always male.
    10094: maleLocked,
    10095: maleLocked,
    10096: maleLocked,
    10097: maleLocked,
    10098: maleLocked,
    10099: maleLocked,
    10160: maleLocked,
    // Battle Bond / Ash-Greninja are event-fixed males.
    10116: maleLocked,
    10117: maleLocked,
  };

  /// Physical facts for a specific form id (falls back to the base species when
  /// a form has no dedicated entry).
  FormFacts? formFacts(int formId, {int? nationalDexNumber}) =>
      _forms[formId] ?? (nationalDexNumber != null ? _forms[nationalDexNumber] : null);

  /// Breeding and training facts for a national dex number.
  SpeciesFacts? speciesFacts(int nationalDexNumber) => _species[nationalDexNumber];

  /// Gender ratio for a specific form, applying [formGenderOverrides] before
  /// falling back to the species-wide ratio.
  GenderRatio? genderFor(int formId, {int? nationalDexNumber}) =>
      formGenderOverrides[formId] ??
      (nationalDexNumber != null ? _species[nationalDexNumber]?.gender : null);

  bool get isEmpty => _forms.isEmpty && _species.isEmpty;

  static SpeciesDataset _parse(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final forms = <int, FormFacts>{};
    (json['forms'] as Map<String, dynamic>).forEach((key, value) {
      final id = int.tryParse(key);
      if (id != null) forms[id] = FormFacts.fromJson(value as Map<String, dynamic>);
    });

    final species = <int, SpeciesFacts>{};
    (json['species'] as Map<String, dynamic>).forEach((key, value) {
      final id = int.tryParse(key);
      if (id != null) species[id] = SpeciesFacts.fromJson(value as Map<String, dynamic>);
    });

    return SpeciesDataset._(forms, species);
  }
}

/// Loads and caches the bundled species dataset.
///
/// Decoding happens on a background isolate so the first Pokémon detail screen
/// never drops a frame, and the parsed result is kept alive for the app session.
final speciesDatasetProvider = FutureProvider<SpeciesDataset>((ref) async {
  final raw = await rootBundle.loadString('assets/data/species.json');
  return compute(SpeciesDataset._parse, raw);
});
